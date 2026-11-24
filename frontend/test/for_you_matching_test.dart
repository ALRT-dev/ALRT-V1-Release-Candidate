import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/profile/models/for_you_library.dart';
import 'package:hazard_app/features/profile/models/safety_cohort.dart';

/// The safety profile is only worth having if a ticked cohort actually
/// reaches the alert. These use the REAL category names the backend seeds,
/// because the bug this guards against was a silent one: every hazard
/// matched on its broad parent, so a flood got generic weather advice.
void main() {
  test('bundled bushfire and smoke profiles never invent evacuation advice', () {
    for (final bucket in ['bushfire', 'smoke']) {
      final lines = ForYouLibrary.rows[bucket]!;
      expect(lines.keys.toSet(), SafetyCohort.values.toSet());
      for (final line in lines.values) {
        expect(
          line,
          isNot(
            matches(
              RegExp(
                r'\b(leave|leaving|evacuat\w*|stay|staying|indoors|ember attacks)\b',
                caseSensitive: false,
              ),
            ),
          ),
        );
      }
    }
  });
  test('fuel leaks and alarms never borrow fuel shortage or fire guidance', () {
    expect(
      ForYouLibrary.bucketFor(
        title: 'Fuel Leak - BEDFORDALE',
        categoryName: 'Other',
      ),
      isNull,
    );
    expect(
      ForYouLibrary.bucketFor(
        title: 'Active Alarm - CLAREMONT',
        parentCategoryName: 'Weather & Environment',
      ),
      isNull,
    );
  });
  String? bucket({
    final String? category,
    final String? parent,
    final String? title,
  }) => ForYouLibrary.bucketFor(
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

  group('owner review, 16 Nov 2026', () {
    test('heat health and heat stress get heatwave rows', () {
      expect(bucket(category: 'Heat Health Alert', parent: 'Health & Air'), 'heatwave');
      expect(bucket(category: 'Heat Stress', parent: 'Health & Air'), 'heatwave');
    });
    test('the rows reworded on 16 Nov give no movement direction', () {
      final move = RegExp(
        r'\b(leave now|leave early|leaving early|leaving at|evacuat\w*|shelter in place|go indoors|going indoors|stay(ing)? indoors|moving to)\b',
        caseSensitive: false,
      );
      for (final bucket in ['chemical', 'structure_fire', 'tornado', 'tsunami', 'grass_fire', 'dust_storm']) {
        for (final line in ForYouLibrary.rows[bucket]!.values) {
          expect(line, isNot(matches(move)), reason: '$bucket: $line');
        }
      }
    });
    test('Other Fire gets neither bushfire nor storm rows', () {
      expect(bucket(category: 'Other Fire', parent: 'Weather & Environment'), isNull);
    });
    test('land slip and asthma reach their rows', () {
      expect(bucket(category: 'Land Slip', parent: 'Weather & Environment'), 'landslide');
      expect(bucket(category: 'Asthma Alert', parent: 'Health & Air'), 'pollen');
    });
  });

  group('deliberately silent categories stay silent', () {
    test('traffic and security get no card, by design', () {
      expect(bucket(category: 'Crash', parent: 'Traffic & Transport'), isNull);
      expect(bucket(category: 'Crime', parent: 'Security & Crime'), isNull);
    });
  });

  group('the buckets people are matched into actually have rows', () {
    test('every bucket a real category resolves to exists in the library', () {
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
      final rows =
          ForYouLibrary.rows[bucket(
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

  group('shark, crocodile, landslide and tornado have their own guidance', () {
    test('titles find the new hazards', () {
      expect(bucket(title: 'Shark sighting near beach'), 'shark');
      expect(bucket(title: 'Crocodile warning at boat ramp'), 'crocodile');
      expect(bucket(title: 'Landslide closes road'), 'landslide');
      expect(bucket(title: 'Tornado warning'), 'tornado');
    });

    test('every hazard has a line for all nine groups', () {
      for (final entry in ForYouLibrary.rows.entries) {
        expect(
          entry.value.keys.toSet(),
          SafetyCohort.values.toSet(),
          reason: '${entry.key} is missing a group',
        );
      }
    });

    test('no line uses the retired wording or a phone number', () {
      final banned = RegExp(
        r'advisable|all clear|\bnever\b|\balways\b|\bsafe(ly|st)?\b|\b000\b|\b112\b|\b911\b',
        caseSensitive: false,
      );
      for (final entry in ForYouLibrary.rows.entries) {
        for (final line in entry.value.entries) {
          expect(
            banned.hasMatch(line.value),
            isFalse,
            reason: '${entry.key} / ${line.key.name}: ${line.value}',
          );
        }
      }
    });
  });

  group('general lines (owner, 24 Nov 2026)', () {
    final allGeneral = <String, String>{
      for (final type in ForYouLibrary.generalRows.entries)
        for (final line in type.value.entries)
          '${type.key} / ${line.key.name}': line.value,
      for (final line in ForYouLibrary.anyAlertRows.entries)
        'any / ${line.key.name}': line.value,
    };

    test('every type and the any-alert set cover all nine groups', () {
      for (final entry in ForYouLibrary.generalRows.entries) {
        expect(entry.value.keys.toSet(), SafetyCohort.values.toSet(),
            reason: '${entry.key} is missing a group');
      }
      expect(ForYouLibrary.anyAlertRows.keys.toSet(),
          SafetyCohort.values.toSet());
    });

    test('general lines keep the library voice', () {
      final banned = RegExp(
        r'advisable|all clear|\bnever\b|\balways\b|\bsafe(ly|st)?\b|\b000\b|\b112\b|\b911\b|\bevacuat|\bleave\b|stay indoors|shelter|—',
        caseSensitive: false,
      );
      for (final entry in allGeneral.entries) {
        expect(banned.hasMatch(entry.value), isFalse,
            reason: '${entry.key}: ${entry.value}');
        expect(entry.value.endsWith('may help.'), isTrue,
            reason: '${entry.key} must end on what may help');
      }
    });

    test('alerts with no reviewed rows get their type', () {
      String? type({String? category, String? parent, String? title}) =>
          ForYouLibrary.generalTypeFor(
              categoryName: category, parentCategoryName: parent, title: title);
      expect(type(category: 'Other Fire', parent: 'Weather & Environment'), 'fire');
      expect(type(category: 'Vehicle Fire', parent: 'Transport & Traffic'), 'fire');
      expect(type(category: 'Crash', parent: 'Transport & Traffic'), 'transport');
      expect(type(category: 'Road Closure', parent: 'Transport & Traffic'), 'transport');
      expect(type(category: 'Crime', parent: 'Safety & Crime'), 'security');
      expect(type(category: 'Gas Leak', parent: 'Utilities & Infrastructure'), 'utilities');
      expect(type(category: 'Concert/Festival', parent: 'Community / Information'), 'events');
      expect(type(category: 'Something new'), isNull);
    });

    test('every ticked group always gets a line, even with no reviewed rows', () {
      for (final cohort in SafetyCohort.values) {
        for (final category in ['Crash', 'Gas Leak', 'Other Fire', 'Crime', 'Unknown']) {
          expect(
            ForYouLibrary.generalLineFor(cohort, categoryName: category),
            isNotEmpty,
          );
        }
      }
    });
  });
}
