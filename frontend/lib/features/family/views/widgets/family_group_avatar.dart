import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';

/// How a family group is drawn wherever it is named: hub header, the group
/// switcher, group settings and the home-screen widget.
///
/// One widget so a group looks the same in every list. With a picture set
/// it shows the picture; without one it falls back to the group's initial
/// on its beacon colour, which is the default look and never a blank hole.
class FamilyGroupAvatar extends StatelessWidget {
  const FamilyGroupAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.themeColorHex,
    this.size = 44,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String name;
  final String? photoUrl;

  /// The group's beacon colour as stored (`#RRGGBB`). Falls back to the
  /// family indigo when absent or unparseable.
  final String? themeColorHex;

  final double size;

  /// An optional ring, used where the avatar sits on a coloured header.
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    final hasPhoto = url != null && url.isNotEmpty;
    final beacon = colorOfHex(themeColorHex) ?? FamilyColors.v31Indigo;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: beacon,
        shape: BoxShape.circle,
        border: borderWidth > 0 && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              // A slow or failed image must never leave the group unnamed,
              // so both states fall back to the initial treatment.
              placeholder: (_, _) => _initialBuilder(),
              errorWidget: (_, _, _) => _initialBuilder(),
            )
          : _initialBuilder(),
    );
  }

  Widget _initialBuilder() {
    return Center(
      child: Text(
        initialOf(name),
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  /// The single letter a group without a picture wears.
  static String initialOf(final String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }

  /// Parses a stored `#RRGGBB` (or `RRGGBB`) beacon colour.
  static Color? colorOfHex(final String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(cleaned.length <= 6 ? value | 0xFF000000 : value);
  }
}
