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
              'code': 'ask_limit',
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

  test(
    'a 502/503 says Ask ALRT is unavailable and does not use up the question',
    () async {
      for (final status in [502, 503]) {
        var allowanceReads = 0;
        final dio = _fakeDio((options, handler) {
          if (options.path.endsWith('/allowance')) {
            allowanceReads += 1;
            return handler.resolve(
              _json(options, 200, {'limit': 3, 'used': 1, 'remaining': 2}),
            );
          }
          handler.reject(
            DioException(
              requestOptions: options,
              response: _json(options, status, {'error': 'Bad gateway'}),
              type: DioExceptionType.badResponse,
            ),
          );
        });
        final container = _container(dio);
        addTearDown(container.dispose);
        final sub = container.listen(providerOfAskAlrt, (_, _) {});
        addTearDown(sub.close);
        final notifier = container.read(providerOfAskAlrt.notifier);
        await notifier.refreshAllowance();
        final readsBefore = allowanceReads;

        await notifier.ask('How do I send an SOS?');
        await Future<void>.delayed(Duration.zero);

        final state = container.read(providerOfAskAlrt);
        expect(
          state.messages.last.text,
          'Ask ALRT is temporarily unavailable. Try again soon.',
          reason: 'status $status',
        );
        expect(state.messages.last.text, isNot(contains('–')));
        expect(state.remainingToday, 2, reason: 'status $status');
        expect(state.limitReached, isFalse);
        expect(allowanceReads, greaterThan(readsBefore));
      }
    },
  );

  test('a 400 is not answered with the offline text either', () async {
    final dio = _fakeDio((options, handler) {
      if (options.path.endsWith('/allowance')) {
        return handler.resolve(
          _json(options, 200, {'limit': 3, 'used': 0, 'remaining': 3}),
        );
      }
      handler.reject(
        DioException(
          requestOptions: options,
          response: _json(options, 400, {'error': 'Invalid input'}),
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
    expect(state.messages.last.text, AskAlrtProvider.unavailableAnswer);
    expect(state.limitReached, isFalse);
  });

  test(
    'a 429 without the ask_limit code is the rate limiter, not the daily limit',
    () async {
      final dio = _fakeDio((options, handler) {
        if (options.path.endsWith('/allowance')) {
          return handler.resolve(
            _json(options, 200, {'limit': 3, 'used': 1, 'remaining': 2}),
          );
        }
        handler.reject(
          DioException(
            requestOptions: options,
            response: _json(options, 429, {
              'error': 'Too many requests',
              'message': 'Slow down',
            }),
            type: DioExceptionType.badResponse,
          ),
        );
      });
      final container = _container(dio);
      addTearDown(container.dispose);
      final sub = container.listen(providerOfAskAlrt, (_, _) {});
      addTearDown(sub.close);
      final notifier = container.read(providerOfAskAlrt.notifier);
      await notifier.refreshAllowance();

      await notifier.ask('Anything near me?');

      final state = container.read(providerOfAskAlrt);
      expect(
        state.messages.last.text,
        'Too many requests. Try again in a minute.',
      );
      expect(state.limitReached, isFalse);
      expect(state.remainingToday, 2);
    },
  );

  test('a timeout still answers from the phone', () async {
    final dio = _fakeDio((options, handler) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        ),
      );
    });
    final container = _container(dio);
    addTearDown(container.dispose);
    final sub = container.listen(providerOfAskAlrt, (_, _) {});
    addTearDown(sub.close);

    await container.read(providerOfAskAlrt.notifier).ask('What is ALRT?');

    final state = container.read(providerOfAskAlrt);
    expect(state.messages.last.text, isNot(AskAlrtProvider.unavailableAnswer));
    expect(state.messages.last.text, isNotEmpty);
  });

  test('the question is trimmed to the server limit before sending', () async {
    Object? sent;
    final dio = _fakeDio((options, handler) {
      if (options.path.endsWith('/allowance')) {
        return handler.resolve(
          _json(options, 200, {'limit': 3, 'used': 0, 'remaining': 3}),
        );
      }
      sent = options.data;
      handler.resolve(_json(options, 200, {'answer': 'ok'}));
    });
    final container = _container(dio);
    addTearDown(container.dispose);
    final sub = container.listen(providerOfAskAlrt, (_, _) {});
    addTearDown(sub.close);

    await container.read(providerOfAskAlrt.notifier).ask('a' * 2500);

    expect(sent, isA<Map>());
    expect(
      ((sent! as Map)['question'] as String).length,
      AskAlrtProvider.maxQuestionLength,
    );
  });

  test('clip keeps text within a limit without splitting a character', () {
    expect(AskAlrtProvider.clip('short', 300), 'short');
    expect(AskAlrtProvider.clip('x' * 400, 300).length, 300);
    final emoji = '${'x' * 299}\u{1F525}';
    final clipped = AskAlrtProvider.clip(emoji, 300);
    expect(clipped.length, lessThanOrEqualTo(300));
    expect(clipped, 'x' * 299);
  });
}
