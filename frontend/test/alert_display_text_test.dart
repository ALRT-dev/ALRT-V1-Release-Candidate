import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';

void main() {
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
