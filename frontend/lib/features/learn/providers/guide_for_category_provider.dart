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
final providerOfGuideForCategory =
    FutureProvider.family<GuideForCategory?, String>(
      (ref, categoryId) async {
        if (categoryId.trim().isEmpty) return null;

        final learnService = ref.watch(providerOfLearnService);

        final result = await learnService.getGuideForCategory(
          categoryId: categoryId,
        );

        return result.when(
          (guide) => guide,
          // Swallow the error: a missing guide strip is a graceful fallback.
          (error) => null,
        );
      },
    );
