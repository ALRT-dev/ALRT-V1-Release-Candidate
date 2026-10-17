import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shared pieces for the Me sub-screens, drawn from the prototype's own
/// helpers (ui.js `hdr`, `card`, `group`, `row`, `primary`, `secondary`,
/// `ghost`, `muted`, `note`): grey page #F5F5F7, a white header with a back
/// arrow, a 24 px title and an optional 14 px subtitle, then white
/// 18 px-radius cards.
class ProfilePageKit {
  ProfilePageKit._();

  static const page = Color(0xFFF5F5F7);
  static const muted = Color(0xFF5C5C66);
  static const hairline = Color(0xFFE3E6EA);
  static const divider = Color(0x0F000000);
  static const noteBg = Color(0xFFF0EEEA);
  static const noteInk = Color(0xFF3A3A42);
  static const secondaryBorder = Color(0xFFD9D6D0);
  static const dangerStart = Color(0xFFC8102E);
  static const dangerEnd = Color(0xFF7A0012);

  static BoxDecoration cardDecoration({final Color color = AppColors.white}) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 3.0,
            offset: Offset(0, 1),
          ),
        ],
      );
}

/// The prototype header: white, back arrow, 24/700 title, optional muted
/// subtitle. Pass [onBack] to override the default pop.
class ProfilePageHeader extends StatelessWidget {
  const ProfilePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showBack = true,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.spMin, 8.spMin, 16.spMin, 12.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (showBack)
                    Transform.translate(
                      offset: Offset(-8.spMin, 0),
                      child: SizedBox(
                        width: 40.spMin,
                        height: 40.spMin,
                        child: IconButton(
                          tooltip: 'Back',
                          padding: EdgeInsets.zero,
                          onPressed: onBack ?? () => context.pop(),
                          icon: Icon(
                            LucideIcons.chevronLeft,
                            size: 24.spMin,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 24.spMin,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4.spMin),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14.spMin,
                    color: ProfilePageKit.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// White card, 16 px padding, children spaced 10 px (prototype `card`).
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.children, this.gap = 10});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.spMin),
      decoration: ProfilePageKit.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap.spMin),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Muted body copy (prototype `muted`).
class ProfileMutedText extends StatelessWidget {
  const ProfileMutedText(this.text, {super.key, this.size = 13});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size.spMin,
        height: 1.45,
        color: ProfilePageKit.muted,
      ),
    );
  }
}

/// Uppercase section label (#B84500).
class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.spMin),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.sectionLabel,
        ),
      ),
    );
  }
}

/// Beige note block (prototype `note`).
class ProfileNote extends StatelessWidget {
  const ProfileNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: ProfilePageKit.noteBg,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.spMin,
          height: 1.45,
          color: ProfilePageKit.noteInk,
        ),
      ),
    );
  }
}

/// One white group of rows separated by inset hairlines (prototype
/// `group`).
class ProfileRowGroup extends StatelessWidget {
  const ProfileRowGroup({
    super.key,
    required this.rows,
    this.color = AppColors.white,
  });

  final List<Widget> rows;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18.spMin),
        border: Border.all(color: const Color(0x0A000000)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.spMin),
                child: const Divider(
                  height: 1,
                  thickness: 1,
                  color: ProfilePageKit.divider,
                ),
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// One list row: 15/700 title, optional 12/500 subtitle, a chevron or
/// [trailing] (prototype `row`).
class ProfileListRow extends StatelessWidget {
  const ProfileListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleColor = ProfilePageKit.muted,
    this.onTap,
    this.trailing,
    this.leading,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final Color subtitleColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? leading;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: 58.spMin),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin),
        child: Row(
          children: [
            if (leading != null) ...[leading!, SizedBox(width: 12.spMin)],
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.spMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      SizedBox(height: 1.spMin),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12.spMin,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.spMin),
            if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(
                LucideIcons.chevronRight,
                size: 18.spMin,
                color: ProfilePageKit.muted,
              ),
          ],
        ),
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

/// The three prototype buttons: primary (orange or a gradient, 54 px),
/// secondary (white, outlined, 48 px) and ghost (text only, 44 px).
enum ProfileButtonKind { primary, secondary, ghost }

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = ProfileButtonKind.primary,
    this.gradient,
    this.busy = false,
  });

  /// A red primary, as on the delete screens.
  const ProfileButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  })  : kind = ProfileButtonKind.primary,
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ProfilePageKit.dangerStart, ProfilePageKit.dangerEnd],
        );

  final String label;
  final VoidCallback? onPressed;
  final ProfileButtonKind kind;
  final Gradient? gradient;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    switch (kind) {
      case ProfileButtonKind.primary:
        final shadowColor = gradient != null
            ? const Color(0x4DC8102E)
            : AppColors.orange.withValues(alpha: 0.25);
        return Opacity(
          opacity: enabled || busy ? 1.0 : 0.5,
          child: Container(
            height: 54.spMin,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gradient == null ? AppColors.orange : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(14.spMin),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: busy
                ? SizedBox(
                    width: 22.spMin,
                    height: 22.spMin,
                    child: const CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
          ),
        )._tap(enabled ? onPressed : null);
      case ProfileButtonKind.secondary:
        return Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Container(
            height: 48.spMin,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.spMin),
              border: Border.all(color: ProfilePageKit.secondaryBorder),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
        )._tap(enabled ? onPressed : null);
      case ProfileButtonKind.ghost:
        return SizedBox(
          height: 44.spMin,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w600,
                color: ProfilePageKit.muted,
              ),
            ),
          ),
        )._tap(enabled ? onPressed : null);
    }
  }
}

extension on Widget {
  Widget _tap(final VoidCallback? onTap) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: this,
      );
}

/// The prototype sheet title block (`sh1`): 22/700 title, 14 px muted
/// subtitle.
class ProfileSheetTitle extends StatelessWidget {
  const ProfileSheetTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        if (subtitle != null) ...[
          SizedBox(height: 4.spMin),
          ProfileMutedText(subtitle!, size: 14),
        ],
      ],
    );
  }
}

/// Opens a prototype-style bottom sheet: white, 24 px top radius, drag
/// handle, 20 px padding, children spaced 12 px.
Future<T?> showProfileSheet<T>({
  required final BuildContext context,
  required final List<Widget> Function(BuildContext sheetContext) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (sheetContext) {
      final children = builder(sheetContext);
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.spMin, 0, 20.spMin, 16.spMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(height: 12.spMin),
                children[i],
              ],
            ],
          ),
        ),
      );
    },
  );
}
