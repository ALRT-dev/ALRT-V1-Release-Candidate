import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/ask_alrt/models/ask_alrt_message.dart';
import 'package:hazard_app/features/ask_alrt/providers/ask_alrt_provider.dart';
import 'package:hazard_app/features/shared/providers/dio_instance_provider.dart';
import 'package:hazard_app/features/shared/services/emergency_number.dart';

/// A Dio whose every request is answered by [handler], never the network.
Dio _fakeDio(
  final void Function(RequestOptions, RequestInterceptorHandler) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: handler));
  return dio;
}

ProviderContainer _container(final Dio dio) => ProviderContainer(
  overrides: [
    providerOfDioInstance(true).overrideWithValue(dio),
    providerOfEmergencyNumber.overrideWithValue('000'),
  ],
);

Response<dynamic> _json(
  final RequestOptions options,
  final int status,
  final Object body,
) => Response<dynamic>(
  requestOptions: options,
  statusCode: status,
  data: body,
);

void main() {
  test('a question the phone could answer still goes to the server', () async {
    final asked = <String>[];
    final dio = _fakeDio((options, handler) {
      asked.add(options.path);
      if (options.path.endsWith('/allowance')) {
        return handler.resolve(
          _json(options, 200, {'limit': 3, 'used': 0, 'remaining': 3}),
        );
      }
      handler.resolve(
        _json(options, 200, {
          'answer': 'From the library',
          'remainingToday': 2,
        }),
      );
    });
    final container = _container(dio);
    addTearDown(container.dispose);
    final sub = container.listen(providerOfAskAlrt, (_, _) {});
    addTearDown(sub.close);

    await container.read(providerOfAskAlrt.notifier).ask('How much is ALRT +?');

    expect(asked.where((p) => p.endsWith('/ask-alrt')), hasLength(1));
    final state = container.read(providerOfAskAlrt);
    expect(state.messages.last.role, AskAlrtRole.assistant);
    expect(state.messages.last.text, 'From the library');
    expect(state.remainingToday, 2);
    expect(state.limitReached, isFalse);
  });

  test(
    'at the limit the server message is shown and the limit flagged',
    () async {
      final dio = _fakeDio((options, handler) {
        if (options.path.endsWith('/allowance')) {
          return handler.resolve(
            _json(options, 200, {'limit': 3, 'used': 3, 'remaining': 0}),
          );
        }
        handler.reject(
          DioException(
            requestOptions: options,
            response: _json(options, 429, {
              'error': 'You have used your 3 questions today.',
            }),
            type: DioExceptionType.badResponse,
          ),
        );
      });
      final container = _container(dio);
      addTearDown(container.dispose);
      final sub = container.listen(providerOfAskAlrt, (_, _) {});
      addTearDown(sub.close);

      await container.read(providerOfAskAlrt.notifier).ask('Anything near me?');

      final state = container.read(providerOfAskAlrt);
      expect(state.messages.last.text, 'You have used your 3 questions today.');
      expect(state.limitReached, isTrue);
      expect(state.remainingToday, 0);
    },
  );

  test('offline, the phone answers the basics instead', () async {
    final dio = _fakeDio((options, handler) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
    });
    final container = _container(dio);
    addTearDown(container.dispose);
    final sub = container.listen(providerOfAskAlrt, (_, _) {});
    addTearDown(sub.close);

    await container
        .read(providerOfAskAlrt.notifier)
        .ask('How do I send an SOS?');

    final state = container.read(providerOfAskAlrt);
    expect(state.messages.last.role, AskAlrtRole.assistant);
    expect(state.messages.last.text, isNotEmpty);
    expect(state.messages.last.text, isNot(contains('—')));
    expect(state.limitReached, isFalse);
  });
}
