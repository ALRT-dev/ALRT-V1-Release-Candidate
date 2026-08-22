import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/profile/models/for_you_library.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';

/// The safety profile is only worth having if a ticked cohort actually
/// reaches the alert. These use the REAL category names the backend seeds,
/// because the bug this guards against was a silent one: every hazard
/// matched on its broad parent, so a flood got generic weather advice.
void main() {
  String? bucket({
    final String? category,
    final String? parent,
    final String? title,
  }) =>
      ForYouLibrary.bucketFor(
        categoryName: category,
        parentCategoryName: parent,
        title: title,
      );

  group('a specific hazard gets its own guidance', () {
    const parent = 'Weather & Environment';

    test('flood is not generic weather', () {
      expect(bucket(category: 'Flood', parent: parent), 'flood');
    });

    test('bushfire is not generic weather', () {
      expect(bucket(category: 'Bushfire', parent: parent), 'bushfire');
    });

    test('cyclone, earthquake and tsunami each match themselves', () {
      expect(bucket(category: 'Cyclone', parent: parent), 'cyclone');
      expect(bucket(category: 'Earthquake', parent: parent), 'earthquake');
      expect(bucket(category: 'Tsunami', parent: parent), 'tsunami');
    });

    test('heat, dust and pollen match themselves', () {
      expect(bucket(category: 'Extreme Heat', parent: parent), 'heatwave');
      expect(bucket(category: 'Dust Storm', parent: parent), 'dust_storm');
      expect(bucket(category: 'Pollen', parent: parent), 'pollen');
    });

    test('surf hazards match rough surf', () {
      expect(bucket(category: 'Hazardous Surf', parent: parent), 'rough_surf');
      expect(bucket(category: 'Coastal Hazard', parent: parent), 'rough_surf');
    });
  });

  group('falls back sensibly', () {
    test('an unmatched subcategory falls back to its parent', () {
      expect(
        bucket(category: 'Damaging Winds', parent: 'Weather & Environment'),
        'severe_weather',
      );
    });

    test('health categories reach guidance', () {
      expect(
        bucket(category: 'Disease Outbreak', parent: 'Health & Air'),
        'public_health',
      );
      expect(
        bucket(category: 'Air Quality Alert', parent: 'Health & Air'),
        'air_quality',
      );
    });

    test('the title still wins when it is more specific', () {
      expect(
        bucket(
          category: 'Other Fire',
          parent: 'Weather & Environment',
          title: 'Grass fire at Cranebrook',
        ),
        'grass_fire',
      );
    });
  });

  group('deliberately silent categories stay silent', () {
    test('traffic and security get no card, by design', () {
      expect(bucket(category: 'Crash', parent: 'Traffic & Transport'), isNull);
      expect(bucket(category: 'Crime', parent: 'Security & Crime'), isNull);
    });
  });

  group('the buckets people are matched into actually have rows', () {
    test('every bucket a real category resolves to exists in the library',
        () {
      const realCategories = <(String, String)>[
        ('Flood', 'Weather & Environment'),
        ('Bushfire', 'Weather & Environment'),
        ('Cyclone', 'Weather & Environment'),
        ('Earthquake', 'Weather & Environment'),
        ('Tsunami', 'Weather & Environment'),
        ('Extreme Heat', 'Weather & Environment'),
        ('Dust Storm', 'Weather & Environment'),
        ('Pollen', 'Weather & Environment'),
        ('Smoke', 'Health & Air'),
        ('Air Quality Alert', 'Health & Air'),
        ('Disease Outbreak', 'Health & Air'),
        ('Damaging Winds', 'Weather & Environment'),
      ];

      for (final (category, parent) in realCategories) {
        final resolved = bucket(category: category, parent: parent);
        expect(resolved, isNotNull, reason: '$category matched nothing');
        final rows = ForYouLibrary.rows[resolved];
        expect(
          rows,
          isNotNull,
          reason: '$category resolved to "$resolved", which has no rows',
        );
        expect(
          rows!.isNotEmpty,
          isTrue,
          reason: '$category resolved to an empty bucket',
        );
      }
    });

    test('a ticked cohort reaches guidance on a real hazard', () {
      final rows = ForYouLibrary.rows[bucket(
        category: 'Flood',
        parent: 'Weather & Environment',
      )]!;
      // The cohorts most likely to be ticked should have something to say
      // about a flood.
      for (final cohort in [
        SafetyCohort.older,
        SafetyCohort.kids,
        SafetyCohort.mobility,
      ]) {
        expect(
          rows.containsKey(cohort),
          isTrue,
          reason: 'no flood guidance for ${cohort.label}',
        );
      }
    });
  });
}
