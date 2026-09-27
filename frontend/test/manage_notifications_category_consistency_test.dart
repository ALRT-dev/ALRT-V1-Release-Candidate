import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/notification/providers/manage_notifications_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/manage_push_notifications_list.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/search/models/hazard_search_params.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/app_user_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/get_hazards_with_subscription_id_reponse.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/models/view_hazard_response_model.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/providers/repository_providers.dart';
import 'package:hazard_app/features/shared/repositories/hazard_repository.dart';
import 'package:hazard_app/features/shared/repositories/user_repository.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:hazard_app/features/shared/views/widgets/category_filter_chip.dart';
import 'package:hazard_app/features/shared/views/widgets/filter_widgets/hazard_filters_bottomsheet_content.dart';

/// A [HazardRepository] that only serves the parent-category list this test
/// controls, so the exact same category set that real category data would
/// carry (name, colour, id, ordering) is fed to both screens under test.
/// Every other member throws: nothing here should ever need them.
class _FakeHazardRepository implements HazardRepository {
  _FakeHazardRepository(this.categories);

  final List<HazardCategory> categories;

  @override
  Future<Either<List<HazardCategory>, AppError>>
  getAllParentHazardCategories() async => Success(categories);

  @override
  Future<Either<List<HazardCategory>, AppError>> getAllHazardCategories() =>
      throw UnimplementedError();

  @override
  Future<Either<List<HazardCategory>, AppError>> getAllSubHazardCategories() =>
      throw UnimplementedError();

  @override
  Future<Either<List<Hazard>, AppError>> getHazards({
    required final HazardSearchParams searchParams,
    final CancelToken? cancelToken,
  }) => throw UnimplementedError();

  @override
  Future<Either<GetHazardsWithSubscriptionIdResponse, AppError>>
  getGetHazardsWithSubscriptionId({
    required final HazardSearchParams searchParams,
  }) => throw UnimplementedError();

  @override
  Future<Either<Hazard, AppError>> createHazardReport({
    required final Hazard hazard,
    final List<AlrtMedia>? mediaFiles,
  }) => throw UnimplementedError();

  @override
  Future<Either<Hazard, AppError>> updateHazardReport({
    required final Hazard hazard,
    final List<AlrtMedia>? mediaFiles,
    final List<String>? removedMediaIds,
  }) => throw UnimplementedError();

  @override
  Future<Either<void, AppError>> deleteHazard({
    required final String hazardId,
  }) => throw UnimplementedError();

  @override
  Future<Either<void, AppError>> voteHazard({
    required final String hazardId,
    required final HazardVoteType voteType,
  }) => throw UnimplementedError();

  @override
  Future<Either<ViewHazardResponse, AppError>> viewHazard({
    required final String hazardId,
  }) => throw UnimplementedError();
}

/// A [UserRepository] whose push-notification settings are fully
/// controlled by the test, and which records every value the code under
/// test tries to persist - so a test can assert not just what renders, but
/// whether (and what) it saved.
class _FakeUserRepository implements UserRepository {
  _FakeUserRepository(this._settings);

  PushNotificationSettings _settings;
  final List<PushNotificationSettings> savedSettings = [];

  @override
  Future<Either<PushNotificationSettings, AppError>>
  getPushNotificationSettings() async => Success(_settings);

  @override
  Future<Either<PushNotificationSettings, AppError>>
  updatePushNotificationSettings({
    required final PushNotificationSettings pushNotificationSettings,
  }) async {
    _settings = pushNotificationSettings;
    savedSettings.add(pushNotificationSettings);
    return Success(pushNotificationSettings);
  }

  @override
  Future<Either<AppUser, AppError>> getCurrentUser() =>
      throw UnimplementedError();

  @override
  Future<Either<AppUser, AppError>> updateCurrentUser({
    required final AppUser user,
    final CancelToken? cancelToken,
  }) => throw UnimplementedError();

  @override
  Future<Either<AppUser, AppError>> updateUserProfilePicture({
    required final AlrtMedia profilePicture,
    void Function(int, int)? onSendProgress,
  }) => throw UnimplementedError();

  @override
  Future<Either<LocationSubscription, AppError>> subscribeToLocation({
    required final double northeastLat,
    required final double northeastLng,
    required final double southwestLat,
    required final double southwestLng,
    final String? name,
    final String? address,
  }) => throw UnimplementedError();

