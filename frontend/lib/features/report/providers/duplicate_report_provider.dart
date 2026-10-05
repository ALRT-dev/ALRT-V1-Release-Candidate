import 'package:flutter_riverpod/legacy.dart';

/// What the server sent back when a new report repeats a live one nearby.
class DuplicateReport {
  const DuplicateReport({
    required this.hazardId,
    required this.title,
    required this.categoryName,
    this.locationName,
    this.createdAt,
    this.canConfirm = true,
  });

  final String hazardId;
  final String title;
  final String categoryName;
  final String? locationName;
  final DateTime? createdAt;
  final bool canConfirm;

  static DuplicateReport? fromErrorDetails(final Object? details) {
    if (details is! Map) return null;
    final id = details['existingHazardId'];
    if (id is! String) return null;
    return DuplicateReport(
      hazardId: id,
      title: (details['existingTitle'] as String?) ?? 'A similar alert',
      categoryName: (details['existingCategoryName'] as String?) ?? 'Other',
      locationName: details['existingLocationName'] as String?,
      createdAt: DateTime.tryParse('${details['existingCreatedAt']}'),
      canConfirm: details['canConfirm'] != false,
    );
  }
}

/// Set when a post is refused as a duplicate; the report screen shows the
/// "Is this the alert?" sheet and then clears it.
final providerOfDuplicateReport = StateProvider<DuplicateReport?>((ref) => null);
