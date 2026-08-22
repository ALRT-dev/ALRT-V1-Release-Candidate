import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/ask_alrt/models/ask_alrt_local_answers.dart';

String? ask(final String q) =>
    AskAlrtLocalAnswers.answerFor(q, emergencyNumber: '911');

void main() {
  group('answers the basics with no network', () {
    test('shape questions', () {
      expect(ask('what do the shapes mean'), contains('Triangle'));
      expect(ask('what does the triangle mean'), contains('AWS'));
      expect(ask('what does the shield mean'), contains('Shield'));
    });

    test('colour questions', () {
      expect(ask('what do the colours mean'), contains('Critical'));
      expect(ask('what does orange mean'), contains('Action'));
    });

    test('privacy questions', () {
      expect(ask('do you track me'), contains('never live-tracks'));
      expect(ask('is my location shared'), contains('only when you send it'));
    });

    test('family and pricing', () {
      expect(ask('can i be in more than one group'), contains('always free'));
      expect(ask('is it free'), contains('always free'));
    });

    test('sos', () {
      expect(ask('how do i send an sos'), contains('3 seconds'));
    });
  });

  group('the emergency number is never hard-coded', () {
    test('placeholder is replaced with the resolved number', () {
      final answer = ask('do you contact emergency services');
      expect(answer, contains('911'));
      expect(answer, isNot(contains('{emergency}')));
      expect(answer, isNot(contains('000')));
    });

    test('a different region gets its own number', () {
      final answer = AskAlrtLocalAnswers.answerFor(
        'what number do i call',
        emergencyNumber: '112',
      );
      expect(answer, contains('112'));
    });

    test('no seeded answer leaks a placeholder or hard-codes 000', () {
      for (final entry in AskAlrtLocalAnswers.entries) {
        final rendered = entry.answer.replaceAll('{emergency}', '999');
        expect(
          rendered.contains('{'),
          isFalse,
          reason: '${entry.id} still has an unfilled placeholder',
        );
        expect(
          RegExp(r'\b000\b').hasMatch(rendered),
          isFalse,
          reason: '${entry.id} hard-codes 000',
        );
      }
    });
  });

  group('stays quiet rather than guessing', () {
    test('unrelated questions get nothing', () {
      expect(ask('what is the capital of France'), isNull);
      expect(ask('write me a poem'), isNull);
      expect(ask(''), isNull);
      expect(ask('asdfgh'), isNull);
    });

    test('a bare vague word does not trigger an answer', () {
      expect(ask('hi'), isNull);
      expect(ask('thanks'), isNull);
    });
  });

  group('never promises what ALRT does not do', () {
    test('no answer claims ALRT contacts emergency services', () {
      for (final entry in AskAlrtLocalAnswers.entries) {
        final lower = entry.answer.toLowerCase();
        if (lower.contains('contact')) {
          expect(
            lower.contains('does not contact') ||
                lower.contains('never contacts'),
            isTrue,
            reason: '${entry.id} may imply ALRT contacts emergency services',
          );
        }
      }
    });

    test('no answer quotes a price', () {
      for (final entry in AskAlrtLocalAnswers.entries) {
        expect(
          RegExp(r'\$\s*\d').hasMatch(entry.answer),
          isFalse,
          reason: '${entry.id} quotes a price; prices come from the store',
        );
      }
    });
  });
}
