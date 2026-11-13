import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/learn/models/guide_models.dart';
import 'package:hazard_app/features/learn/providers/service_providers.dart';

/// The guide linked to a hazard category, keyed by category id.
///
/// Resolves to `null` when no guide is linked to the category (or when the
/// lookup fails) so feed cards can simply hide their guide strip. Results
/// are cached per category id for the lifetime of the app session
/// (non-autoDispose family).
///
/// Usage from a feed card:
/// ```dart
/// final guide = ref.watch(providerOfGuideForCategory(categoryId));
/// guide.valueOrNull; // GuideForCategory? — null means no strip
/// ```
/// The provider key for a category and, optionally, the alert's level.
///
/// The level picks the guide's stage (owner review, 13 November 2026): an
/// active warning gets the "during" guide, an advice the "before" guide, a
/// cancelled or resolved alert the "after" guide. Without a level the key is
/// the plain category id.
String guideForCategoryKey(final String categoryId, [final String? level]) {
  final trimmed = level?.trim();
  return trimmed == null || trimmed.isEmpty
      ? categoryId
      : '$categoryId|$trimmed';
}

final providerOfGuideForCategory =
    FutureProvider.family<GuideForCategory?, String>(
      (ref, key) async {
        final separator = key.indexOf('|');
        final categoryId = separator < 0 ? key : key.substring(0, separator);
        final level = separator < 0 ? null : key.substring(separator + 1);
        if (categoryId.trim().isEmpty) return null;

        final learnService = ref.watch(providerOfLearnService);

        final result = await learnService.getGuideForCategory(
          categoryId: categoryId,
          level: level,
        );

        return result.when(
          (guide) => guide,
          // Swallow the error: a missing guide strip is a graceful fallback.
          (error) => null,
        );
      },
    );
