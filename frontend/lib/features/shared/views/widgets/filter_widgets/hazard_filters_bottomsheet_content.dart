import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/base_bottomsheet_v2.dart';
import 'package:hazard_app/features/shared/views/widgets/category_filter_chip.dart';
import 'package:hazard_app/features/shared/views/widgets/hazard_shape_badge.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HazardFiltersBottomsheetContent extends ConsumerStatefulWidget {
  const HazardFiltersBottomsheetContent({
    super.key,
    required this.filtersKey,
    this.onFiltersUpdated,
  });

  /// The key to identify the specific hazard filters instance.
  final String filtersKey;

  /// Callback when any filter is updated.
  final void Function()? onFiltersUpdated;

  @override
  ConsumerState<HazardFiltersBottomsheetContent> createState() =>
      _HazardFiltersBottomsheetContentState();
}

class _HazardFiltersBottomsheetContentState
    extends ConsumerState<HazardFiltersBottomsheetContent> {
  late final _filtersProvider = providerOfHazardFilters(widget.filtersKey);

  /// The switch colour (product owner, 12 Oct 2026: the green toggle).
  static const _toggleOn = AppColors.green;

  @override
  Widget build(BuildContext context) {
    return BaseBottomsheetV2(
      // Opens to a little over half the screen, like the Ask ALRT sheet,
      // and can be pulled up for the full list (owner, 8 Sep 2026: not
      // full screen on open). The sheet itself stays light: white card on
      // the light grey body in both themes.
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      safeAreaBottom: false,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerBuilder(),
          Expanded(
            child: Container(
              color: AppColors.extraLightGrey,
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.spMin,
                ),
                child: Column(
                  children: [
                    20.hSizedBox,
                    // Who is speaking, how serious, then what kind. The
                    // key (shapes and colours) lives in the map's own Map
                    // key sheet, not here.
                    _whoIsSpeakingSection(),
                    16.hSizedBox,
                    _howSeriousSection(),
                    16.hSizedBox,
                    _categoriesSection(),
                    SafeArea(child: 20.hSizedBox),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// White header: drag handle, "Filters", one line on what the sheet
  /// controls, and Reset All as a plain text button.
  Widget _headerBuilder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.spMin),
          topRight: Radius.circular(20.spMin),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.spMin, 10.spMin, 12.spMin, 14.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.spMin,
              height: 4.spMin,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2.spMin),
              ),
            ),
          ),
          12.hSizedBox,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 24.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.2,
                  ),
                ),
              ),
              TextButton(
                onPressed: _handleResetAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.orange,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.spMin,
                    vertical: 4.spMin,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Reset All',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
          4.hSizedBox,
          Padding(
            padding: EdgeInsets.only(right: 8.spMin),
            child: Text(
              'What shows on the map and in Alerts. Emergency Warnings are '
              'never hidden.',
              style: TextStyle(
                fontSize: 15.spMin,
                height: 1.4,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The four sources, each behind its outline shape (product owner, 12 Oct
  /// 2026): triangle, diamond, circle, shield. The square is gone; global
  /// feeds show as Official.
  Widget _whoIsSpeakingSection() {
    return Consumer(
      builder: (context, ref, child) {
        final awsAdvice = ref.watch(
          _filtersProvider.select((value) => value.awsAdvice),
        );
        final awsWatchAndAct = ref.watch(
          _filtersProvider.select((value) => value.awsWatchAndAct),
        );
        final officialAlerts = ref.watch(
          _filtersProvider.select((value) => value.officialNonAws),
        );
        final userAlerts = ref.watch(
          _filtersProvider.select((value) => value.userReported),
        );
        final alrtAssessment = ref.watch(
          _filtersProvider.select((value) => value.alrtIntel),
        );

        return _sectionContainerBuilder(
          title: 'Who is speaking',
          subtitle: 'Shape says who. The same sources as the map.',
          child: Column(
            children: [
              // AWS has no switch of its own on the server: its yellow and
              // orange levels are the two switches below, and red never
              // hides. This row flips both of those together.
              _switchBuilder(
                icon: LucideIcons.triangle,
                title: 'AWS warnings',
                subtitle: 'Emergency Warnings always show',
                isEnabled: awsAdvice || awsWatchAndAct,
                onToggle: (value) {
                  final notifier = ref.read(_filtersProvider.notifier);
                  notifier.updateAwsAdvice(value);
                  notifier.updateAwsWatchAndAct(value);
                  widget.onFiltersUpdated?.call();
                },
              ),
              10.hSizedBox,
              _switchBuilder(
                icon: LucideIcons.diamond,
                title: 'Official sources',
                subtitle: 'State agencies, services and global feeds',
                isEnabled: officialAlerts,
                onToggle: (value) {
                  ref
                      .read(_filtersProvider.notifier)
                      .updateOfficialNonAws(value);
                  widget.onFiltersUpdated?.call();
                },
              ),
              10.hSizedBox,
              _switchBuilder(
                icon: LucideIcons.circle,
                title: 'Community reports',
                subtitle: 'From people nearby. Always Unverified',
                isEnabled: userAlerts,
                onToggle: (value) {
                  ref.read(_filtersProvider.notifier).updateUserReported(value);
                  widget.onFiltersUpdated?.call();
                },
              ),
              10.hSizedBox,
              _switchBuilder(
                icon: LucideIcons.shield,
                title: 'ALRT Assessment',
                subtitle: 'Named sources. Never restates a warning',
                isEnabled: alrtAssessment,
                onToggle: (value) {
                  ref.read(_filtersProvider.notifier).updateAlrtIntel(value);
                  widget.onFiltersUpdated?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// The four colours, named by colour and nothing else (product owner,
  /// 12 Oct 2026). Yellow and orange are the AWS Advice and Watch and Act
  /// switches, and the state applies the same switch to the matching band
  /// on official alerts. Red is never hidden. Grey has no switch of its
  /// own on the server, so it shows as always on while Official is on.
  Widget _howSeriousSection() {
    return Consumer(
      builder: (context, ref, child) {
        final awsWatchAndAct = ref.watch(
          _filtersProvider.select((value) => value.awsWatchAndAct),
        );
        final awsAdvice = ref.watch(
          _filtersProvider.select((value) => value.awsAdvice),
        );

        return _sectionContainerBuilder(
          title: 'How serious',
          subtitle: 'Colour says how serious. One colour, one meaning.',
          spacing: 6.0,
          child: Column(
            children: [
              _colourRowBuilder(
                swatch: AppColors.info,
                title: 'Grey',
                subtitle: 'Official, lowest level',
                isEnabled: null,
              ),
              _dividerBuilder(),
              _colourRowBuilder(
                swatch: AppColors.advice,
                title: 'Yellow',
                subtitle: 'AWS Advice and official equivalents',
                isEnabled: awsAdvice,
                onToggle: (value) {
                  ref.read(_filtersProvider.notifier).updateAwsAdvice(value);
                  widget.onFiltersUpdated?.call();
                },
              ),
              _dividerBuilder(),
              _colourRowBuilder(
                swatch: AppColors.watchAndAct,
                title: 'Orange',
                subtitle: 'AWS Watch and Act and official equivalents',
                isEnabled: awsWatchAndAct,
                onToggle: (value) {
                  ref
                      .read(_filtersProvider.notifier)
                      .updateAwsWatchAndAct(value);
                  widget.onFiltersUpdated?.call();
                },
              ),
              _dividerBuilder(),
              _colourRowBuilder(
                swatch: AppColors.emergency,
                title: 'Red',
                subtitle: 'AWS Emergency Warning and official equivalents',
                isEnabled: null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dividerBuilder() {
    return const Divider(color: AppColors.extraLightGrey, height: 0.0);
  }

  Widget _categoriesSection() {
    return Consumer(
      builder: (context, ref, child) {
        final categories = ref.watch(
          providerOfMainCategories.select(
            (value) => value.mainCategories,
          ),
        );
        final selectedCategories = ref.watch(
          _filtersProvider.select((value) => value.selectedCategoryIds),
        );
        return _sectionContainerBuilder(
          title: 'Categories',
          subtitle:
              'One category shown on every alert. Tap to toggle visibility.',
          child: Wrap(
            spacing: 10.spMin,
            runSpacing: 10.spMin,
            children: categories
                .map(
                  (category) => CategoryFilterChip(
                    category: category,
                    isSelected: selectedCategories.contains(category.id),
                    onToggle: (value) {
                      ref
                          .read(_filtersProvider.notifier)
                          .toggleCategory(category.id);
                      widget.onFiltersUpdated?.call();
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _sectionContainerBuilder({
    required final String title,
    required final String subtitle,
    required final Widget child,
    final double spacing = 20.0,
    final EdgeInsets? padding,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: padding ?? EdgeInsets.all(18.spMin),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.spMin),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The V3 section label: rust, uppercase, letter-spaced, the
          // same one every other section header in the app wears.
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.sectionLabel,
            ),
          ),
          5.hSizedBox,
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.spMin,
              height: 1.45,
              color: AppColors.grey,
            ),
          ),
          spacing.hSizedBox,
          child,
        ],
      ),
    );
  }

  /// One colour row: a 14 px rounded swatch, the colour's name, what it
  /// covers, and either a switch or the "Always on" pill ([isEnabled]
  /// null) for a colour that cannot be hidden.
  Widget _colourRowBuilder({
    required final Color swatch,
    required final String title,
    required final String subtitle,
    required final bool? isEnabled,
    final ValueChanged<bool>? onToggle,
  }) {
    final row = Row(
      children: [
        Container(
          width: 14.spMin,
          height: 14.spMin,
          decoration: BoxDecoration(
            color: swatch,
            borderRadius: BorderRadius.circular(4.spMin),
          ),
        ),
        12.wSizedBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.spMin,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              2.hSizedBox,
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
        8.wSizedBox,
        if (isEnabled == null || onToggle == null)
          _alwaysOnPillBuilder()
        else
          _togglerBuilder(
            isEnabled: isEnabled,
            onToggle: onToggle,
            activeColor: _toggleOn,
          ),
      ],
    ).pY(12.0);
    if (isEnabled == null || onToggle == null) return row;
    return row.onPressed(() => onToggle(!isEnabled));
  }

  Widget _alwaysOnPillBuilder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 5.spMin),
      decoration: BoxDecoration(
        color: _toggleOn.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Always on',
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          color: _toggleOn,
        ),
      ),
    );
  }

  /// One source row: its outline shape, the name, one line, and a switch.
  Widget _switchBuilder({
    required final IconData icon,
    required final String title,
    required final String subtitle,
    required final bool isEnabled,
    required final ValueChanged<bool> onToggle,
  }) {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: isEnabled
            ? _toggleOn.withValues(alpha: 0.06)
            : AppColors.transparent,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(
          color: isEnabled
              ? _toggleOn.withValues(alpha: 0.45)
              : AppColors.lightGrey,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34.spMin,
            height: 34.spMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.extraLightGrey,
              borderRadius: BorderRadius.circular(10.spMin),
            ),
            child: HazardShapeBadge.outlineGlyph(icon: icon, size: 18.spMin),
          ),
          12.wSizedBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                2.hSizedBox,
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          8.wSizedBox,
          _togglerBuilder(
            isEnabled: isEnabled,
            onToggle: onToggle,
            activeColor: _toggleOn,
          ),
        ],
      ),
    ).onPressed(() => onToggle(!isEnabled));
  }

  Widget _togglerBuilder({
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: () => onToggle(!isEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48.spMin,
        height: 26.spMin,
        decoration: BoxDecoration(
          color: isEnabled ? activeColor : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(13.spMin),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isEnabled ? 24.spMin : 2.spMin,
              top: 2.spMin,
              child: Container(
                width: 22.spMin,
                height: 22.spMin,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11.spMin),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleResetAll() {
    ref.read(_filtersProvider.notifier).resetAllFilters();
    widget.onFiltersUpdated?.call();
  }
}