  @override
  Future<Either<void, AppError>> unsubscribeFromLocation({
    required final String subscriptionId,
  }) => throw UnimplementedError();

  @override
  Future<Either<List<LocationSubscription>, AppError>>
  getLocationSubscriptions() => throw UnimplementedError();

  @override
  Future<Either<LocationSubscription, AppError>> updateOwnLocationSubscription({
    required final double latitude,
    required final double longitude,
    final String? locationName,
  }) => throw UnimplementedError();

  @override
  Future<Either<LocationSubscription, AppError>>
  updateOwnLocationSubscriptionRadius({
    required final double radiusKm,
  }) => throw UnimplementedError();

  @override
  Future<Either<void, AppError>> deleteAccount() => throw UnimplementedError();

  @override
  Future<Either<void, AppError>> cancelAccountDeletion() =>
      throw UnimplementedError();
}

List<HazardCategory> _sampleCategories() => const [
  HazardCategory(
    id: 'weatherAndEnvironment',
    name: 'Weather & Environment',
    color: Color(0xFF2FA6FF),
  ),
  HazardCategory(
    id: 'healthAndAir',
    name: 'Health & Air',
    color: Color(0xFFFF7E29),
  ),
  HazardCategory(
    id: 'securityAndCrime',
    name: 'Security & Crime',
    color: Color(0xFFD946EF),
  ),
  HazardCategory(
    id: 'trafficAndTransport',
    name: 'Traffic & Transport',
    color: Color(0xFF00CC96),
  ),
  HazardCategory(
    id: 'utilitiesAndInfrastructure',
    name: 'Utilities & Infrastructure',
    color: Color(0xFFFFB300),
  ),
  HazardCategory(
    id: 'communityAndInfo',
    name: 'Community & Info',
    color: Color(0xFFC233DB),
  ),
];

/// The ordered (name, colour, selected) tuple every [CategoryFilterChip]
/// renders - the "actual rendered data/mapping" this suite compares,
/// rather than trusting that two call sites reading the same provider
/// necessarily render the same thing.
List<(String, Color, bool)> _renderedChips(final WidgetTester tester) {
  return tester
      .widgetList<CategoryFilterChip>(find.byType(CategoryFilterChip))
      .map(
        (final chip) => (
          chip.category.name ?? '',
          categoryChipColor(chip.category),
          chip.isSelected,
        ),
      )
      .toList();
}

