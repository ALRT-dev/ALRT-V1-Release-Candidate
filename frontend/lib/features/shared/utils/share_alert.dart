import 'package:hazard_app/api/endpoints.dart';
import 'package:hazard_app/features/shared/enums/hazard_review_status_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/services/analytics_service.dart';
import 'package:share_plus/share_plus.dart';

/// Only accepted alerts have a public share page — the backend serves a 410
/// for anything else, so hide share affordances otherwise.
bool isAlertShareable(final Hazard hazard) {
  return hazard.id != null &&
      hazard.reviewStatus == HazardReviewStatus.accepted;
}

/// Opens the OS share sheet for an alert, pointing at the public short link
/// (which unfurls with the OG card). [from] tags the analytics event with
/// where the share started (e.g. 'detail', 'card', 'map_callout').
Future<void> shareAlert({
  required final Hazard hazard,
  required final String from,
}) async {
  final id = hazard.id;
  if (id == null) return;

  final url = '$kUrlBase/a/$id';
  final parts = <String>[
    if ((hazard.severityTitle).isNotEmpty &&
        hazard.severityTitle != 'Unknown')
      '${hazard.severityTitle.toUpperCase()}:',
    hazard.title ?? 'Safety alert',
    if (hazard.locationName != null) 'near ${hazard.locationName}',
  ];

  AnalyticsService.alertShared(hazardId: id, from: from);
  await SharePlus.instance.share(
    ShareParams(
      text: '${parts.join(' ')}\n$url',
      subject: hazard.title ?? 'Safety ALRT alert',
    ),
  );
}
