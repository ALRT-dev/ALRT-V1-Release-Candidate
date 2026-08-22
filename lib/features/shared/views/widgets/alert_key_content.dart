import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// THE key: what the shapes mean, the AWS words, the official colours and
/// the category chips.
///
/// One widget, rendered everywhere a key appears (the Map details sheet,
/// the ALRT feed's filter sheet, the ALRT Key sheet), so the key cannot
/// disagree with itself again. [isDark] only flips the surface colours;
/// every word and every colour swatch is identical on both.
class AlertKeyContent extends StatelessWidget {
  const AlertKeyContent({super.key, required this.isDark});

  /// Dark for the map's sheet, light for the feed's.
  final bool isDark;

  Color get _ink => isDark ? AppColors.white : AppColors.black;
  Color get _softInk => isDark
      ? AppColors.white.withValues(alpha: 0.55)
      : AppColors.grey.withValues(alpha: 0.9);
  Color get _label => isDark
      ? AppColors.white.withValues(alpha: 0.45)
      : const Color(0xFFB84500);
  Color get _tile => isDark
      ? AppColors.white.withValues(alpha: 0.06)
      : AppColors.extraLightGrey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelBuilder('KEY · SHAPE SAYS WHO'),
        SizedBox(height: 10.spMin),
        _keyRowBuilder(
          icon: LucideIcons.triangleAlert,
          iconColor: AlertCardStyle.bandMonitor,
          title: 'Triangle · AWS warning',
          subtitle: 'The only source that states a severity level',
        ),
        _keyRowBuilder(
          icon: LucideIcons.diamond,
          iconColor: AlertCardStyle.bandAction,
          title: 'Diamond · official source',
          subtitle: 'State agencies and services',
        ),
        _keyRowBuilder(
          icon: LucideIcons.square,
          iconColor: const Color(0xFF7E8B9A),
          title: 'Rounded square · global humanitarian',
          subtitle: "Carries the source's own scale, not an AWS level",
        ),
        _keyRowBuilder(
          icon: LucideIcons.circle,
          iconColor: const Color(0xFF5AB0FF),
          title: 'Circle · community report',
          subtitle: 'Unverified, from someone nearby',
        ),
        _keyRowBuilder(
          icon: LucideIcons.shield,
          iconColor: AlertCardStyle.bandInfo,
          title: "Shield · ALRT's own assessment",
          subtitle: 'Never restates or overrides an official warning',
        ),
        SizedBox(height: 16.spMin),
        _labelBuilder('AWS WARNING LEVELS'),
        SizedBox(height: 10.spMin),
        _awsLevelsBuilder(),
        SizedBox(height: 16.spMin),
        _labelBuilder('OFFICIAL ALERT COLOURS'),
        SizedBox(height: 10.spMin),
        _officialColoursBuilder(),
        SizedBox(height: 16.spMin),
        _labelBuilder('COMMUNITY REPORTS WEAR THEIR CATEGORY'),
        SizedBox(height: 10.spMin),
        _categoriesBuilder(),
      ],
    );
  }

  Widget _labelBuilder(final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.5.spMin,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: _label,
      ),
    );
  }

  Widget _keyRowBuilder({
    required final IconData icon,
    required final Color iconColor,
    required final String title,
    required final String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.spMin),
      child: Row(
        children: [
          Container(
            width: 34.spMin,
            height: 34.spMin,
            decoration: BoxDecoration(
              color: _tile,
              borderRadius: BorderRadius.circular(10.spMin),
            ),
            child: Icon(icon, size: 17.spMin, color: iconColor),
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.spMin, color: _softInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The AWS words, in AWS's own colours. Only AWS states a level.
  Widget _awsLevelsBuilder() {
    const levels = [
      (AppColors.advice, 'Advice'),
      (AppColors.watchAndAct, 'Watch and Act'),
      (AppColors.emergency, 'Emergency Warning'),
    ];
    return Row(
      children: [
        for (final (color, label) in levels)
          Expanded(
            child: Column(
              children: [
                _barBuilder(color),
                SizedBox(height: 4.spMin),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5.spMin,
                    fontWeight: FontWeight.w600,
                    color: _softInk,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// The four official colours, no words: official sources never write a
  /// level, so the colour only SUGGESTS how serious it is.
  Widget _officialColoursBuilder() {
    const bands = [
      AppColors.info,
      AppColors.advice,
      AppColors.watchAndAct,
      AppColors.emergency,
    ];
    return Column(
      children: [
        Row(
          children: [
            for (final color in bands) Expanded(child: _barBuilder(color)),
          ],
        ),
        SizedBox(height: 6.spMin),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lower',
              style: TextStyle(fontSize: 10.5.spMin, color: _softInk),
            ),
            Text(
              'The colour shows the suggested severity',
              style: TextStyle(fontSize: 10.5.spMin, color: _softInk),
            ),
            Text(
              'Higher',
              style: TextStyle(fontSize: 10.5.spMin, color: _softInk),
            ),
          ],
        ),
      ],
    );
  }

  Widget _barBuilder(final Color color) {
    return Container(
      height: 8.spMin,
      margin: EdgeInsets.symmetric(horizontal: 3.spMin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _categoriesBuilder() {
    const names = [
      'Weather',
      'Health',
      'Security',
      'Traffic',
      'Utilities',
      'Community',
      'Other',
    ];
    return Wrap(
      spacing: 7.spMin,
      runSpacing: 7.spMin,
      children: [
        for (final name in names)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.spMin,
              vertical: 5.spMin,
            ),
            decoration: BoxDecoration(
              color: _tile,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9.spMin,
                  height: 9.spMin,
                  decoration: BoxDecoration(
                    color: lockedCategoryColorFor(name) ?? categoryOtherColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.spMin),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.85)
                        : AppColors.black,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
