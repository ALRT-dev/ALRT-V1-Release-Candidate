import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/services/severity_labels.dart';
import 'package:hazard_app/features/shared/views/widgets/category_filter_chip.dart';
import 'package:hazard_app/features/shared/views/widgets/hazard_shape_badge.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// THE key: who is speaking (the shapes), how serious (the colours) and
/// the category chips community reports wear.
///
/// UI polish 18 Oct 2026: darker body text, more breathing room, severity
/// labels no longer crowd edges, ON THE MAP section restored.
class AlertKeyContent extends ConsumerWidget {
  const AlertKeyContent({super.key, required this.isDark});

  final bool isDark;

  Color get _ink => isDark ? AppColors.white : AppColors.black;
  Color get _softInk => isDark
      ? AppColors.white.withValues(alpha: 0.75)
      : const Color(0xFF4A4A55);
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
        SizedBox(height: 12.spMin),
        _keyRowBuilder(icon: LucideIcons.triangle, title: 'Australian Warning System', subtitle: 'The only one that writes the level in words'),
        _keyRowBuilder(icon: LucideIcons.diamond, title: 'Official source', subtitle: 'Colour for the level, never a level word'),
        _keyRowBuilder(icon: LucideIcons.circle, title: 'Community report', subtitle: 'Colour is the category. Always Unverified'),
        _keyRowBuilder(icon: LucideIcons.shield, title: 'ALRT Assessment', subtitle: 'Named sources. Never restates a warning'),
        SizedBox(height: 20.spMin),
        _labelBuilder('COLOUR SHOWS SEVERITY'),
        SizedBox(height: 12.spMin),
        _seriousnessBuilder(),
        SizedBox(height: 20.spMin),
        _labelBuilder('ON THE MAP'),
        SizedBox(height: 12.spMin),
        _onTheMapBuilder(),
        SizedBox(height: 20.spMin),
        _labelBuilder('COMMUNITY REPORTS WEAR THEIR CATEGORY'),
        SizedBox(height: 12.spMin),
        Wrap(spacing: 7.spMin, runSpacing: 7.spMin,
          children: [for (final category in categories) CategoryFilterChip(category: category, isSelected: true)]),
      ],
    );
  }

  Widget _labelBuilder(final String text) => Text(text,
    style: TextStyle(fontSize: 10.5.spMin, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: _label));

  Widget _keyRowBuilder({required final IconData icon, required final String title, required final String subtitle}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.spMin),
      child: Row(children: [
        Container(width: 38.spMin, height: 38.spMin, alignment: Alignment.center,
          decoration: BoxDecoration(color: _tile, borderRadius: BorderRadius.circular(11.spMin)),
          child: HazardShapeBadge.outlineGlyph(icon: icon, size: 20.spMin)),
        SizedBox(width: 12.spMin),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13.5.spMin, fontWeight: FontWeight.w700, color: _ink)),
          SizedBox(height: 2.spMin),
          Text(subtitle, style: TextStyle(fontSize: 12.spMin, color: _softInk, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _seriousnessBuilder() {
    const bands = [AppColors.info, AppColors.advice, AppColors.watchAndAct, AppColors.emergency];
    final awsWords = [SeverityLabels.advice(), SeverityLabels.watchAndAct(), SeverityLabels.emergency()];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Expanded(child: SizedBox.shrink()),
        for (final word in awsWords) Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(word, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.spMin, fontWeight: FontWeight.w700, height: 1.2, color: _ink)),
          SizedBox(height: 3.spMin),
          Text('▲', style: TextStyle(fontSize: 8.spMin, height: 1.2, color: _softInk)),
        ])),
      ]),
      SizedBox(height: 4.spMin),
      Row(children: [for (final color in bands) Expanded(child: _segmentBuilder(color))]),
      SizedBox(height: 8.spMin),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Less serious', style: TextStyle(fontSize: 10.5.spMin, color: _softInk)),
        Text('More serious', style: TextStyle(fontSize: 10.5.spMin, color: _softInk)),
      ]),
      SizedBox(height: 8.spMin),
      Text('Colour shows severity. Official alerts use the same colours; only AWS writes its level in words.',
        style: TextStyle(fontSize: 11.spMin, height: 1.45, color: _softInk)),
    ]);
  }

  Widget _onTheMapBuilder() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('The picture inside a pin says what happened. The outline colour says how serious.',
        style: TextStyle(fontSize: 12.spMin, height: 1.45, color: _softInk)),
      SizedBox(height: 12.spMin),
      Row(children: [
        _clusterPill('4', AppColors.black), SizedBox(width: 8.spMin),
        _clusterPill('8', AppColors.watchAndAct), SizedBox(width: 8.spMin),
        _clusterPill('3', AppColors.emergency), SizedBox(width: 12.spMin),
        Expanded(child: Text('A number is a group of alerts. Orange or red means a serious warning is inside. Tap to zoom in.',
          style: TextStyle(fontSize: 11.spMin, height: 1.45, color: _softInk))),
      ]),
    ]);
  }

  Widget _clusterPill(final String label, final Color color) => Container(
    width: 32.spMin, height: 32.spMin, alignment: Alignment.center,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    child: Text(label, style: TextStyle(fontSize: 13.spMin, fontWeight: FontWeight.w800, color: AppColors.white)));

  Widget _segmentBuilder(final Color color) => Container(
    height: 12.spMin, margin: EdgeInsets.symmetric(horizontal: 2.spMin),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)));
}
