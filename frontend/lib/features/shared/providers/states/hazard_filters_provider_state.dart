import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

part 'hazard_filters_provider_state.freezed.dart';

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
