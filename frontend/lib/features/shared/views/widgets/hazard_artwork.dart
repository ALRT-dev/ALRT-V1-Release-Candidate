import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hazard_app/features/shared/enums/category_image_type.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/utils/hazard_art_assets.dart';
import 'package:hazard_app/features/shared/views/widgets/category_glyph.dart';

/// The same picture the map pin wears, drawn on a card: the band-coloured
/// diamond or AWS triangle with the hazard pictogram for official alerts,
/// the category disc for community reports (product owner, 16 Oct 2026:
/// the icon sits at the right of the card title on the list and the map
/// callout alike, so a card and its pin match).
///
/// Server artwork (the category's image for this band) wins; the bundled
/// asset is the fallback, as on the map.
class HazardArtwork extends StatelessWidget {
  const HazardArtwork({super.key, required this.hazard, this.size = 44});

  final Hazard hazard;
  final double size;

  @override
  Widget build(BuildContext context) {
    final category = hazard.category;
    if (hazard.isUserReported) {
      if (category == null) return SizedBox.square(dimension: size);
      final parent = category.parent;
      final drawn =
          CategoryGlyph.iconFor(category.name) == null && parent != null
              ? parent
              : category;
      return CategoryGlyph(category: drawn, size: size * 0.8);
    }

    final band = hazard.severityBand ?? HazardSeverityBand.info;
    final isAws = hazard.isAwsCompliant == true;
    final asset = bundledHazardArtPath(category, band, isAwsCompliant: isAws);
    final url = _serverImageUrl(category, band, isAws: isAws);

    final fallback = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
    if (url == null) return fallback;
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => fallback,
    );
  }

  /// The first image for this band in the category chain, as the map does.
  static String? _serverImageUrl(
    final HazardCategory? category,
    final HazardSeverityBand band, {
    required final bool isAws,
  }) {
    final type = isAws
        ? switch (band) {
            HazardSeverityBand.info ||
            HazardSeverityBand.monitor => CategoryImageType.advice,
            HazardSeverityBand.action => CategoryImageType.watchAndAct,
            HazardSeverityBand.critical => CategoryImageType.emergency,
          }
        : switch (band) {
            HazardSeverityBand.info => CategoryImageType.info,
            HazardSeverityBand.monitor => CategoryImageType.monitor,
            HazardSeverityBand.action => CategoryImageType.action,
            HazardSeverityBand.critical => CategoryImageType.critical,
          };
    for (HazardCategory? node = category; node != null; node = node.parent) {
      final slot = node.images?.firstWhereOrNull((i) => i.imageType == type);
      if (slot != null && slot.url.isNotEmpty) return slot.url;
    }
    return null;
  }
}
