import 'package:flutter/material.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/notification/providers/manage_notifications_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/providers/states/main_categories_provider_state.dart';
import 'package:hazard_app/features/shared/views/widgets/category_filter_chip.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The same section-card shape and rust (#B84500) uppercase label the
/// ALRT feed's own "ALRT Filters" sheet uses for every section
/// (hazard_filters_bottomsheet_content.dart), so this screen reads as
/// that same filter, not a separate generic settings list.
const _sectionLabelColor = Color(0xFFB84500);

/// Selected level tile fill and border (the same pair the Me board uses
/// for a done step).
const _selectedTile = Color(0xFFE6F7EC);
const _selectedBorder = Color(0xFF16A34A);

/// The three one-tap levels (Notifications board, 12 Oct 2026). Each is a
/// preset over the five type flags; the switches under TYPES fine-tune
/// the result, and the level shown is always derived from the flags, so
/// a hand-tuned mix still reads as the nearest level.
enum NotificationLevel {
  /// Every official source, no community reports.
  officialOnly,

  /// Every official source plus community reports.
  officialAndCommunity,

  /// Emergency Warning (AWS) only.
  quiet,
}

/// The level [settings] currently amount to: quiet when only Emergency
/// Warning is on, "official and community" when community reports are
/// on, else "official only".
NotificationLevel notificationLevelOf(final PushNotificationSettings settings) {
  final onlyEmergency = settings.awsEmergency &&
      !settings.awsWatchAndAct &&
      !settings.awsAdvice &&
      !settings.officialNonAws &&
      !settings.userReported;
  if (onlyEmergency) return NotificationLevel.quiet;
  if (settings.userReported) return NotificationLevel.officialAndCommunity;
  return NotificationLevel.officialOnly;
}

/// [current] with the type flags set for [level]. Categories are left as
/// they are; Emergency Warning (AWS) is always on.
PushNotificationSettings settingsForLevel(
  final PushNotificationSettings current,
  final NotificationLevel level,
) {
  return switch (level) {
    NotificationLevel.quiet => current.copyWith(
        awsEmergency: true,
        awsWatchAndAct: false,
        awsAdvice: false,
        officialNonAws: false,
        userReported: false,
      ),
    NotificationLevel.officialOnly => current.copyWith(
        awsEmergency: true,
        awsWatchAndAct: true,
        awsAdvice: true,
        officialNonAws: true,
        userReported: false,
      ),
    NotificationLevel.officialAndCommunity => current.copyWith(
        awsEmergency: true,
        awsWatchAndAct: true,
        awsAdvice: true,
        officialNonAws: true,
        userReported: true,
      ),
  };
}

/// The LEVEL, TYPES and CATEGORIES cards of the Notifications screen. Not
/// a scroll view itself: the screen owns the one scroll.
class ManagePushNotificationsList extends ConsumerStatefulWidget {
  const ManagePushNotificationsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManagePushNotificationsListState();
}

