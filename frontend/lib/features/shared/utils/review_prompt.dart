import 'package:hazard_app/features/shared/enums/shared_prefs_key_types.dart';
import 'package:hazard_app/features/shared/repositories/shared_prefs_repository.dart';
import 'package:hazard_app/features/shared/services/analytics_service.dart';
import 'package:in_app_review/in_app_review.dart';

/// Never ask more often than this — the OS quota is stricter anyway.
const _kReviewAskCooldown = Duration(days: 90);

/// Requests the in-app review dialog at a happy moment (e.g. right after the
/// user's report was approved), at most once per cooldown window. The OS
/// ultimately decides whether the dialog is actually shown.
Future<void> maybeAskForReview({
  required final SharedPreferencesRepository prefs,
}) async {
  final lastAskedResult = await prefs.getInt(
    key: SharedPrefsKey.reviewLastAskedAt,
  );
  final lastAskedAt = lastAskedResult.whenSuccess((v) => v);
  final now = DateTime.now().millisecondsSinceEpoch;
  if (lastAskedAt != null && now - lastAskedAt < _kReviewAskCooldown.inMilliseconds) {
    return;
  }

  final inAppReview = InAppReview.instance;
  if (!await inAppReview.isAvailable()) return;

  await prefs.saveInt(key: SharedPrefsKey.reviewLastAskedAt, value: now);
  AnalyticsService.reviewRequested();
  await inAppReview.requestReview();
}
