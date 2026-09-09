import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/map/views/screens/map_screen.dart';
import 'package:hazard_app/features/notification/views/widgets/notifications_appbar.dart';
import 'package:hazard_app/features/search/views/widgets/hazard_search_appbar.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_filters_provider_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final providerOfHazardFiltersForMap = providerOfHazardFilters(
  MapScreen.filtersKey,
);
final providerOfHazardFiltersForSearch = providerOfHazardFilters(
  HazardSearchAppBar.filtersKey,
);
final providerOfHazardFiltersForNotifications = providerOfHazardFilters(
  NotificationsAppBar.filtersKey,
);

final providerOfHazardFilters = StateNotifierProvider.autoDispose
    .family<HazardFiltersProvider, HazardFiltersProviderState, String>(
      (ref, id) => HazardFiltersProvider(
        ref: ref,
        state: const HazardFiltersProviderState(),
        storageKey: id,
      ),
    );

class HazardFiltersProvider extends StateNotifier<HazardFiltersProviderState> {
  HazardFiltersProvider({
    required final Ref ref,
    required final HazardFiltersProviderState state,
    this.storageKey,
  }) : _ref = ref,
       super(state) {
    _onInit();
  }

  final Ref _ref;

  /// SharedPreferences key this instance saves to, or null for a
  /// transient instance (tests, screenshots).
  final String? storageKey;

  /// True until the saved choice has been read back. Nothing is written
  /// before that: the constructor's own category seeding used to persist
  /// the defaults over the saved value before restore could read it.
  bool _restoring = true;
  bool _changedWhileRestoring = false;

  /// True while the provider itself seeds the category lists from the
  /// server's main categories; that is not a user choice.
  bool _seeding = false;

  /// Every change is written straight to the device, so the choice
  /// survives closing the sheet, switching tabs and restarting the app.
  @override
  set state(final HazardFiltersProviderState value) {
    super.state = value;
    if (_restoring) {
      if (!_seeding) _changedWhileRestoring = true;
    } else if (!_seeding) {
      unawaited(_persist());
    }
  }

  /// Restore is over (with or without a saved value): from now on every
  /// change is written, and a change made while restoring is written now.
  void _restoreDone() {
    _restoring = false;
    if (_changedWhileRestoring) {
      _changedWhileRestoring = false;
      unawaited(_persist());
    }
  }

  static String prefsKeyFor(final String id) => 'hazard_filters.$id';

