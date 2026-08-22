import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The ALRT+ visual language: blended gradients and glows instead of solid
/// blocks (per the "ALRT + supporting screens" design board). Kept separate
/// from [FamilyColors] — ALRT+ is the premium-tier brand (purple/magenta),
/// the family chrome accent stays indigo.
abstract final class AlrtPlusStyle {
  static const ink = Color(0xFF232326);
  static const inkSoft = Color(0xFF75757E);
  static const inkFaint = Color(0xFFABABB2);
  static const body = Color(0xFFF4F1F8);
  static const cardLine = Color(0xFFEDE8F2);
  static const magenta = Color(0xFFA63BD4);
  static const label = Color(0xFF9B7BC0);
  static const lavText = Color(0xFF7B3FA0);
  static const goldBg = Color(0xFFFBF0D9);
  static const goldText = Color(0xFFB07D1E);
  static const seatEmpty = Color(0xFFEDE6F4);
  static const seatOpenBorder = Color(0xFFCDB8E0);

  /// Magenta to violet CTA gradient.
  static const ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC13BD4), Color(0xFF8F2BBE)],
  );

  /// Deep purple header band with a warm glow.
  static const bandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF42186C), Color(0xFF2A0E45)],
  );

  /// Soft lavender info box.
  static const lavBoxGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF6ECFC), Color(0xFFEFE3FA)],
  );

  static const greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1FC97A), Color(0xFF0FA45C)],
  );

  static const amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF3DC), Color(0xFFFFE6C2)],
  );
}

/// The small "ALRT +" tier pill.
class AlrtPlusPill extends StatelessWidget {
  const AlrtPlusPill({super.key, this.onDark = false});

  /// Whether the pill sits on the dark purple band.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.spMin, vertical: 4.spMin),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.15)
            : AlrtPlusStyle.magenta.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'ALRT +',
        style: TextStyle(
          fontSize: 11.spMin,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: onDark ? Colors.white : AlrtPlusStyle.magenta,
        ),
      ),
    );
  }
}

/// The lavender trust/info note box.
class AlrtPlusLavNote extends StatelessWidget {
  const AlrtPlusLavNote({super.key, required this.lead, required this.text});

  final String lead;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 13.spMin, vertical: 10.spMin),
      decoration: BoxDecoration(
        gradient: AlrtPlusStyle.lavBoxGradient,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$lead ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
        style: TextStyle(
          fontSize: 11.5.spMin,
          height: 1.55,
          color: AlrtPlusStyle.lavText,
        ),
      ),
    );
  }
}

/// The full-width gradient CTA button.
class AlrtPlusCta extends StatelessWidget {
  const AlrtPlusCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AlrtPlusStyle.ctaGradient,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AlrtPlusStyle.magenta.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              height: 52.spMin,
              child: Center(
                child: busy
                    ? SizedBox(
                        width: 22.spMin,
                        height: 22.spMin,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        label,
                        style: TextStyle(
                          fontSize: 14.5.spMin,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
