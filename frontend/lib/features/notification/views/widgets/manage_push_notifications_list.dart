import 'package:flutter/material.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/providers/manage_notifications_provider.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';
import 'package:hazard_app/features/shared/providers/main_categories_provider.dart';
import 'package:hazard_app/features/shared/providers/states/main_categories_provider_state.dart';
import 'package:hazard_app/features/shared/views/widgets/category_filter_chip.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The same section-card shape and rust (#B84500) uppercase label the
/// ALRT feed's own "ALRT Filters" sheet uses for every section
/// (hazard_filters_bottomsheet_content.dart), so this screen reads as
/// that same filter, not a separate generic settings list.
const _sectionLabelColor = Color(0xFFB84500);

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
    return _filtersContentBuilder();
  }

  Widget _filtersContentBuilder() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.hSizedBox,
          _alertTypesSection(),
          16.hSizedBox,
          _categoriesSection(),
          24.hSizedBox,
        ],
      ).pX(20.0),
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

  Widget _alertTypesSection() {
    return Consumer(
      builder: (context, ref, child) {
        final awsEmergency = ref.watch(
          providerOfManageNotifications.select(
            (s) => s.pushNotificationSettings.awsEmergency,
          ),
        );
        final awsWatchAndAct = ref.watch(
          providerOfManageNotifications.select(
            (s) => s.pushNotificationSettings.awsWatchAndAct,
          ),
        );
        final awsAdvice = ref.watch(
          providerOfManageNotifications.select(
            (s) => s.pushNotificationSettings.awsAdvice,
          ),
        );
        final officialNonAws = ref.watch(
          providerOfManageNotifications.select(
            (s) => s.pushNotificationSettings.officialNonAws,
          ),
        );
        final isUserReported = ref.watch(
          providerOfManageNotifications.select(
            (s) => s.pushNotificationSettings.userReported,
          ),
        );

        final isAnyAlertTypeEnabled =
            awsEmergency ||
            awsWatchAndAct ||
            awsAdvice ||
            officialNonAws ||
            isUserReported;

        final filterProvider = ref.read(
          providerOfManageNotifications.notifier,
        );

        return _sectionContainerBuilder(
          title: 'Alert Types',
          subtitle: 'Which severity bands can send you a push, on this device.',
          trailing: _customToggleSwitch(
            isEnabled: isAnyAlertTypeEnabled,
            onToggle: (_) {
              if (isAnyAlertTypeEnabled) {
                filterProvider.updateAwsEmergency(false);
                filterProvider.updateAwsWatchAndAct(false);
                filterProvider.updateAwsAdvice(false);
                filterProvider.updateOfficialNonAws(false);
                filterProvider.updateUserReported(false);
              } else {
                filterProvider.updateAwsEmergency(true);
                filterProvider.updateAwsWatchAndAct(true);
                filterProvider.updateAwsAdvice(true);
                filterProvider.updateOfficialNonAws(true);
                filterProvider.updateUserReported(true);
              }
            },
            activeColor: AppColors.green.withValues(alpha: 0.6),
          ),
          child: Column(
            children: [
              // The four bands mirror how alerts render on the front screen
              // (locked hexes; shapes carry the source system there).
              _filterToggleCard(
                title: 'Critical',
                description: 'Emergency warnings - immediate danger',
                isEnabled: awsEmergency,
                onToggle: (value) {
                  filterProvider.updateAwsEmergency(value);
                },
                color: AlertCardStyle.bandCritical,
              ),
              10.hSizedBox,
              _filterToggleCard(
                title: 'Action',
                description: 'Conditions are changing - act now',
                isEnabled: awsWatchAndAct,
                onToggle: (value) {
                  filterProvider.updateAwsWatchAndAct(value);
                },
                color: AlertCardStyle.bandAction,
              ),
              10.hSizedBox,
              _filterToggleCard(
                title: 'Monitor',
                description: 'Stay informed and watch conditions',
                isEnabled: awsAdvice,
                onToggle: (value) {
                  filterProvider.updateAwsAdvice(value);
                },
                color: AlertCardStyle.bandMonitor,
              ),
              10.hSizedBox,
              _filterToggleCard(
                title: 'Info',
                description: 'Official updates and general information',
                isEnabled: officialNonAws,
                onToggle: (value) {
                  filterProvider.updateOfficialNonAws(value);
                },
                color: AlertCardStyle.bandInfo,
              ),
              10.hSizedBox,
              _filterToggleCard(
                title: 'Community reports',
                description: 'Posted by people nearby - unverified',
                isEnabled: isUserReported,
                onToggle: (value) {
                  filterProvider.updateUserReported(value);
                },
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
  /// the state, not a second competing shadow.
  Widget _filterToggleCard({
    required final String title,
    required final String description,
    required final bool isEnabled,
    required final ValueChanged<bool> onToggle,
    required final Color color,
  }) {
    return GestureDetector(
      onTap: () => onToggle(!isEnabled),
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
            _customToggleSwitch(
              isEnabled: isEnabled,
              onToggle: onToggle,
              activeColor: AppColors.green.withValues(alpha: 0.6),
            ),
          ],
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
            subtitle: 'Same categories, colours and icons as the ALRT feed.',
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
              subtitle:
                  'Same categories, colours and icons as the ALRT feed. Tap to toggle.',
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
                activeColor: AppColors.green.withValues(alpha: 0.6),
              ),
              // Same pill as the ALRT feed filter, so a category reads
              // identically wherever it is offered.
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
