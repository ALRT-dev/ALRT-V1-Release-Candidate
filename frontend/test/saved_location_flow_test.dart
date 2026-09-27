import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/map/models/alrt_location_bounds_model.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/providers/states/notifications_feed_provider_state.dart';
import 'package:hazard_app/features/search/providers/main_search_provider.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_socket_manager_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/socket_service.dart';
import 'package:hazard_app/features/shared/services/user_service.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/utils/saved_location_gate.dart';

/// The saved-location flow through the real provider, with the server and
/// the store faked (phone QA 2026-09-09, issue 7). One "own location"
/// row is always present and never counts.
class _FakeUserService extends UserService {
  const _FakeUserService(super.ref, this.store);
  final _Store store;

  @override
  Future<Either<List<LocationSubscription>, AppError>> getLocationSubscriptions() async {
    store.listFetches += 1;
    if (store.listFails) return const Failure(AppError(message: 'offline'));
    return Success(List.of(store.saved));
  }

  @override
  Future<Either<LocationSubscription, AppError>> subscribeToLocation({
    required double northeastLat,
    required double northeastLng,
    required double southwestLat,
    required double southwestLng,
    String? name,
    String? address,
  }) async {
    store.saveCalls += 1;
    if (store.serverRefuses) {
      return const Failure(AppError(message: 'Free accounts can save up to 1 locations. ALRT+ removes the limit.', code: '403'));
    }
    final s = LocationSubscription(
      id: 'sub-${store.saveCalls}',
      northeastLat: northeastLat,
      northeastLng: northeastLng,
      southwestLat: southwestLat,
      southwestLng: southwestLng,
      name: name,
    );
    store.saved.add(s);
    return Success(s);
  }
}

class _Store {
  final saved = <LocationSubscription>[
    const LocationSubscription(
      id: 'own', northeastLat: 1, northeastLng: 1, southwestLat: 0, southwestLng: 0, isOwnLocation: true, name: 'My Location',
    ),
  ];
  bool listFails = false;
  bool serverRefuses = false;
  int saveCalls = 0;
  int listFetches = 0;
}

class _QuietSocket extends SocketService {
  _QuietSocket(super.ref);
  @override
  Future<void> listenToEvent(event, onData) async {}
}

class _QuietFeed extends NotificationsFeedProvider {
  _QuietFeed(Ref ref) : super(ref: ref, state: NotificationsFeedProviderState());
  @override
  Future<void> getNotificationsFeedHazards() async {}
}

const _brisbane = AlrtLocation(
  latitude: -27.47,
  longitude: 153.02,
  name: 'Brisbane',
  bounds: AlrtLocationBounds(northeastLat: -27.3, northeastLng: 153.2, southwestLat: -27.6, southwestLng: 152.9),
);

({ProviderContainer container, _Store store, _PlusSwitch plus}) _setUp({bool isPlus = false}) {
  final store = _Store();
  final plus = _PlusSwitch(isPlus);
  final container = ProviderContainer(
    overrides: [
      providerOfUserService.overrideWith((ref) => _FakeUserService(ref, store)),
      providerOfSocketService.overrideWith(_QuietSocket.new),
      providerOfNotificationsFeed.overrideWith((ref) => _QuietFeed(ref)),
      providerOfAlrtPlus.overrideWith((ref) async => plus.value),
    ],
  );
  container.listen(providerOfHazardSocketManager, (_, __) {});
  return (container: container, store: store, plus: plus);
}

class _PlusSwitch {
  _PlusSwitch(this.value);
  bool value;
}

Future<SaveLocationOutcome> _tapSave(ProviderContainer c) async {
  final n = c.read(providerOfMainSearch.notifier);
  n.updateSearchedLocation(_brisbane);
  return n.toggleSubscription();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('1. the first saved location is free; the second reaches the paywall on a free account', () async {
    final (:container, :store, :plus) = _setUp();
    expect(await _tapSave(container), isA<SaveLocationSaved>());
    expect(store.saveCalls, 1);
    container.read(providerOfMainSearch.notifier).updateSubscriptionId(null);
    final second = await _tapSave(container);
    expect(second, isA<SaveLocationNeedsPlus>());
    expect((second as SaveLocationNeedsPlus).fromServer, isFalse);
    expect(store.saveCalls, 1, reason: 'nothing is saved before ALRT+');
    container.dispose();
  });

  test('2. an existing subscriber saves a second location with no paywall', () async {
    final (:container, :store, :plus) = _setUp(isPlus: true);
    store.saved.add(const LocationSubscription(id: 's1', northeastLat: 2, northeastLng: 2, southwestLat: 1, southwestLng: 1, name: 'Home'));
    final outcome = await _tapSave(container);
    expect(outcome, isA<SaveLocationSaved>());
    expect((outcome as SaveLocationSaved).name, 'Brisbane');
    expect(store.saveCalls, 1);
    container.dispose();
  });

  test('3. a successful purchase unlocks the pending save without a restart', () async {
    final (:container, :store, :plus) = _setUp();
    store.saved.add(const LocationSubscription(id: 's1', northeastLat: 2, northeastLng: 2, southwestLat: 1, southwestLng: 1, name: 'Home'));
    expect(await _tapSave(container), isA<SaveLocationNeedsPlus>());
    // The paywall finished: the entitlement provider is refreshed, the
    // same handler tries the save again.
    plus.value = true;
    container.invalidate(providerOfAlrtPlus);
    final again = await container.read(providerOfMainSearch.notifier).toggleSubscription();
    expect(again, isA<SaveLocationSaved>());
    expect(store.saveCalls, 1);
    container.dispose();
  });

  test('4. a cancelled or failed purchase leaves the account free and saves nothing', () async {
    final (:container, :store, :plus) = _setUp();
    store.saved.add(const LocationSubscription(id: 's1', northeastLat: 2, northeastLng: 2, southwestLat: 1, southwestLng: 1, name: 'Home'));
    expect(await _tapSave(container), isA<SaveLocationNeedsPlus>());
    // Nothing changed at the store; a retry still needs ALRT+.
    container.invalidate(providerOfAlrtPlus);
    expect(await container.read(providerOfMainSearch.notifier).toggleSubscription(), isA<SaveLocationNeedsPlus>());
    expect(store.saveCalls, 0);
    container.dispose();
  });

  test('5. a server refusal (billing enforced) is reported as needing ALRT+, not swallowed', () async {
    final (:container, :store, :plus) = _setUp();
    store.serverRefuses = true;
    final outcome = await _tapSave(container);
    expect(outcome, isA<SaveLocationNeedsPlus>());
    expect((outcome as SaveLocationNeedsPlus).fromServer, isTrue);
    container.dispose();
  });

  test('the saved list is fetched before counting; an unreachable list never saves blindly', () async {
    final (:container, :store, :plus) = _setUp();
    store.listFails = true;
    final outcome = await _tapSave(container);
    expect(outcome, isA<SaveLocationCouldNotCheck>());
    expect(store.saveCalls, 0);
    container.dispose();
  });
}
