import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phone builds meet the current Google Play target API requirement', () {
    // New phone apps and updates require API 36 from 31 August 2026.
    // https://developer.android.com/google/play/requirements/target-sdk
    // Keep this explicit so an SDK or build-tool update cannot lower it.
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final targetSdk = RegExp(r'^\s*targetSdk\s*=\s*(\d+)\b', multiLine: true)
        .allMatches(gradle)
        .map((match) => int.parse(match.group(1)!))
        .toList();

    expect(targetSdk, isNotEmpty, reason: 'Pin the phone target SDK explicitly.');
    for (final target in targetSdk) {
      expect(target, greaterThanOrEqualTo(36),
          reason: 'Every phone flavour must meet the API 36 submission floor.');
    }
  });
}
