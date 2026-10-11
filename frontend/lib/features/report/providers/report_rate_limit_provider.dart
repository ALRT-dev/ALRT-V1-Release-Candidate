import 'package:flutter_riverpod/legacy.dart';

/// Set when the server refuses a community report with HTTP 429 (rate limit).
/// The report screen shows a refusal sheet and then clears it.
///
/// Backend limits: 3 reports per hour, 10 per day
/// (COMMUNITY_REPORTS_PER_HOUR / COMMUNITY_REPORTS_PER_DAY).
final providerOfReportRateLimit = StateProvider<String?>((ref) => null);
