import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_colors.dart';

/// A clean outlined icon with its colour on the stroke only, via a 45°
/// two-stop gradient - never a filled tile background. Used by every
/// grouped-card row on the Profile screen so the row itself stays a plain
/// white/dark card and the colour reads as identity, not as an alert.
class ProfileGradientIcon extends StatelessWidget {
  const ProfileGradientIcon({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 22.0,
  });

  final IconData icon;
  final ProfileRowAccent accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: accent.colors,
      ).createShader(bounds),
      child: Icon(
        icon,
        size: size.spMin,
        color: Colors.white,
      ),
    );
  }
}
