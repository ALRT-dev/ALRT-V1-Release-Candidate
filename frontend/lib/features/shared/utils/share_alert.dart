import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/enums/hazard_review_status_types.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/base_url_provider.dart';
import 'package:hazard_app/features/shared/services/analytics_service.dart';
import 'package:share_plus/share_plus.dart';

/// Only accepted alerts have a public share page — the backend serves a 410
/// for anything else, so hide share affordances otherwise.
bool isAlertShareable(final Hazard hazard) {
  return hazard.id != null &&
      hazard.reviewStatus == HazardReviewStatus.accepted;
}

/// Builds the public share-page URL for an alert against [baseUrl] — kept
/// as a pure function, separate from [shareAlert], so the URL construction
/// is testable without a provider/widget harness.
String buildAlertShareUrl({
  required final String baseUrl,
  required final String hazardId,
}) => '$baseUrl/a/$hazardId';

/// Opens the OS share sheet for an alert, pointing at the public short link
/// (which unfurls with the OG card). [from] tags the analytics event with
/// where the share started (e.g. 'detail', 'card', 'map_callout').
///
/// The link is built against [providerOfBaseUrl] — the same base URL the
/// app's own API/socket traffic uses — so a DEV/TEST build shares a link
/// into the isolated TEST backend, never production (see
/// V1_RECONCILIATION_REPORT.md's TEST environment isolation audit).
Future<void> shareAlert({
  required final WidgetRef ref,
  required final Hazard hazard,
  required final String from,
}) async {
  final id = hazard.id;
  if (id == null) return;

  final baseUrl = ref.read(providerOfBaseUrl);
  final url = buildAlertShareUrl(baseUrl: baseUrl, hazardId: id);
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
