import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/category_filter_chip.dart';
import 'package:hazard_app/features/shared/views/widgets/hazard_shape_badge.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// THE key: who is speaking (the shapes), how serious (the colours) and
/// the category chips community reports wear.
///
/// One widget, rendered everywhere a key appears (the Map key sheet behind
/// the rail's info button), so the key cannot disagree with itself again.
/// [isDark] only flips the surface colours; every word, every shape and
/// every colour swatch is identical on both.
///
/// Product owner, 12 Oct 2026: the shapes are drawn as dark grey outlines
/// with no fill, so the key never hints that a source is more or less
/// serious. The seriousness band carries no level words; only the three
/// AWS words sit above it, because AWS is the only source that writes its
/// level in words.
class AlertKeyContent extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(
      providerOfMainCategories.select((value) => value.mainCategories),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _labelBuilder('WHO IS SPEAKING'),
        SizedBox(height: 10.spMin),
        _keyRowBuilder(
          icon: LucideIcons.triangle,
          title: 'Australian Warning System',
          subtitle: 'The only one that writes the level in words',
        ),
        _keyRowBuilder(
          icon: LucideIcons.diamond,
          title: 'Official source',
          subtitle: 'Colour for the level, never a level word',
        ),
        _keyRowBuilder(
          icon: LucideIcons.circle,
          title: 'Community report',
          subtitle: 'Colour is the category. Always Unverified',
        ),
        _keyRowBuilder(
          icon: LucideIcons.shield,
          title: 'ALRT Assessment',
          subtitle: 'Named sources. Never restates a warning',
        ),
        SizedBox(height: 16.spMin),
        _labelBuilder('COLOUR SHOWS SEVERITY'),
        SizedBox(height: 10.spMin),
        _seriousnessBuilder(),
        SizedBox(height: 16.spMin),
        // How the pins themselves read (product owner, 14 Oct 2026: the
        // info button is the key, so it explains the actual markers).
        _labelBuilder('ON THE MAP'),
        SizedBox(height: 10.spMin),
        _pinExamplesBuilder(),
        SizedBox(height: 10.spMin),
        _groupsBuilder(),
        SizedBox(height: 16.spMin),
        _labelBuilder('COMMUNITY REPORTS WEAR THEIR CATEGORY'),
        SizedBox(height: 10.spMin),
        Wrap(
          spacing: 7.spMin,
          runSpacing: 7.spMin,
          children: [
            for (final category in categories)
              CategoryFilterChip(category: category, isSelected: true),
          ],
        ),
      ],
    );
  }

  /// Real pin artwork: the picture inside says what happened, the
  /// outline colour says how serious.
  Widget _pinExamplesBuilder() {
    const examples = [
      ('assets/images/hazards/non_aws/crash_action.png', 'Crash'),
      ('assets/images/hazards/non_aws/trafficAndTransport_action.png', 'Transport'),
      ('assets/images/hazards/non_aws/securityAndCrime_monitor.png', 'Security'),
      ('assets/images/hazards/non_aws/communityInfo_info.png', 'Events'),
      ('assets/images/hazards/aws/bushfire_action.png', 'Bushfire'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final (asset, label) in examples)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(asset, width: 34.spMin, height: 34.spMin),
                  SizedBox(height: 4.spMin),
                  Text(
                    label,
                    style: TextStyle(fontSize: 10.5.spMin, color: _softInk),
                  ),
                ],
              ),
          ],
        ),
        SizedBox(height: 8.spMin),
        Text(
          'The picture inside a pin says what happened. The outline '
          'colour says how serious.',
          style: TextStyle(fontSize: 11.spMin, height: 1.4, color: _softInk),
        ),
      ],
    );
  }

  /// The count bubbles: black for a group, orange or red when a serious
  /// warning is inside it.
  Widget _groupsBuilder() {
    Widget bubble(final Color color, final String count) {
      return Container(
        width: 26.spMin,
        height: 26.spMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 2),
        ),
        child: Text(
          count,
          style: TextStyle(
            fontSize: 11.spMin,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      );
    }

    return Row(
      children: [
        bubble(const Color(0xFF111114), '4'),
        SizedBox(width: 4.spMin),
        bubble(AppColors.watchAndAct, '8'),
        SizedBox(width: 4.spMin),
        bubble(AppColors.emergency, '3'),
        SizedBox(width: 10.spMin),
        Expanded(
          child: Text(
            'A number is a group of alerts. Orange or red means a serious '
            'warning is inside. Tap to zoom in.',
            style: TextStyle(fontSize: 11.spMin, height: 1.4, color: _softInk),
          ),
        ),
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

  /// One source: its shape as a dark grey outline on a soft tile, then
  /// the name and one line on how to read it.
  Widget _keyRowBuilder({
    required final IconData icon,
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
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _tile,
              borderRadius: BorderRadius.circular(10.spMin),
            ),
            child: HazardShapeBadge.outlineGlyph(icon: icon, size: 18.spMin),
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

  /// The four colours as one band, no level words under it. The three AWS
  /// words sit over the yellow, orange and red segments with a pointer,
  /// because AWS is the only source that writes its level.
  Widget _seriousnessBuilder() {
    const bands = [
      AppColors.info,
      AppColors.advice,
      AppColors.watchAndAct,
      AppColors.emergency,
    ];
    const awsWords = ['Advice', 'Watch and Act', 'Emergency Warning'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Nothing over the grey segment: AWS never uses it.
            const Expanded(child: SizedBox.shrink()),
            for (final word in awsWords)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5.spMin,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: _ink,
                      ),
                    ),
                    Text(
                      '▲',
                      style: TextStyle(
                        fontSize: 8.spMin,
                        height: 1.2,
                        color: _softInk,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 2.spMin),
        Row(
          children: [
            for (final color in bands) Expanded(child: _segmentBuilder(color)),
          ],
        ),
        SizedBox(height: 6.spMin),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Less serious',
              style: TextStyle(fontSize: 10.5.spMin, color: _softInk),
            ),
            Text(
              'More serious',
              style: TextStyle(fontSize: 10.5.spMin, color: _softInk),
            ),
          ],
        ),
        SizedBox(height: 8.spMin),
        Text(
          'Colour shows severity. Official alerts use the same '
          'colours; only AWS writes its level in words.',
          style: TextStyle(
            fontSize: 11.spMin,
            height: 1.4,
            color: _softInk,
          ),
        ),
      ],
    );
  }

  Widget _segmentBuilder(final Color color) {
    return Container(
      height: 10.spMin,
      margin: EdgeInsets.symmetric(horizontal: 2.spMin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
