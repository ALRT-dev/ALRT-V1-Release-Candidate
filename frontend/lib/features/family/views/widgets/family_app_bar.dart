import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The plain white header of the 12 Oct 2026 Family mockups: a 36 px round
/// back button, the title at 22/700 in ink, optional trailing actions.
///
/// The gradient band (FamilyAppBar in family_header_surface.dart) stays
/// for the hub and the screens that still wear it; the editing and SOS
/// screens take this one so their cards sit on a quiet white sheet.
class FamilyWhiteAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FamilyWhiteAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
    this.backgroundColor = Colors.white,
  });

  final String title;
  final List<Widget>? actions;

  /// What Back does; defaults to popping the nearest navigator.
  final VoidCallback? onBack;

  final Color backgroundColor;

  static const _height = 60.0;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.spMin),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Back',
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36.spMin,
                      height: 36.spMin,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.extraLightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 20.spMin,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.spMin),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
