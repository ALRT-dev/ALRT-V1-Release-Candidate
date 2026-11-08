import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_source_model.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';

void main() {
  test('main category label uses the seven stable parent IDs, not incident type', () {
    const smoke = Hazard(category: HazardCategory(id: 'airQualityAlert', name: 'Air Quality Alert', parentId: 'healthAndAir'));
    const fire = Hazard(category: HazardCategory(id: 'bushfire', name: 'Bushfire', parentId: 'weatherAndEnvironment'));
    expect(smoke.displayMainCategoryName, 'Health & Air');
    expect(fire.displayMainCategoryName, 'Weather & Environment');
    expect(const Hazard(category: HazardCategory(id: 'securityAndCrime', name: 'Security & Crime')).displayMainCategoryName, 'Safety & Crime');
    expect(const Hazard(category: HazardCategory(id: 'other', name: 'Other')).displayMainCategoryName, 'Other');
  });
  test('specific DFES incident type is not lost behind Other', () {
    const alarm = Hazard(
      source: HazardSource(id: 'waDfes'),
      title: 'Active Alarm - CLAREMONT',
      category: HazardCategory(id: 'other', name: 'Other'),
    );
    expect(alarm.displayCategoryName, 'Active alarm');
    expect(alarm.displayTitle, 'Active alarm in Claremont');
    expect(const Hazard(title: 'Fuel Leak - BEDFORDALE').displayTitle,
        'Fuel leak in Bedfordale');
    expect(alarm.category?.id, 'other');
  });
  test('plain terms also normalises Other Fire from the source title', () {
    expect(
      AlertCardStyle.plainTermsOf(
        isOfficial: true,
        isAws: false,
        sourceName: 'DFES',
        categoryName: 'Other Fire',
        title: 'Other Fire - BASSENDEAN',
        hasAdvice: false,
      ),
      'DFES has reported a fire in Bassendean.',
    );
  });
  test('agency dash titles are calm and generic Other Fire becomes Fire', () {
    expect(
      const Hazard(title: 'Bushfire - MELALEUCA').displayTitle,
      'Bushfire in Melaleuca',
    );
    expect(
      const Hazard(title: 'Other Fire - BASSENDEAN').displayTitle,
      'Fire in Bassendean',
    );
    expect(
      const Hazard(title: 'Road Crash – WARWICK').displayTitle,
      'Road crash in Warwick',
    );
    expect(
      const Hazard(title: 'Fire - McLaren Vale').displayTitle,
      'Fire in McLaren Vale',
    );
    expect(
      const Hazard(
        category: HazardCategory(id: 'otherFire', name: 'Other Fire'),
      ).displayCategoryName,
      'Fire',
    );
  });
  test('original source and community titles remain intact', () {
    const official = Hazard(title: 'Bushfire - MELALEUCA');
    expect(official.title, 'Bushfire - MELALEUCA');
    expect(
      const Hazard(
        title: 'Smoke at ACME - Gate B',
        reportedBy: AppUser(id: 'me'),
      ).displayTitle,
      'Smoke at ACME - Gate B',
    );
    expect(
      const Hazard(title: 'DFES advises: Leave now').displayTitle,
      'DFES advises: Leave now',
    );
  });
}