class _ManagePushNotificationsListState
    extends ConsumerState<ManagePushNotificationsList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _levelSection(),
          16.hSizedBox,
          _alertTypesSection(),
          16.hSizedBox,
          _categoriesSection(),
        ],
      ),
    );
  }

  /// The shared section-card shape: a white rounded card, the locked V3
  /// rust uppercase label, a grey subtitle, then [child] - matching
  /// HazardFiltersBottomsheetContent._sectionContainerBuilder exactly, so
  /// a section here and a section in the feed's own filter sheet read as
  /// the same design, not two different screens.
  Widget _sectionContainerBuilder({
    required final String title,
    required final String subtitle,
    required final Widget child,
    final Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(18.spMin),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: _sectionLabelColor,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
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
          20.hSizedBox,
          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // LEVEL
  // ---------------------------------------------------------------

  Widget _levelSection() {
    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(
          providerOfManageNotifications.select(
            (s) => s.pushNotificationSettings,
          ),
        );
        final level = notificationLevelOf(settings);
        final notifier = ref.read(providerOfManageNotifications.notifier);

        void pick(final NotificationLevel chosen) {
          if (chosen == level) return;
          notifier.updatePushNotificationSettings(
            settingsForLevel(settings, chosen),
          );
        }

        return _sectionContainerBuilder(
          title: 'Level',
          subtitle: 'One tap sets every switch below.',
          child: Column(
            children: [
              _levelCard(
                title: 'Official warnings only',
                description:
                    'Emergency, Watch and Act, Advice and other official '
                    'alerts. No community reports.',
                selected: level == NotificationLevel.officialOnly,
                onTap: () => pick(NotificationLevel.officialOnly),
              ),
              10.hSizedBox,
              _levelCard(
                title: 'Official and community',
                description:
                    'Everything official, plus reports from people nearby.',
                selected: level == NotificationLevel.officialAndCommunity,
                onTap: () => pick(NotificationLevel.officialAndCommunity),
              ),
              10.hSizedBox,
              _levelCard(
                title: 'Keep it quiet',
                description: 'Emergency Warning (AWS) only. Nothing else.',
                selected: level == NotificationLevel.quiet,
                onTap: () => pick(NotificationLevel.quiet),
              ),
            ],
          ),
        );
      },
    );
  }

  /// A radio card: title, one line, and a 22 px radio at the right. The
  /// selected one fills green with a green border.
  Widget _levelCard({
    required final String title,
    required final String description,
    required final bool selected,
    required final VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.spMin),
        decoration: BoxDecoration(
          color: selected ? _selectedTile : AppColors.extraLightGrey,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(
            color: selected ? _selectedBorder : AppColors.lightGrey,
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
                      height: 1.2,
                    ),
                  ),
                  3.hSizedBox,
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      color: AppColors.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.spMin),
            _radioBuilder(selected: selected),
          ],
        ),
      ),
    );
  }

  Widget _radioBuilder({required final bool selected}) {
    return Container(
      width: 22.spMin,
      height: 22.spMin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _selectedBorder : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: const Color(0xFFD9D6D0), width: 2.0),
      ),
      child: selected
          ? Icon(LucideIcons.check, size: 14.spMin, color: Colors.white)
          : null,
    );
  }

  // ---------------------------------------------------------------
  // TYPES
  // ---------------------------------------------------------------

  Widget _alertTypesSection() {
    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(
          providerOfManageNotifications.select(
            (s) => s.pushNotificationSettings,
          ),
        );
        final notifier = ref.read(providerOfManageNotifications.notifier);

        // Emergency Warning (AWS) is always on: every save from here
        // carries awsEmergency true, whatever the stored flag said.
        void save(final PushNotificationSettings next) {
          notifier.updatePushNotificationSettings(
            next.copyWith(awsEmergency: true),
          );
        }

        return _sectionContainerBuilder(
          title: 'Types',
          subtitle: 'Which alerts can send you a push.',
          child: Column(
            children: [
              // The four bands mirror how alerts render on the front screen
              // (locked hexes; shapes carry the source system there).
              _filterToggleCard(
                title: 'Emergency Warning (AWS)',
                description: 'Immediate danger. Act now.',
                isEnabled: true,
                alwaysOn: true,
                color: AlertCardStyle.bandCritical,
              ),
              10.hSizedBox,
              _filterToggleCard(
                title: 'Watch and Act (AWS)',
                description: 'Conditions are changing. Prepare.',
                isEnabled: settings.awsWatchAndAct,
                onToggle: (value) =>
                    save(settings.copyWith(awsWatchAndAct: value)),
                color: AlertCardStyle.bandAction,
              ),
              10.hSizedBox,
              _filterToggleCard(
                title: 'Advice (AWS)',
                description: 'Stay informed. Watch conditions.',
                isEnabled: settings.awsAdvice,
                onToggle: (value) => save(settings.copyWith(awsAdvice: value)),
                color: AlertCardStyle.bandMonitor,
              ),
              10.hSizedBox,
              _filterToggleCard(
                title: 'Other official alerts',
                description: 'State agencies, global feeds and ALRT Intel.',
                isEnabled: settings.officialNonAws,
                onToggle: (value) =>
                    save(settings.copyWith(officialNonAws: value)),
                color: AlertCardStyle.bandInfo,
              ),
              10.hSizedBox,
              _filterToggleCard(
                title: 'Community reports',
                description: 'From people nearby. Unverified.',
                isEnabled: settings.userReported,
                onToggle: (value) =>
                    save(settings.copyWith(userReported: value)),
                color: const Color(0xFFC233DB),
              ),
            ],
          ),
        );
      },
    );
  }

  /// A single Alert Type row, inside the shared section card. Same
  /// tinted-when-active / neutral-when-off language as the feed's own
  /// "Show alerts from" switch rows - a border and background tint carry
  /// the state, not a second competing shadow. An [alwaysOn] row shows an
  /// "Always on" pill instead of a switch and cannot be tapped off.
  Widget _filterToggleCard({
    required final String title,
    required final String description,
    required final bool isEnabled,
    required final Color color,
    final ValueChanged<bool>? onToggle,
    final bool alwaysOn = false,
  }) {
    return GestureDetector(
      onTap: alwaysOn || onToggle == null ? null : () => onToggle(!isEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.spMin),
        decoration: BoxDecoration(
          color: isEnabled
              ? color.withValues(alpha: 0.08)
              : AppColors.extraLightGrey,
          borderRadius: BorderRadius.circular(14.spMin),
          border: Border.all(
            color: isEnabled
                ? color.withValues(alpha: 0.4)
                : AppColors.lightGrey,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8.spMin,
              height: 8.spMin,
              margin: EdgeInsets.only(right: 10.spMin),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      height: 1.2,
                    ),
                  ),
                  3.hSizedBox,
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (alwaysOn)
              _alwaysOnPill()
            else if (onToggle != null)
              _customToggleSwitch(
                isEnabled: isEnabled,
                onToggle: onToggle,
                activeColor: AppColors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _alwaysOnPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.spMin, vertical: 5.spMin),
      decoration: BoxDecoration(
        color: _selectedTile,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _selectedBorder),
      ),
      child: Text(
        'Always on',
        style: TextStyle(
          fontSize: 11.spMin,
          fontWeight: FontWeight.w800,
          color: _selectedBorder,
        ),
      ),
    );
  }

  Widget _customToggleSwitch({
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
          borderRadius: BorderRadius.circular(13.r),
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
                  borderRadius: BorderRadius.circular(11.r),
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

  // ---------------------------------------------------------------
  // CATEGORIES
  // ---------------------------------------------------------------

  Widget _categoriesSection() {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesState = ref.watch(
          providerOfMainCategories.select(
            (value) => value.getMainCategoriesState,
          ),
        );

        final isAnyCategoryEnabled = ref.watch(
          providerOfManageNotifications.select(
            (s) => s.pushNotificationSettings.subscribedCategoryIds.isNotEmpty,
          ),
        );

        return categoriesState.when(
          initial: () => const SizedBox.shrink(),
          loading: () => _sectionContainerBuilder(
            title: 'Categories',
            subtitle: 'Which hazard categories reach you.',
            child: SizedBox(
              height: 50.spMin,
              child: Center(
                child: SizedBox(
                  width: 20.spMin,
                  height: 20.spMin,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                  ),
                ),
              ),
            ),
          ),
          success: (cats) {
            if (cats.isEmpty) return const SizedBox.shrink();
            final filterProvider = ref.read(
              providerOfManageNotifications.notifier,
            );

            return _sectionContainerBuilder(
              title: 'Categories',
              subtitle: 'Which hazard categories reach you. Tap to toggle.',
              trailing: _customToggleSwitch(
                isEnabled: isAnyCategoryEnabled,
                onToggle: (_) {
                  if (isAnyCategoryEnabled) {
                    filterProvider.updateSelectedCategories({});
                  } else {
                    filterProvider.updateSelectedCategories(
                      cats.map((e) => e.id).toSet(),
                    );
                  }
                },
                activeColor: AppColors.green,
              ),
              // Same pill as the ALRT feed filter, so a category reads
              // identically wherever it is offered (it draws its glyph).
              child: Wrap(
                spacing: 10.spMin,
                runSpacing: 10.spMin,
                children: cats
                    .map((category) => _categoryChipBuilder(category))
                    .toList(),
              ),
            );
          },
          error: (error) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _categoryChipBuilder(final HazardCategory category) {
    return Consumer(
      builder: (context, ref, child) {
        final isSelected = ref.watch(
          providerOfManageNotifications.select(
            (s) => s.pushNotificationSettings.subscribedCategoryIds.contains(
              category.id,
            ),
          ),
        );

        return CategoryFilterChip(
          category: category,
          isSelected: isSelected,
          onToggle: (value) => ref
              .read(providerOfManageNotifications.notifier)
              .toggleCategory(category.id),
        );
      },
    );
  }
}
