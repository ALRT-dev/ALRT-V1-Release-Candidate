import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';

part 'places_provider_state.freezed.dart';

@freezed
abstract class PlacesProviderState with _$PlacesProviderState {
  const factory PlacesProviderState({
    /// The search string used to fetch places.
    @Default('') final String searchString,

    /// The places fetched from the map service after a successful fetch.
    @Default(<GooglePlace>[]) final List<GooglePlace> places,

    /// The state of fetching places.
    @Default(GetPlacesState.initial()) final GetPlacesState getPlacesState,
  }) = _PlacesProviderState;
}

@freezed
abstract class GetPlacesState with _$GetPlacesState {
  const factory GetPlacesState.initial() = _GetPlacesStateInitial;
  const factory GetPlacesState.loading() = _GetPlacesStateLoading;
  const factory GetPlacesState.success(
    final List<GooglePlace> places,
  ) = _GetPlacesStateSuccess;
  const factory GetPlacesState.error(
    final AppError error,
  ) = _GetPlacesStateError;
}
