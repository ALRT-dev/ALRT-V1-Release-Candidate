import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_colors.dart';

/// A row's icon, coloured from its [ProfileRowAccent].
///
/// Calm by default: a single flat colour (the accent's richer stop), so an
/// ordinary row reads as one small accent, not a wash of colour down the
/// screen. Pass [gradient] true only for the handful of rows meant to
/// stand out (currently Family & check-ins and ALRT+ membership) - there
/// it renders the full two-stop 45° gradient via [ShaderMask].
class ProfileGradientIcon extends StatelessWidget {
  const ProfileGradientIcon({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 22.0,
    this.gradient = false,
  });

  final IconData icon;
  final ProfileRowAccent accent;
  final double size;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    if (!gradient) {
      return Icon(icon, size: size.spMin, color: accent.end);
    }
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
