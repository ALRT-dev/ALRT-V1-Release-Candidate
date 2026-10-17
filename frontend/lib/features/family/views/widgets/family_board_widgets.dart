import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The approved ALRT screen map's building blocks for the Family screens
/// (prototype ui.js: card, label, muted, note, primary, secondary, ghost,
/// small, chip, pill, person, sh1), so every Family screen and sheet is
/// drawn from the same parts and cannot drift from the boards.

/// The lavender page behind the Family sub-screens on the boards.
const kFamilyBoardPage = Color(0xFFF0EEF5);

/// The secondary button border on the boards.
const _secondaryBorder = Color(0xFFD9D6D0);

/// The white card: 18 px radius, 16 px padding, a hairline shadow.
class FamilyBoardCard extends StatelessWidget {
  const FamilyBoardCard({
    super.key,
    required this.children,
    this.padding,
    this.leftEdge,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  /// An optional 5 px coloured strip down the left edge.
  final Color? leftEdge;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? EdgeInsets.all(16.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 10.spMin,
        children: children,
      ),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 3.0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: leftEdge == null
          ? content
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 5.spMin, color: leftEdge),
                  Expanded(child: content),
                ],
              ),
            ),
    );
  }
}

/// The orange uppercase section label (#B84500).
class FamilyBoardLabel extends StatelessWidget {
  const FamilyBoardLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.spMin,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.sectionLabel,
      ),
    );
  }
}

/// Muted body copy (#5C5C66).
class FamilyBoardMuted extends StatelessWidget {
  const FamilyBoardMuted(this.text, {super.key, this.size = 13});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size.spMin,
        height: 1.45,
        color: AppColors.mediumGrey,
      ),
    );
  }
}

/// The soft grey note block.
class FamilyBoardNote extends StatelessWidget {
  const FamilyBoardNote(
    this.text, {
    super.key,
    this.background = const Color(0xFFF0EEEA),
    this.ink = const Color(0xFF3A3A42),
  });

  final String text;
  final Color background;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13.spMin, height: 1.45, color: ink),
      ),
    );
  }
}

/// The 54 px primary button. Family screens pass the indigo gradient.
class FamilyBoardPrimaryButton extends StatelessWidget {
  const FamilyBoardPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient = FamilyColors.headerGradient,
    this.shadow = const Color(0x4D2E2A9E),
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final Color shadow;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14.spMin),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 16.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: 54.spMin,
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.spMin),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  width: 20.spMin,
                  height: 20.spMin,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

/// The 48 px white outlined button.
class FamilyBoardSecondaryButton extends StatelessWidget {
  const FamilyBoardSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.ink = AppColors.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.spMin,
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
            side: const BorderSide(color: _secondaryBorder),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// The 44 px text-only button (Cancel, Close).
class FamilyBoardGhostButton extends StatelessWidget {
  const FamilyBoardGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.spMin,
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(foregroundColor: AppColors.mediumGrey),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// The 36 px small outlined button used inside cards and rows.
class FamilyBoardSmallButton extends StatelessWidget {
  const FamilyBoardSmallButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.spMin,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 14.spMin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.spMin),
            side: const BorderSide(color: AppColors.lightGrey),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// A 40 px selectable chip; selected chips take the family indigo.
class FamilyBoardChip extends StatelessWidget {
  const FamilyBoardChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = FamilyColors.indigo,
    this.tint = const Color(0xFFEEEEFB),
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 40.spMin,
          padding: EdgeInsets.symmetric(horizontal: 16.spMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? tint : Colors.white,
            borderRadius: BorderRadius.circular(20.spMin),
            border: Border.all(
              color: selected ? color : AppColors.lightGrey,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? color : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// A small status pill (Waiting, Checked in, SOS, Check on).
class FamilyBoardPill extends StatelessWidget {
  const FamilyBoardPill({
    super.key,
    required this.label,
    required this.background,
    required this.ink,
  });

  /// "Checked in": green on mint.
  const FamilyBoardPill.checkedIn({super.key})
      : label = 'Checked in',
        background = const Color(0xFFE6F6EC),
        ink = FamilyColors.checkedInInk;

  /// "Waiting": teal, only while a check-in was actually asked.
  const FamilyBoardPill.waiting({super.key})
      : label = 'Waiting',
        background = const Color(0x1F0D9488),
        ink = FamilyColors.teal;

  final String label;
  final Color background;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26.spMin,
      padding: EdgeInsets.symmetric(horizontal: 10.spMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13.spMin),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
    );
  }
}

/// A person row as its own white card: avatar, name, one line, and an
/// optional trailing control.
class FamilyBoardPersonRow extends StatelessWidget {
  const FamilyBoardPersonRow({
    super.key,
    required this.avatar,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget avatar;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 12.spMin),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.spMin),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 3.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            avatar,
            SizedBox(width: 12.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 2.spMin),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.spMin,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: 8.spMin),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A 44 px initial disc in a flat colour (the boards' person avatar).
class FamilyBoardInitial extends StatelessWidget {
  const FamilyBoardInitial({
    super.key,
    required this.name,
    this.color = AppColors.orange,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    return Container(
      width: 44.spMin,
      height: 44.spMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        trimmed.isEmpty ? '?' : trimmed[0].toUpperCase(),
        style: TextStyle(
          fontSize: 16.spMin,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// A bottom sheet's title (22/700) and optional muted line under it.
class FamilyBoardSheetTitle extends StatelessWidget {
  const FamilyBoardSheetTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22.spMin,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: AppColors.ink,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          SizedBox(height: 4.spMin),
          FamilyBoardMuted(subtitle!, size: 14),
        ],
      ],
    );
  }
}

/// The short grab handle at the top of the boards' sheets.
class FamilyBoardSheetHandle extends StatelessWidget {
  const FamilyBoardSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.spMin,
        height: 4.spMin,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(2.spMin),
        ),
      ),
    );
  }
}
