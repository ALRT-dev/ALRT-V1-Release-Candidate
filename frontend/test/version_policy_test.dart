import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/app_update/providers/force_update_provider.dart';
import 'package:hazard_app/features/app_update/utils/version_policy.dart';
import 'package:hazard_app/features/app_update/views/force_update_screen.dart';

/// GET /api/app/version-policy: a build below its platform's minimum is
/// stopped on "Please update ALRT"; anything unreadable never blocks.

bool _required(
  final String version,
  final String build, {
  final String? minVersion,
  final int? minBuild,
}) => isUpdateRequired(
  version: version,
  buildNumber: build,
  policy: PlatformVersionPolicy(minVersion: minVersion, minBuild: minBuild),
);

void main() {
  group('semantic version compare', () {
    test('x.y.z compares number by number, not as text', () {
      expect(compareSemver('1.2.3', '1.2.3'), 0);
      expect(compareSemver('1.2.3', '1.2.4')! < 0, isTrue);
      expect(compareSemver('1.10.0', '1.9.9')! > 0, isTrue);
      expect(compareSemver('2.0.0', '1.99.99')! > 0, isTrue);
    });

    test('short versions and suffixes are read sensibly', () {
      expect(compareSemver('1.2', '1.2.0'), 0);
      expect(compareSemver('1', '1.0.0'), 0);
      expect(compareSemver('1.2.3+45', '1.2.3'), 0);
      expect(compareSemver('1.2.3-beta', '1.2.3'), 0);
    });

    test('not a version: no answer', () {
      expect(compareSemver('abc', '1.0.0'), isNull);
      expect(compareSemver('1.0.0', ''), isNull);
      expect(parseSemver('1.2.3.4'), isNull);
    });
  });

  group('isUpdateRequired', () {
    test('below the minimum version: update', () {
      expect(_required('1.3.9', '60', minVersion: '1.4.0'), isTrue);
    });

    test('above the minimum version: the build number is not looked at', () {
      expect(
        _required('1.5.0', '1', minVersion: '1.4.0', minBuild: 99),
        isFalse,
      );
    });

    test('same version: the build number decides', () {
      expect(
        _required('1.4.0', '51', minVersion: '1.4.0', minBuild: 52),
        isTrue,
      );
      expect(
        _required('1.4.0', '52', minVersion: '1.4.0', minBuild: 52),
        isFalse,
      );
      expect(_required('1.4.0', '1', minVersion: '1.4.0'), isFalse);
    });

    test('build only', () {
      expect(_required('9.9.9', '40', minBuild: 41), isTrue);
      expect(_required('0.0.1', '41', minBuild: 41), isFalse);
    });

    test('no minimum, or anything unreadable: never blocks', () {
      expect(_required('1.0.0', '1'), isFalse);
      expect(_required('weird', '1', minVersion: '2.0.0'), isFalse);
      expect(_required('1.0.0', 'x', minBuild: 99), isFalse);
    });

    test('the response is read per platform; nulls mean no minimum', () {
      final json = {
        'ios': {'minVersion': '1.4.0', 'minBuild': 52, 'storeUrl': 'https://a'},
        'android': {'minVersion': null, 'minBuild': null, 'storeUrl': null},
      };
      final ios = policyForPlatform(json, isIOS: true);
      expect(ios.minVersion, '1.4.0');
      expect(ios.minBuild, 52);
      expect(ios.storeUrl, 'https://a');
      final android = policyForPlatform(json, isIOS: false);
      expect(android.minVersion, isNull);
      expect(android.minBuild, isNull);
      expect(policyForPlatform('nope', isIOS: true).minVersion, isNull);
    });
  });

  group('the check at start', () {
    ProviderContainer container({
      required final Future<Object?> Function() source,
      final bool? isIOS = false,
      final String version = '1.3.0',
      final String build = '40',
    }) {
      final c = ProviderContainer(
        overrides: [
          providerOfVersionPolicySource.overrideWithValue(source),
          providerOfVersionPolicyPlatform.overrideWithValue(isIOS),
          providerOfInstalledVersion.overrideWithValue(
            () async => (version: version, buildNumber: build),
          ),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('below the minimum: the store page to update from', () async {
      final c = container(
        source: () async => {
          'android': {
            'minVersion': '1.4.0',
            'minBuild': null,
            'storeUrl': 'https://play.google.com/store/apps/details?id=x',
          },
        },
      );
      await c.read(providerOfForceUpdate.notifier).check();
      expect(
        c.read(providerOfForceUpdate)?.storeUrl,
        'https://play.google.com/store/apps/details?id=x',
      );
    });

    test('a failed or missing policy is ignored', () async {
      final failing = container(source: () async => throw Exception('500'));
      await failing.read(providerOfForceUpdate.notifier).check();
      expect(failing.read(providerOfForceUpdate), isNull);

      final empty = container(source: () async => null);
      await empty.read(providerOfForceUpdate.notifier).check();
      expect(empty.read(providerOfForceUpdate), isNull);
    });

    test('platforms without a store minimum are never checked', () async {
      var asked = false;
      final c = container(
        isIOS: null,
        source: () async {
          asked = true;
          return null;
        },
      );
      await c.read(providerOfForceUpdate.notifier).check();
      expect(asked, isFalse);
      expect(c.read(providerOfForceUpdate), isNull);
    });
  });

  testWidgets('Please update ALRT: no way back, one button to the store', (
    tester,
  ) async {
    Uri? opened;
    await tester.pumpWidget(
      MaterialApp(
        home: ForceUpdateScreen(
          storeUrl: 'https://apps.apple.com/app/id1',
          openUrl: (uri) async {
            opened = uri;
            return true;
          },
        ),
      ),
    );
    expect(find.text('Please update ALRT'), findsOneWidget);
    final scope = tester.widget<PopScope>(find.byType(PopScope));
    expect(scope.canPop, isFalse);
    await tester.tap(find.byKey(const Key('force-update-open-store')));
    await tester.pump();
    expect(opened, Uri.parse('https://apps.apple.com/app/id1'));
  });
}