  Future<void> _persist() async {
    final key = storageKey;
    if (key == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKeyFor(key), jsonEncode(state.toStorageJson()));
    } catch (_) {
      // A failed save only costs the memory of this choice next launch.
    }
  }

  Future<void> _restore() async {
    final key = storageKey;
    if (key == null) {
      _restoreDone();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(prefsKeyFor(key));
      if (raw == null) {
        _restoreDone();
        return;
      }
      final saved = HazardFiltersProviderState.fromStorageJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (!mounted) return;
      // A choice made before the saved one was read wins over the saved
      // one: the user just made it.
      if (_changedWhileRestoring) {
        _restoreDone();
        return;
      }
      state = state.copyWith(
        awsEmergency: saved.awsEmergency,
        awsWatchAndAct: saved.awsWatchAndAct,
        awsAdvice: saved.awsAdvice,
        officialNonAws: saved.officialNonAws,
        userReported: saved.userReported,
        globalHumanitarian: saved.globalHumanitarian,
        alrtIntel: saved.alrtIntel,
        // A saved category choice is honoured only for categories that
        // still exist; an empty saved set means "all", as it always has.
        selectedCategoryIds: saved.selectedCategoryIds.isEmpty || state.allCategoryIds.isEmpty
            ? state.selectedCategoryIds
            : saved.selectedCategoryIds.intersection(state.allCategoryIds),
        selectedLocationIds: saved.selectedLocationIds,
      );
      _restoreDone();
    } catch (_) {
      _restoreDone();
    }
  }

  void _onInit() {
    // Initialize selected categories with all main categories if none are selected.
    final allMainCategories = _ref
        .read(providerOfMainCategories)
        .mainCategories;
    _seed(allMainCategories.map((e) => e.id).toSet());
    unawaited(_restore());
    _ref.listen(
      providerOfMainCategories.select(
        (value) => value.mainCategories,
      ),
      (previous, next) {
        if (previous != next && state.selectedCategoryIds.isEmpty) {
          _seed(next.map((e) => e.id).toSet());
        }
      },
    );
  }

  void _seed(final Set<String> ids) {
    _seeding = true;
    updateAllCategories(ids);
    updateSelectedCategories(ids);
    _seeding = false;
  }

  /// Updates the AWS Emergency filter state.
  void updateAwsEmergency(bool value) {
    state = state.copyWith(awsEmergency: value);
  }

  /// Updates the AWS Watch and Act filter state.
  void updateAwsWatchAndAct(bool value) {
    state = state.copyWith(awsWatchAndAct: value);
  }

  /// Updates the AWS Advice filter state.
  void updateAwsAdvice(bool value) {
    state = state.copyWith(awsAdvice: value);
  }

  /// Updates the Official Non-AWS filter state.
  void updateOfficialNonAws(bool value) {
    state = state.copyWith(officialNonAws: value);
  }

  /// Updates the User Reported filter state.
  void updateUserReported(bool value) {
    state = state.copyWith(userReported: value);
  }

  /// Updates the global humanitarian filter state.
  void updateGlobalHumanitarian(bool value) {
    state = state.copyWith(globalHumanitarian: value);
  }

  /// Updates the ALRT Intel filter state.
  void updateAlrtIntel(bool value) {
    state = state.copyWith(alrtIntel: value);
  }

  /// Updates all available category IDs.
  void updateAllCategories(Set<String> categoryIds) {
    state = state.copyWith(allCategoryIds: categoryIds);
  }

  /// Updates the selected category IDs.
  void updateSelectedCategories(Set<String> categoryIds) {
    state = state.copyWith(selectedCategoryIds: categoryIds);
  }

  /// Adds a category ID to the selected categories.
  void addSelectedCategory(String categoryId) {
    final updatedSet = Set<String>.from(state.selectedCategoryIds);
    updatedSet.add(categoryId);
    updateSelectedCategories(updatedSet);
  }

  /// Removes a category ID from the selected categories.
  void removeSelectedCategory(String categoryId) {
    final updatedSet = Set<String>.from(state.selectedCategoryIds);
    updatedSet.remove(categoryId);
    updateSelectedCategories(updatedSet);
  }

  /// Toggles a category selection.
  void toggleCategory(String categoryId) {
    if (state.selectedCategoryIds.contains(categoryId)) {
      removeSelectedCategory(categoryId);
    } else {
      addSelectedCategory(categoryId);
    }
  }

  /// Updates the selected location subscription IDs.
  void updateSelectedLocationIds(Set<String> locationIds) {
    state = state.copyWith(selectedLocationIds: locationIds);
  }

  /// Adds a location subscription ID to the selected location subscription IDs.
  void addSelectedLocationId(String locationId) {
    final updatedSet = Set<String>.from(state.selectedLocationIds);
    updatedSet.add(locationId);
    updateSelectedLocationIds(updatedSet);
  }

  /// Removes a location subscription ID from the selected location subscription IDs.
  void removeSelectedLocationId(String locationId) {
    final updatedSet = Set<String>.from(state.selectedLocationIds);
    updatedSet.remove(locationId);
    updateSelectedLocationIds(updatedSet);
  }

  /// Toggles a location subscription ID selection.
  void toggleLocationId(String locationId) {
    if (state.selectedLocationIds.contains(locationId)) {
      removeSelectedLocationId(locationId);
    } else {
      // Only allow single selection for location subscriptions for now.
      updateSelectedLocationIds({locationId});
    }
  }

  /// Resets all filters to their initial values.
  void resetAllFilters() {
    final allCategoryIds = state.allCategoryIds;
    state = HazardFiltersProviderState(
      allCategoryIds: allCategoryIds,
      selectedCategoryIds: allCategoryIds,
    );
  }
}
