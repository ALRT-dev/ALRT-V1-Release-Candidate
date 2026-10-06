import 'dart:convert';

/// Custom exception for JWT token related errors
class JwtException implements Exception {
  final String message;
  final dynamic originalError;

  const JwtException(this.message, [this.originalError]);

  @override
  String toString() =>
      'JwtException: $message${originalError != null ? ' ($originalError)' : ''}';
}

class TokenHandler {
  ///Gets the payload for the stored JWT token.
  ///
  ///Returns ```Map<String, dynamic>``` of the payload object which is encryped in jwt token
  ///
  //////Throws [JwtException] if no valid JWT token is stored, it's malformed or its payload cannot be decoded.
  ///```Note:```
  ///Make sure to save token using ```FlutterSessionJwt.saveToken("token here")``` method before using other methods
  static Future<Map<String, dynamic>> getPayload({
    required final String token,
  }) async {
    try {
      if (token.isEmpty) {
        throw const JwtException(
          'No token found: Please save a valid JWT token first',
        );
      }

      final splitToken = token.split(".");
      if (splitToken.length != 3) {
        throw const JwtException(
          'Invalid token format: JWT must have three parts',
        );
      }

      try {
        final payloadBase64 = splitToken[1];
        final normalizedPayload = base64.normalize(payloadBase64);
        final payloadString = utf8.decode(base64.decode(normalizedPayload));
        final decodedPayload = jsonDecode(payloadString);
        return decodedPayload;
      } on FormatException catch (e) {
        throw JwtException('Invalid payload format', e);
      } catch (e) {
        throw JwtException('Failed to decode payload', e);
      }
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get payload', e);
    }
  }

  /// Returns ```true``` if token has expired else returns ```false```
  static Future<bool> isTokenExpired({
    required final String token,
  }) async {
    try {
      final expirationDate = await getExpirationDateTime(
        token: token,
      );
      if (expirationDate == null) {
        throw const JwtException('No expiration date found in token');
      }
      // If current date is after the expiration date from token, then JWT token is expired
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to check token expiration', e);
    }
  }

  /// Returns the JWT token's ```DateTime``` of expiration (exp).
  ///
  /// Returns ```null``` if expiration date is not found in payload.
  ///
  /// Throws [JwtException] if no JWT token is stored.
  static Future<DateTime?> getExpirationDateTime({
    required final String token,
  }) async {
    try {
      return await _getTokenDate(token: token, param: 'exp');
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get expiration date', e);
    }
  }

  /// Returns the JWT token's ```DateTime``` of issue (iat).
  ///
  /// Returns ```null``` if issue date is not found in payload.
  ///
  /// Throws [JwtException] if no JWT token is stored.
  static Future<DateTime?> getIssuedDateTime({
    required final String token,
  }) async {
    try {
      return await _getTokenDate(token: token, param: 'iat');
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get issue date', e);
    }
  }

  /// Returns the ```Duration``` since the JWT token's issue.
  ///
  /// Returns null if issued date is not found in payload.
  static Future<Duration?> getDurationFromIssuedTime({
    required final String token,
  }) async {
    try {
      final issuedAtDate = await getIssuedDateTime(token: token);
      if (issuedAtDate == null) {
        return null;
      }
      return DateTime.now().difference(issuedAtDate);
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to calculate duration from issue time', e);
    }
  }

  static Future<DateTime?> _getTokenDate({
    required final String token,
    required final String param,
  }) async {
    try {
      final decodedToken = await getPayload(
        token: token,
      );
      final date = decodedToken[param] as int?;
      if (date == null) {
        return null;
      }
      // convert milliseconds to valid ```DateTime```
      return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    } catch (e) {
      if (e is JwtException) rethrow;
      throw JwtException('Failed to get token date for parameter: $param', e);
    }
  }
}
