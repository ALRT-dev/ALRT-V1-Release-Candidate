import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/utils/attributed_action_parts.dart';

void main() {
  for (final action in [
    'CFS advises: Leave, then use North Road.',
    'CFS advises:  Do not use the bridge.  Take the signed route.',
    'CFS advises:\nIf you are east of the river, stay indoors.\nWait for updates.',
    'CFS advises: Stay.',
  ]) {
    test('preserves every source character: $action', () {
      final parts = attributedActionParts(action)!;
      expect(parts.attribution + parts.lead + parts.remainder, action);
    });
  }
  test('highlights the phrase with its negation', () {
    final parts = attributedActionParts(
      'CFS advises: Do not use the bridge. Take the signed route.',
    )!;
    expect(parts.lead, 'Do not use the bridge.');
  });
  test('keeps a conditional clause with its instruction', () {
    final parts = attributedActionParts(
      'CFS advises: If you are east of the river, stay indoors.',
    )!;
    expect(parts.lead, '');
    expect(parts.remainder, 'If you are east of the river, stay indoors.');
  });
  test('does not reinterpret an unattributed suggestion', () {
    expect(
      attributedActionParts('Consider checking official updates.'),
      isNull,
    );
  });
}
