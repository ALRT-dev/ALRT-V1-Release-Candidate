import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Tracks the timestamp of the last successful notifications feed fetch.
/// Used by the offline banner to show "Showing alerts as of HH:MM".
final providerOfLastFeedFetchAt = StateProvider<DateTime?>((ref) => null);
