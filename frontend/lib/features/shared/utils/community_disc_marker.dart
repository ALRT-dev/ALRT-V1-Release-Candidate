import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/widgets/category_glyph.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

/// Logical size of the community category disc on every map (main map and
/// the alert detail's small map). Raised from 30 after the 14 Oct 2026
/// phone review found the pins too small to read or tap.
const double communityDiscSize = 38.0;

final Map<String, BitmapDescriptor> _cache = {};

/// The community pin: the category disc, a circle in the category colour
/// with a white ring and the category's white glyph, the same picture
/// [CategoryGlyph] draws on chips and cards. A community report wears its
/// category, never a band colour. Returns null when the category has no
/// disc (the caller falls back to the pin set).
///
/// Shared so the detail screen's small map draws the same pin as the main
/// map; it used to show a plain grey circle for community reports.
Future<BitmapDescriptor?> communityDiscMarker(final Hazard hazard) async {
  final category = hazard.category;
  if (category == null) return null;
  // A child category has no glyph of its own; the parent's glyph and
  // colour are the ones the chips show.
  final parent = category.parent;
  final drawn = CategoryGlyph.iconFor(category.name) == null && parent != null
      ? parent
      : category;
  final cached = _cache[drawn.id];
  if (cached != null) return cached;

  try {
    const size = communityDiscSize;
    // Room for the ring so the disc is not clipped at the bitmap edge.
    const canvas = size + 4.0;
    final bitmap = await Center(
      child: CategoryGlyph(
        category: drawn,
        size: size,
        borderColor: AppColors.white,
        borderWidth: 3.0,
      ),
    ).toBitmapDescriptor(
      logicalSize: const Size(canvas, canvas),
      imageSize: const Size(canvas * 2.5, canvas * 2.5),
    );
    _cache[drawn.id] = bitmap;
    return bitmap;
  } catch (_) {
    return null;
  }
}
