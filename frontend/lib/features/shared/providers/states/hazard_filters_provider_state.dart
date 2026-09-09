import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

part 'hazard_filters_provider_state.freezed.dart';

/// The map and the ALRT feed share ONE set of alert filters, persisted on
/// the device, so what you hide on the map is hidden in the feed and stays
/// hidden after a restart (phone QA 2026-09-09). Search keeps its own key.
const kSharedAlertFiltersKey = 'SharedAlertFilters';

@freezed
abstract class HazardFiltersProviderState with _$HazardFiltersProviderState {
  const HazardFiltersProviderState._();

  const factory HazardFiltersProviderState({
    /// Whether AWS Emergency level "Emergency" is selected.
    @Default(true) final bool awsEmergency,

    /// Whether AWS Emergency level "Watch and Act" is selected.
    @Default(true) final bool awsWatchAndAct,

    /// Whether AWS Emergency level "Advice" is selected.
    @Default(true) final bool awsAdvice,

    /// Whether Official Non-AWS sources are selected.
    @Default(true) final bool officialNonAws,

    /// Whether User Reported sources are selected.
    @Default(true) final bool userReported,

    /// Whether global humanitarian feeds (the rounded square) are shown.
    @Default(true) final bool globalHumanitarian,

    /// Whether ALRT Intel (the shield) is shown.
    @Default(true) final bool alrtIntel,

    /// All available category IDs.
    @Default(<String>{}) final Set<String> allCategoryIds,

    /// Selected category IDs.
    @Default(<String>{}) final Set<String> selectedCategoryIds,

    /// Selected location subscription IDs.
    @Default(<String>{}) final Set<String> selectedLocationIds,
  }) = _HazardFiltersProviderState;

  /// What is saved on the device: the switches and the chosen categories
  /// and locations. `allCategoryIds` is not saved; it comes from the
  /// server on every launch.
  Map<String, dynamic> toStorageJson() => {
        'awsEmergency': awsEmergency,
        'awsWatchAndAct': awsWatchAndAct,
        'awsAdvice': awsAdvice,
        'officialNonAws': officialNonAws,
        'userReported': userReported,
        'globalHumanitarian': globalHumanitarian,
        'alrtIntel': alrtIntel,
        'selectedCategoryIds': selectedCategoryIds.toList(),
        'selectedLocationIds': selectedLocationIds.toList(),
      };

  static HazardFiltersProviderState fromStorageJson(final Map<String, dynamic> json) {
    bool b(final String key) => json[key] is bool ? json[key] as bool : true;
    Set<String> ids(final String key) =>
        (json[key] as List<dynamic>? ?? const []).map((e) => e.toString()).toSet();
    return HazardFiltersProviderState(
      awsEmergency: b('awsEmergency'),
      awsWatchAndAct: b('awsWatchAndAct'),
      awsAdvice: b('awsAdvice'),
      officialNonAws: b('officialNonAws'),
      userReported: b('userReported'),
      globalHumanitarian: b('globalHumanitarian'),
      alrtIntel: b('alrtIntel'),
      selectedCategoryIds: ids('selectedCategoryIds'),
      selectedLocationIds: ids('selectedLocationIds'),
    );
  }


  /// Indicates whether any filters are currently selected.
  bool get hasFiltersSelected =>
      awsEmergency ||
      awsWatchAndAct ||
      awsAdvice ||
      officialNonAws ||
      userReported ||
      globalHumanitarian ||
      alrtIntel ||
      selectedCategoryIds.isNotEmpty;

  /// Whether [hazard] passes the source toggles that are applied on the
  /// phone (the API predates the global humanitarian and Intel switches,
  /// so those two filter the results after they arrive).
  bool allowsHazard(final Hazard hazard) {
    if (!globalHumanitarian && hazard.isGlobalHumanitarian) return false;
    if (!alrtIntel && hazard.isAlrtIntel) return false;
    return true;
  }

  /// Returns the total count of unselected filters.
  int get unselectedFiltersCount {
    int count = 0;
    if (!awsEmergency) count++;
    if (!awsWatchAndAct) count++;
    if (!awsAdvice) count++;
    if (!officialNonAws) count++;
    if (!userReported) count++;
    if (!globalHumanitarian) count++;
    if (!alrtIntel) count++;
    count += allCategoryIds.length - selectedCategoryIds.length;
    return count;
  }
}
