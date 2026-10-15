import 'package:flutter/material.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/notification/views/widgets/manage_push_notifications_list.dart';
import 'package:hazard_app/features/shared/views/widgets/filter_widgets/category_grid_picker.dart';
import 'package:hazard_app/features/shared/views/widgets/filter_widgets/severity_line.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/base_bottomsheet_v2.dart';
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
              'What shows on the map and in Alerts.',
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

  /// Who you hear from: the same four choices as Notifications, so one
  /// filter is learned once. Emergency warnings are never hidden. ALRT
  /// Assessment keeps its own switch underneath.
  Widget _whoIsSpeakingSection() {
    return Consumer(
      builder: (context, ref, child) {
        final f = ref.watch(_filtersProvider);
        final settings = PushNotificationSettings(
          awsEmergency: true,
          awsWatchAndAct: f.awsWatchAndAct,
          awsAdvice: f.awsAdvice,
          officialNonAws: f.officialNonAws,
          userReported: f.userReported,
        );
        final level = notificationLevelOf(settings);
        final notifier = ref.read(_filtersProvider.notifier);

        void pick(final NotificationLevel chosen) {
          final next = settingsForLevel(settings, chosen);
          notifier
            ..updateAwsAdvice(next.awsAdvice)
            ..updateAwsWatchAndAct(next.awsWatchAndAct)
            ..updateOfficialNonAws(next.officialNonAws)
            ..updateUserReported(next.userReported);
          widget.onFiltersUpdated?.call();
        }

        Widget choice(
          final String title,
          final NotificationLevel value, {
          final String? sub,
        }) {
          final selected = level == value;
          return Semantics(
            button: true,
            selected: selected,
            label: title,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => pick(value),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.spMin),
                constraints: BoxConstraints(minHeight: 52.spMin),
                padding: EdgeInsets.symmetric(
                  horizontal: 14.spMin,
                  vertical: 10.spMin,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.green.withValues(alpha: 0.10)
                      : AppColors.extraLightGrey,
                  borderRadius: BorderRadius.circular(14.spMin),
                  border: Border.all(
                    color: selected ? AppColors.green : AppColors.lightGrey,
                    width: selected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.spMin,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          if (sub != null) ...[
                            2.hSizedBox,
                            Text(
                              sub,
                              style: TextStyle(
                                fontSize: 12.spMin,
                                height: 1.3,
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: selected ? AppColors.green : AppColors.lightGrey,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _sectionContainerBuilder(
          title: 'Show',
          subtitle: 'Emergency warnings from official sources are always on. '
              'Pick what else shows.',
          child: Column(
            children: [
              // Emergency warnings can never be switched off, so they sit
              // on top as a row that is always ticked and locked: people
              // see the guarantee instead of reading about it.
              _alwaysOnRowBuilder(),
              8.hSizedBox,
              // "All alerts" first so the everything choice is obvious, and
              // every option says in one line what it shows; no shape icons
              // beside the levels (product owner, 16 Oct 2026).
              choice(
                'All alerts',
                NotificationLevel.officialAndCommunity,
                sub: 'Official alerts and reports from people nearby.',
              ),
              choice(
                'Official warnings only',
                NotificationLevel.officialOnly,
                sub: 'From agencies only. No community reports.',
              ),
              choice(
                'Community only',
                NotificationLevel.communityOnly,
                sub: 'Reports from people nearby, plus emergency warnings.',
              ),
              choice(
                'Keep it quiet',
                NotificationLevel.quiet,
                sub: 'Emergency warnings only.',
              ),
              4.hSizedBox,
              _switchBuilder(
                icon: LucideIcons.shield,
                title: 'ALRT Assessment',
                subtitle: 'Named sources. Never restates a warning',
                isEnabled: f.alrtIntel,
                onToggle: (value) {
                  notifier.updateAlrtIntel(value);
                  widget.onFiltersUpdated?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// "Emergency warnings: always on", ticked and locked. Not tappable.
  Widget _alwaysOnRowBuilder() {
    return Semantics(
      label: 'Emergency warnings, always on',
      child: Container(
        constraints: BoxConstraints(minHeight: 52.spMin),
        padding: EdgeInsets.symmetric(
          horizontal: 14.spMin,
          vertical: 10.spMin,
        ),
        decoration: BoxDecoration(
          color: AppColors.emergency.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(
            color: AppColors.emergency.withValues(alpha: 0.55),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency warnings',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  2.hSizedBox,
                  Text(
                    // Matches hazard_visibility_util: every active AWS
                    // level and every official critical alert bypass the
                    // filters below.
                    'Emergency warnings from official sources are always '
                    'on. You cannot switch these off.',
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.lock,
              size: 15.spMin,
              color: AppColors.mediumGrey,
            ),
            6.wSizedBox,
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.emergency,
            ),
          ],
        ),
      ),
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
          title: 'Colour shows severity',
          subtitle: 'Choose which colours show. Red emergency warnings '
              'always show.',
          spacing: 6.0,
          child: SeverityLine(
            advice: awsAdvice,
            watchAndAct: awsWatchAndAct,
            onChanged: (advice, watchAndAct) {
              ref.read(_filtersProvider.notifier)
                ..updateAwsAdvice(advice)
                ..updateAwsWatchAndAct(watchAndAct);
              widget.onFiltersUpdated?.call();
            },
          ),
        );
      },
    );
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
          subtitle: 'Choose the kinds of alerts to show.',
          spacing: 14.0,
          child: CategoryGridPicker(
            categories: categories,
            selectedIds: selectedCategories,
            onToggle: (category) {
              ref.read(_filtersProvider.notifier).toggleCategory(category.id);
              widget.onFiltersUpdated?.call();
            },
            onSelectAll: () {
              ref
                  .read(_filtersProvider.notifier)
                  .updateSelectedCategories(
                    categories.map((c) => c.id).toSet(),
                  );
              widget.onFiltersUpdated?.call();
            },
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
