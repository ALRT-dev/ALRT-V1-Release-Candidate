import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/service_providers.dart';
import 'package:hazard_app/features/map/services/location_service.dart';
import 'package:hazard_app/features/profile/providers/my_hazards_provider.dart';
import 'package:hazard_app/features/profile/providers/states/my_hazards_provider_state.dart';
import 'package:hazard_app/features/report/providers/states/create_update_report_provider_state.dart';
import 'package:hazard_app/features/shared/enums/hazard_review_status_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/analytics_service.dart';
import 'package:hazard_app/features/shared/services/hazard_service.dart';
import 'package:hazard_app/features/shared/services/media_service.dart';
import 'package:hazard_app/features/shared/utils/either.dart';
import 'package:uuid/uuid.dart';

final providerOfCreateReport =
    StateNotifierProvider.autoDispose<
      CreateReportProvider,
      CreateUpdateReportProviderState
    >(
      (ref) => CreateReportProvider(
        ref: ref,
        state: const CreateUpdateReportProviderState(),
      ),
    );

class CreateReportProvider
    extends StateNotifier<CreateUpdateReportProviderState> {
  CreateReportProvider({
    required final Ref ref,
    required final CreateUpdateReportProviderState state,
  }) : _ref = ref,
       super(state) {
    getCategoriesToSelect();
  }

  final Ref _ref;
  MediaService get _mediaService => _ref.read(providerOfMediaService);
  HazardService get _hazardService => _ref.read(providerOfHazardService);
  LocationService get _locationService => _ref.read(providerOfLocationService);
  MyHazardsProvider get _myHazardsProvider =>
      _ref.read(providerOfMyHazards.notifier);
  MyHazardsProviderState get _myHazardsProviderState =>
      _ref.read(providerOfMyHazards);
  MapProvider get _mapProvider => _ref.read(providerOfMap.notifier);

  /// Fetches the list of hazard categories to select from and updates the state accordingly.
  Future<void> getCategoriesToSelect() async {
    state = state.copyWith(
      getCategoriesToSelectState: GetCategoriesToSelectState.loading(),
    );

    final result = await _hazardService.getAllParentHazardCategories();
    if (!mounted) return;

    result.when(
      (categories) {
        state = state.copyWith(
          getCategoriesToSelectState: GetCategoriesToSelectState.success(
            categories,
          ),
          categoriesToSelect: categories,
        );
      },
      (error) {
        state = state.copyWith(
          getCategoriesToSelectState: GetCategoriesToSelectState.error(error),
        );
      },
    );
  }

  /// Creates or updates a hazard report using the data in the current state.
  Future<void> createOrUpdateReport() async {
    updateReportSubmitted(true);

    final hazard = state.hazardToCreateOrUpdate.copyWith(
      categoryId: state.hazardToCreateOrUpdate.category?.id,
      category: null,
    );

    final isUpdating = hazard.id?.isNotEmpty ?? false;

    final creatingHazardReport = CreatingUpdatingHazardReport(
      id: Uuid().v4(),
      hazard: hazard,
      state: CreatingUpdatingHazardReportState.loading(),
    );
    addCreatingHazardReport(creatingHazardReport);

    Either<Hazard, AppError> result;
    if (isUpdating) {
      result = await _hazardService.updateHazardReport(
        hazard: hazard,
        mediaFiles: state.medias
            .where((element) => element.s3Key == null)
            .toList(),
        removedMediaIds: state.hazardToCreateOrUpdate.processedMedias
            .where((media) => !state.medias.any((m) => m.id == media.id))
            .map((media) => media.id)
            .toList(),
      );
    } else {
      result = await _hazardService.createHazardReport(
        hazard: hazard,
        mediaFiles: state.medias,
      );
    }
    if (!mounted) return;

    result.when(
      (hazard) {
        updateCreatingHazardReport(
          creatingHazardReport.copyWith(
            hazard: hazard,
            state: CreatingUpdatingHazardReportState.success(hazard),
          ),
        );

        if (!isUpdating) {
          AnalyticsService.reportSubmitted(categoryId: hazard.category?.id);

          // Update user's hazardsReportedCount by 1 if a new hazard was created.
          _ref
              .read(providerOfLoggedInUser.notifier)
              .update(
                (user) => user?.copyWith(
                  hazardsReportedCount: user.hazardsReportedCount + 1,
                ),
              );

          // Add the newly created hazard to the appropriate list in MyHazardsProvider.
          if (hazard.reviewStatus == HazardReviewStatus.accepted) {
            _myHazardsProvider.addOrUpdateAcceptedHazard(hazard);
          } else if (hazard.reviewStatus == HazardReviewStatus.rejected) {
            _myHazardsProvider.addOrUpdateRejectedHazard(hazard);
          }
        } else {
          final wasInAcceptedList = _myHazardsProviderState.myAcceptedHazards
              .any((h) => h.id == hazard.id);
          final wasInRejectedList = _myHazardsProviderState.myRejectedHazards
              .any((h) => h.id == hazard.id);

          // Update the hazard in MyHazardsProvider based on its new review status.
          if (wasInAcceptedList &&
              hazard.reviewStatus == HazardReviewStatus.rejected) {
            // If the hazard was in the accepted list and is now rejected, move it.
            _myHazardsProvider
              ..removeFromMyAcceptedHazards(hazard.id!)
              ..addOrUpdateRejectedHazard(hazard);
          } else if (wasInRejectedList &&
              hazard.reviewStatus == HazardReviewStatus.accepted) {
            // If the hazard was in the rejected list and is now accepted, move it.
            _myHazardsProvider
              ..removeFromMyRejectedHazards(hazard.id!)
              ..addOrUpdateAcceptedHazard(hazard);
          } else {
            // If the hazard's review status didn't change, just update it in place.
            if (hazard.reviewStatus == HazardReviewStatus.accepted) {
              _myHazardsProvider.addOrUpdateAcceptedHazard(hazard);
            } else if (hazard.reviewStatus == HazardReviewStatus.rejected) {
              _myHazardsProvider.addOrUpdateRejectedHazard(hazard);
            }
          }
        }

        // refresh the hazard on the map
        _mapProvider.getMapHazards();
      },
      (error) {
        updateCreatingHazardReport(
          creatingHazardReport.copyWith(
            state: CreatingUpdatingHazardReportState.error(error),
          ),
        );
      },
    );
  }

  /// Picks multiple images from the gallery and adds them to [CreateUpdateReportProviderState.medias].
  Future<void> pickMedias() async {
    final result = await _mediaService.pickMedias();
    if (!mounted) return;

    result.whenSuccess(
      (medias) => updateMedias(
        [...state.medias, ...medias],
      ),
    );
  }

  /// Updates [CreateUpdateReportProviderState.hazardToCreateOrUpdate] with the given [hazard].
  void updateHazardToCreateOrUpdate(final Hazard hazard) {
    state = state.copyWith(
      hazardToCreateOrUpdate: hazard,
    );
  }

  /// Updates [CreateUpdateReportProviderState.hazardToCreateOrUpdate.title] with the given [title].
  void updateTitle(final String title) {
    updateHazardToCreateOrUpdate(
      state.hazardToCreateOrUpdate.copyWith(
        title: title,
      ),
    );
  }

  /// Updates [CreateUpdateReportProviderState.hazardToCreateOrUpdate.occuredAt] with the given [dateTime].
  void updateDateTime(final DateTime dateTime) {
    updateHazardToCreateOrUpdate(
      state.hazardToCreateOrUpdate.copyWith(
        occurredAt: dateTime,
      ),
    );
  }

  /// Updates [CreateUpdateReportProviderState.hazardToCreateOrUpdate.category] with the given [category].
  void updateCategory(final HazardCategory category) {
    updateHazardToCreateOrUpdate(
      state.hazardToCreateOrUpdate.copyWith(
        category: category,
      ),
    );
  }

  /// Updates [CreateUpdateReportProviderState.hazardToCreateOrUpdate.severity] with the given [severity].
  void updateSeverity(final HazardSeverity severity) {
    updateHazardToCreateOrUpdate(
      state.hazardToCreateOrUpdate.copyWith(
        severity: severity,
      ),
    );
  }

  /// Prefills [CreateUpdateReportProviderState.hazardToCreateOrUpdate]'s
  /// location with the user's current device location, reverse-geocoded to a
  /// suburb-level name.
  ///
  /// Does nothing when a location is already set (e.g. when updating an
  /// existing report), when the device location is unavailable, or when the
  /// reverse-geocoding fails, so the manual location selection stays intact.
  Future<void> prefillLocationFromCurrentPosition() async {
    if (state.hazardToCreateOrUpdate.latitude != null ||
        state.hazardToCreateOrUpdate.longitude != null) {
      return;
    }

    final locationState = _ref.read(providerOfLocation);
    if (!locationState.isUsingDeviceLocation) return;

    final currentLocation = locationState.location;
    final addressResult = await _locationService
        .getAddressFromCoordinatesPlugin(
          coordinates: currentLocation.latLng,
          getSubUrbOnly: true,
        );
    if (!mounted) return;

    // Don't override a location the user picked while reverse-geocoding.
    if (state.hazardToCreateOrUpdate.latitude != null ||
        state.hazardToCreateOrUpdate.longitude != null) {
      return;
    }

    addressResult.whenSuccess(
      (suburb) => updateLocation(
        AlrtLocation(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          name: suburb,
        ),
      ),
    );
  }

  /// Updates [CreateUpdateReportProviderState.location] with the given [location].
  void updateLocation(final AlrtLocation location) {
    updateHazardToCreateOrUpdate(
      state.hazardToCreateOrUpdate.copyWith(
        latitude: location.latitude,
        longitude: location.longitude,
        locationName: location.displayName,
      ),
    );
  }

  /// Updates [CreateUpdateReportProviderState.description] with the given [description].
  void updateDescription(final String description) {
    updateHazardToCreateOrUpdate(
      state.hazardToCreateOrUpdate.copyWith(
        description: description,
      ),
    );
  }

  /// Updates [CreateUpdateReportProviderState.medias] with the given list of [medias].
  void updateMedias(final List<AlrtMedia> medias) {
    state = state.copyWith(medias: medias);
  }

  /// Adds medias to [CreateUpdateReportProviderState.medias].
  void addMedias(final List<AlrtMedia> medias) {
    updateMedias(
      [...state.medias, ...medias],
    );
  }

  /// Removes a media from [CreateUpdateReportProviderState.medias] with the given [mediaId].
  void removeMedia(final String mediaId) {
    updateMedias(
      state.medias.where((media) => media.id != mediaId).toList(),
    );
  }

  /// Updates [CreateUpdateReportProviderState.reportSubmitted] with the given [reportSubmitted].
  void updateReportSubmitted(final bool reportSubmitted) {
    state = state.copyWith(reportSubmitted: reportSubmitted);
  }

  /// Updates [CreateUpdateReportProviderState.creatingHazardReports] with the given [creatingHazardReports].
  void updateCreatingHazardReports(
    final List<CreatingUpdatingHazardReport> creatingHazardReports,
  ) {
    state = state.copyWith(
      creatingUpdatingHazardReports: creatingHazardReports,
    );
  }

  /// Adds a new [CreatingUpdatingHazardReport] to [CreateUpdateReportProviderState.creatingHazardReports].
  void addCreatingHazardReport(
    final CreatingUpdatingHazardReport creatingHazardReport,
  ) {
    updateCreatingHazardReports(
      [...state.creatingUpdatingHazardReports, creatingHazardReport],
    );
  }

  /// Updates a [CreatingUpdatingHazardReport] in [CreateUpdateReportProviderState.creatingHazardReports].
  void updateCreatingHazardReport(
    final CreatingUpdatingHazardReport creatingHazardReport,
  ) {
    updateCreatingHazardReports(
      state.creatingUpdatingHazardReports.map((chr) {
        if (chr.id == creatingHazardReport.id) {
          return creatingHazardReport;
        }
        return chr;
      }).toList(),
    );
  }

  /// Updates [CreateUpdateReportProviderState.showCategoriesSelector] with the given [showCategoriesSelector].
  void updateShowCategoriesSelector(final bool showCategoriesSelector) {
    state = state.copyWith(showCategoriesSelector: showCategoriesSelector);
  }

  /// Resets all fields in the state to their initial values.
  void resetAllFields() {
    state = state.copyWith(
      hazardToCreateOrUpdate: state.hazardToCreateOrUpdate.copyWith(
        category: null,
        latitude: null,
        longitude: null,
        locationName: null,
        title: null,
        description: null,
      ),
      medias: [],
      showCategoriesSelector: true,
    );
  }

  /// Updates [CreateUpdateReportProviderState.acknowledgedReportIds] with the given list of [acknowledgedReportIds].
  void updateAcknowledgedReportIds(final List<String> acknowledgedReportIds) {
    state = state.copyWith(acknowledgedReportIds: acknowledgedReportIds);
  }

  /// Adds a new report ID to [CreateUpdateReportProviderState.acknowledgedReportIds].
  void addToAcknowledgedReportId(final String reportId) {
    updateAcknowledgedReportIds(
      [...state.acknowledgedReportIds, reportId],
    );
  }
}
