import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

part 'get_hazards_with_subscription_id_reponse.freezed.dart';
part 'get_hazards_with_subscription_id_reponse.g.dart';

@freezed
abstract class GetHazardsWithSubscriptionIdResponse
    with _$GetHazardsWithSubscriptionIdResponse {
  const factory GetHazardsWithSubscriptionIdResponse({
    /// The list of hazards.
    @Default(<Hazard>[]) final List<Hazard> hazards,

    /// The subscription ID associated with the hazards retrieval.
    final String? subscriptionId,
  }) = _GetHazardsWithSubscriptionIdResponse;

  factory GetHazardsWithSubscriptionIdResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$GetHazardsWithSubscriptionIdResponseFromJson(json);
}
