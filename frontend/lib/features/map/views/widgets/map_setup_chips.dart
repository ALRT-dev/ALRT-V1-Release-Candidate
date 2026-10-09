import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/ask_alrt/views/ask_alrt_sheet.dart';
import 'package:hazard_app/features/map/views/screens/select_location_screen.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Horizontally scrolling action chips below the map search bar.
///
/// Handoff: "Ask ALRT button, Check a route, setup chips". The row gives
/// quick access to Ask ALRT (the primary action, styled as the brand
/// button) and Check a route (opens the route-planning search).
class MapSetupChips extends ConsumerWidget {
  const MapSetupChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 36.spMin,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.spMin),
        children: [
          _AskAlrtChip(onTap: () => showAskAlrtSheet(context)),
          SizedBox(width: 8.spMin),
          _ActionChip(
            icon: Icons.route_rounded,
            label: 'Check a route',
            onTap: () => context.push(SelectLocationScreen.route),
          ),
        ],
      ),
    );
  }
}

/// The branded Ask ALRT chip: orange gradient, sparkle icon.
class _AskAlrtChip extends StatelessWidget {
  const _AskAlrtChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B01), Color(0xFFE8622A)],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.spMin,
              vertical: 8.spMin,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16.spMin,
                  color: Colors.white,
                ),
                SizedBox(width: 6.spMin),
                Text(
                  'Ask ALRT',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A translucent action chip with an icon and label.
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.spMin,
              vertical: 8.spMin,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15.spMin,
                  color: AppColors.mediumGrey,
                ),
                SizedBox(width: 6.spMin),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF232326),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
