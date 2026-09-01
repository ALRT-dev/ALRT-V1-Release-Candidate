import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/repositories/hazard_repository.dart';

// Locks in the request-shaping half of the community "post an alert" TEST
// bypass: when a tester's build has USE_DUMMY_AI_FOR_REPORTS enabled, a
// created report's JSON must carry useDummyAi: true so the backend's
// reviewHazard useDummy branch can skip its AI call - and, just as
// importantly, an ordinary (non-TEST) submission's JSON must be left
// completely untouched. The other half of the gate (appFlavor == 'dev' &&
// dotenv) lives in useDummyAiForReports itself and isn't testable here -
// see that getter's own doc comment for why.
void main() {
  group('withDummyAiFlagIfEnabled', () {
    test('adds useDummyAi: true when enabled', () {
      final hazardJson = {
        'title': 'TEST — DO NOT USE',
        'categoryId': 'crime',
      };

      final result = withDummyAiFlagIfEnabled(hazardJson, enabled: true);

      expect(result['useDummyAi'], isTrue);
      expect(result['title'], 'TEST — DO NOT USE');
      expect(result['categoryId'], 'crime');
    });

    test('leaves the JSON completely unchanged when disabled', () {
      final hazardJson = {
        'title': 'A real community report',
        'categoryId': 'crash',
      };

      final result = withDummyAiFlagIfEnabled(hazardJson, enabled: false);

      expect(result.containsKey('useDummyAi'), isFalse);
      expect(result, hazardJson);
    });
  });
}
