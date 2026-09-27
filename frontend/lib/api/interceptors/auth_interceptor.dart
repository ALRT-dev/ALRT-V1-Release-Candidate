import 'package:dio/dio.dart';
import 'package:hazard_app/api/auth_session_events.dart';
import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/api/token_handler.dart';
import 'package:hazard_app/features/shared/enums/shared_prefs_key_types.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';
import 'package:hazard_app/features/shared/utils/async_call_helper.dart';
import 'package:hazard_app/features/shared/utils/either.dart';

class AuthInterceptor implements Interceptor {
  AuthInterceptor({
    required final Dio dio,
    required final SharedPreferencesRepository sharedPreferencesRepository,
  }) : _dio = dio,
       _sharedPreferencesRepository = sharedPreferencesRepository;

  final Dio _dio;
  final SharedPreferencesRepository _sharedPreferencesRepository;

  /// Single in-flight refresh shared by all concurrent requests, so an
  /// expired token triggers exactly one refresh call instead of one per
  /// pending request.
  Future<String?>? _refreshInFlight;

  /// Refresh slightly before the actual expiry so a token that is valid now
  /// doesn't expire mid-flight.
  static const _expiryBuffer = Duration(seconds: 60);

  /// Marker to ensure a request is only retried once after a 401.
  static const _retriedExtraKey = 'authInterceptorRetried';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    final isUnauthorized = response?.statusCode == 401;
    final isRefreshCall = requestOptions.path.contains(kUrlRefreshToken);
    final alreadyRetried =
        requestOptions.extra[_retriedExtraKey] == true;

    if (!isUnauthorized || isRefreshCall || alreadyRetried) {
      return handler.next(err);
    }

    // The server rejected our token: force one refresh and retry once.
    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      // Refresh failed — the session is gone. Clear tokens and tell the app.
      await _clearStoredTokens();
      AuthSessionEvents.notifySessionExpired();
      return handler.next(err);
    }

    try {
      final retryOptions = requestOptions
        ..headers['Authorization'] = 'Bearer $newAccessToken'
        ..extra[_retriedExtraKey] = true;
      final retryResponse = await _dio.fetch<dynamic>(retryOptions);
      return handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final headersResult = await getApiHeaders(
      requestEndpoint: options.path,
      existingHeaders: options.headers,
    );
    final headers = headersResult.whenSuccess(
      (success) => success,
    );

    if (headers != null) {
      options.headers = Map<String, dynamic>.from(headers)
        ..addAll(options.headers);
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  /// Returns the headers for the request based on the current user.
  Future<Either<Map<String, String>, AppError>> getApiHeaders({
    required final String requestEndpoint,
    required final Map<String, dynamic> existingHeaders,
  }) {
    return runAsyncCall(
      name: 'Getting DIO headers',
      withLog: false,
      future: () async {
        // ignore adding token to the endpoints that do not require authentication
        final ignoreEndpoints = [kUrlRefreshToken];

        final ignoreToken = ignoreEndpoints.any(
          (endpoint) => requestEndpoint.contains(endpoint),
        );

        final accessToken = ignoreToken ? null : await getAccessToken();
        final headers = <String, String>{
          'Accept-Encoding': 'gzip, deflate',
          'content-type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          ...existingHeaders,
        };

        return Success(headers);
      },
      onError: Failure.new,
    );
  }

  /// Retrieves the access token from shared preferences.
  Future<String?> getAccessToken() async {
    // get the accessToken from the local storage
    final result = await _sharedPreferencesRepository.getString(
      key: SharedPrefsKey.accessToken,
    );
    final accessToken = result.whenSuccess(
      (success) {
        if (success is String) return success;
        return null;
      },
    );
    if (accessToken == null) return null;

    // A malformed token is treated as expired rather than crashing the call.
    bool isExpired;
    try {
      final expirationDate = await TokenHandler.getExpirationDateTime(
        token: accessToken,
      );
      isExpired = expirationDate == null ||
          DateTime.now().add(_expiryBuffer).isAfter(expirationDate);
    } catch (_) {
      isExpired = true;
    }

    if (isExpired) {
      return await _refreshAccessToken() ?? accessToken;
    }

    return accessToken;
  }

  /// Refreshes the access token, coalescing concurrent callers onto a single
  /// in-flight request. Returns null when the refresh fails.
  Future<String?> _refreshAccessToken() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final refreshFuture = _doRefreshAccessToken().whenComplete(() {
      _refreshInFlight = null;
    });
    _refreshInFlight = refreshFuture;
    return refreshFuture;
  }

  Future<String?> _doRefreshAccessToken() async {
    final newAccessTokenResult = await _generateNewAccessToken();
    return newAccessTokenResult.whenSuccess((success) {
      // save the new access token to the local storage.
      _sharedPreferencesRepository.saveString(
        key: SharedPrefsKey.accessToken,
        value: success,
      );
      return success;
    });
  }

  Future<void> _clearStoredTokens() async {
    await Future.wait([
      _sharedPreferencesRepository.removeKey(key: SharedPrefsKey.accessToken),
      _sharedPreferencesRepository.removeKey(key: SharedPrefsKey.refreshToken),
    ]);
  }

  /// Calls the API to generate new accessToken using the old refreshToken.
  Future<Either<String, AppError>> _generateNewAccessToken() {
    return runAsyncCall(
      name: 'generateNewAccessToken',
      future: () async {
        final result = await _sharedPreferencesRepository.getString(
          key: SharedPrefsKey.refreshToken,
        );
        final refreshToken = result.whenSuccess(
          (success) {
            if (success is String) return success;
            return null;
          },
        );
        if (refreshToken == null) {
          throw AppError(message: 'No refresh token!');
        }

        final request = await _dio.post<Map<String, dynamic>>(
          kUrlRefreshToken,
          data: {
            'refreshToken': refreshToken,
          },
        );

        final data = request.data;
        if (data?['accessToken'] == null || data?['accessToken'] is! String) {
          throw AppError(
            message: 'accessToken could not be generated',
          );
        }

        final newAccessToken = data!['accessToken'] as String;
        return Success(newAccessToken);
      },
      onError: Failure.new,
    );
  }
}
