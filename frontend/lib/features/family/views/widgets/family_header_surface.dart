import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';

/// The family header band: one blend, one light source, used everywhere.
///
/// Wrapping it means the hub, the journey screen, the switcher and the
/// empty state cannot drift into three slightly different purples again,
/// which is what made the family section look assembled rather than
/// designed.
class FamilyHeaderSurface extends StatelessWidget {
  const FamilyHeaderSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// Square by default: most family headers run full-bleed off the top.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: FamilyColors.headerGradient,
        borderRadius: borderRadius,
      ),
      child: DecoratedBox(
        // The highlight rides on top of the blend rather than being mixed
        // into it, so the band keeps a light source at any height.
        decoration: BoxDecoration(
          gradient: FamilyColors.headerHighlight,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// The family app bar: the shared header blend behind a normal AppBar.
///
/// Family screens were each building their own flat `FamilyColors.indigo`
/// bar, so the section had one screen with a rich purple gradient (the
/// hub) and a dozen with a flat blue slab. Several also left the title in
/// the default black, which on indigo is close to unreadable. This is the
/// one header, so they cannot drift apart again.
class FamilyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FamilyAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;

  /// Optional line under the title, in the band rather than on the page.
  final String? subtitle;

  final List<Widget>? actions;

  static const _subtitleHeight = 30.0;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (subtitle == null ? 0 : _subtitleHeight),
      );

  @override
  Widget build(BuildContext context) {
    return FamilyHeaderSurface(
      child: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        // White, always: the default black on this blend is unreadable.
        // foregroundColor alone is NOT enough — the app theme's
        // titleTextStyle (black) outranks it, which is why these titles
        // shipped black on the gradient (QA 2026-08-07).
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 18.spMin,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        elevation: 0,
        actions: actions,
        bottom: subtitle == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(_subtitleHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
