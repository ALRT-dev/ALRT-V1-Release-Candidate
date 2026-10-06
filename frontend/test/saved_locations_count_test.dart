import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';

/// Profile's "Saved locations" row shows a real count of the user's
/// added locations. The auto-tracked "My Location" row (isOwnLocation)
/// is excluded — a user never chose to save that one, it is always
/// there — so the count only reflects places the user actually added.
LocationSubscription _subscription({required bool isOwnLocation}) {
  return LocationSubscription(
    northeastLat: 1,
    northeastLng: 1,
    southwestLat: -1,
    southwestLng: -1,
    isOwnLocation: isOwnLocation,
  );
}

void main() {
  group('Saved locations count', () {
    test('excludes the auto-tracked own-location row', () {
      final subscriptions = [
        _subscription(isOwnLocation: true),
        _subscription(isOwnLocation: false),
        _subscription(isOwnLocation: false),
      ];

      final count =
          subscriptions.where((location) => !location.isOwnLocation).length;

      expect(count, 2);
    });

    test('a user with only the own-location row has zero saved locations', () {
      final subscriptions = [_subscription(isOwnLocation: true)];

      final count =
          subscriptions.where((location) => !location.isOwnLocation).length;

      expect(count, 0);
    });

    test('an empty list is zero, not an error', () {
      final subscriptions = <LocationSubscription>[];

      final count =
          subscriptions.where((location) => !location.isOwnLocation).length;

      expect(count, 0);
    });
  });
}
