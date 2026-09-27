import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

part 'notifications_feed_provider_state.freezed.dart';

@freezed
abstract class NotificationsFeedProviderState
    with _$NotificationsFeedProviderState {
  const factory NotificationsFeedProviderState({
    /// The search string to filter hazards by their title or description.
    @Default('') final String searchString,

    /// The list of hazards in the notifications feed.
    @Default(<Hazard>[]) final List<Hazard> hazards,

    /// The current page of the notifications feed.
    @Default(1) final int currentPage,

    /// The state of fetching the notifications feed.
    @Default(GetNotificationsFeedHazardsState.initial())
    final GetNotificationsFeedHazardsState getNotificationsFeedHazardsState,

    /// The state of fetching the next page of notifications feed.
    @Default(GetNotificationsFeedHazardsState.initial())
    final GetNotificationsFeedHazardsState getNextNotificationsFeedHazardsState,
  }) = _NotificationsFeedProviderState;
}

@freezed
class GetNotificationsFeedHazardsState with _$GetNotificationsFeedHazardsState {
  const factory GetNotificationsFeedHazardsState.initial() =
      _GetNotificationsFeedHazardsStateInitial;
  const factory GetNotificationsFeedHazardsState.loading() =
      _GetNotificationsFeedHazardsStateLoading;
  const factory GetNotificationsFeedHazardsState.success(
    final List<Hazard> hazards,
  ) = _GetNotificationsFeedHazardsStateSuccess;
  const factory GetNotificationsFeedHazardsState.error(
    final AppError error,
  ) = _GetNotificationsFeedHazardsStateError;
}