Widget _wrap(final Widget child, {required final ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  group('Notification Categories vs. the ALRT feed filter', () {
    testWidgets(
      'render the identical categories - same names, colours and order',
      (tester) async {
        final categories = _sampleCategories();
        final container = ProviderContainer(
          overrides: [
            providerOfHazardRepository.overrideWithValue(
              _FakeHazardRepository(categories),
            ),
            providerOfUserRepository.overrideWithValue(
              _FakeUserRepository(
                PushNotificationSettings(
                  subscribedCategoryIds: {'weatherAndEnvironment'},
                ),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(providerOfMainCategories.notifier)
            .getAllMainHazardCategories();

        // The Notification Categories tab.
        await tester.pumpWidget(
          _wrap(const ManagePushNotificationsList(), container: container),
        );
        await tester.pumpAndSettle();
        final notificationsChips = _renderedChips(tester);

        // The ALRT feed's own filter sheet (map / notifications-feed
        // "Filters" button) - the actual screen users filter alerts from.
        await tester.pumpWidget(
          _wrap(
            HazardFiltersBottomsheetContent(
              filtersKey: 'consistency-test-feed-filters',
            ),
            container: container,
          ),
        );
        await tester.pumpAndSettle();
        final feedChips = _renderedChips(tester);

        expect(
          notificationsChips.map((c) => (c.$1, c.$2)),
          feedChips.map((c) => (c.$1, c.$2)),
          reason:
              'every category must show the same name and colour, in the '
              'same order, on both screens',
        );
        expect(
          notificationsChips.map((c) => c.$1),
          categories.map((c) => c.name),
          reason:
              'and that shared list must be the real category list, '
              'not a hardcoded subset',
        );
      },
    );

    testWidgets(
      'a never-customised subscription defaults to every category, like '
      'the feed filter does, and persists that default',
      (tester) async {
        final categories = _sampleCategories();
        final userRepository = _FakeUserRepository(
          const PushNotificationSettings(), // subscribedCategoryIds: {}
        );
        final container = ProviderContainer(
          overrides: [
            providerOfHazardRepository.overrideWithValue(
              _FakeHazardRepository(categories),
            ),
            providerOfUserRepository.overrideWithValue(userRepository),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(providerOfMainCategories.notifier)
            .getAllMainHazardCategories();

        await tester.pumpWidget(
          _wrap(const ManagePushNotificationsList(), container: container),
        );
        await tester.pumpAndSettle();

        final chips = _renderedChips(tester);
        expect(chips, hasLength(categories.length));
        expect(
          chips.every((c) => c.$3),
          isTrue,
          reason:
              'every chip should read as selected - matching the feed '
              'filter, which defaults an empty selection to "everything"',
        );
        expect(
          userRepository.savedSettings,
          isNotEmpty,
          reason:
              'the default must be persisted, not just displayed - an '
              'unpersisted empty subscription still receives nothing '
              'server-side',
        );
        expect(
          userRepository.savedSettings.last.subscribedCategoryIds,
          categories.map((c) => c.id).toSet(),
        );
      },
    );

    testWidgets(
      'an already-customised (partial) subscription is left exactly as '
      'saved, never overwritten',
      (tester) async {
        final categories = _sampleCategories();
        final userRepository = _FakeUserRepository(
          const PushNotificationSettings(
            subscribedCategoryIds: {'healthAndAir', 'securityAndCrime'},
          ),
        );
        final container = ProviderContainer(
          overrides: [
            providerOfHazardRepository.overrideWithValue(
              _FakeHazardRepository(categories),
            ),
            providerOfUserRepository.overrideWithValue(userRepository),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(providerOfMainCategories.notifier)
            .getAllMainHazardCategories();

        await tester.pumpWidget(
          _wrap(const ManagePushNotificationsList(), container: container),
        );
        await tester.pumpAndSettle();

        final chips = _renderedChips(tester);
        final selectedNames = chips.where((c) => c.$3).map((c) => c.$1).toSet();
        expect(selectedNames, {'Health & Air', 'Security & Crime'});
        expect(
          userRepository.savedSettings,
          isEmpty,
          reason:
              'a real, already-saved preference must never trigger an '
              'automatic overwrite',
        );
      },
    );

    testWidgets(
      'a genuinely empty subscription (deliberately unsubscribed from '
      'everything) is only defaulted once, not re-forced back to "all" on '
      'every category-list refresh',
      (tester) async {
        final categories = _sampleCategories();
        final userRepository = _FakeUserRepository(
          const PushNotificationSettings(),
        );
        final container = ProviderContainer(
          overrides: [
            providerOfHazardRepository.overrideWithValue(
              _FakeHazardRepository(categories),
            ),
            providerOfUserRepository.overrideWithValue(userRepository),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(providerOfMainCategories.notifier)
            .getAllMainHazardCategories();

        await tester.pumpWidget(
          _wrap(const ManagePushNotificationsList(), container: container),
        );
        await tester.pumpAndSettle();
        expect(userRepository.savedSettings, hasLength(1));

        // The user deliberately turns every category back off again - this
        // itself is one legitimate, deliberate save of an empty set.
        userRepository.savedSettings.clear();
        container
            .read(providerOfManageNotifications.notifier)
            .updateSelectedCategories({});
        await tester.pumpAndSettle();
        expect(userRepository.savedSettings, hasLength(1));
        expect(
          userRepository.savedSettings.single.subscribedCategoryIds,
          isEmpty,
        );

        // The category list refreshing again (e.g. re-opening the screen)
        // must not silently re-force everything back on: no further save
        // should happen beyond the deliberate one above.
        await container
            .read(providerOfMainCategories.notifier)
            .getAllMainHazardCategories();
        await tester.pumpAndSettle();

        expect(
          userRepository.savedSettings,
          hasLength(1),
          reason:
              'the one-time default must not fire again and clobber a '
              'deliberate later change back to empty',
        );
      },
    );
  });
}
