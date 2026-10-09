import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/family/views/widgets/family_header_surface.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Lets the member choose how much of their location the circle can see.
class FamilySharingLevelScreen extends ConsumerWidget {
  const FamilySharingLevelScreen({super.key});

  static const route = '/family-sharing';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(providerOfFamily.select((s) => s.circle?.me));
    final updateState = ref.watch(
      providerOfFamily.select((s) => s.memberUpdateState),
    );

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      appBar: const FamilyAppBar(title: 'Your sharing level'),
      body: ListView(
        padding: EdgeInsets.all(20.spMin),
        children: [
          Text(
            'Each member controls their own. Change it anytime, '
            'no one is tracked without saying yes.',
            style: TextStyle(fontSize: 13.spMin, color: AppColors.grey),
          ),
          SizedBox(height: 16.spMin),
          for (final level in FamilySharingLevel.values)
            _levelCardBuilder(
              context: context,
              ref: ref,
              level: level,
              isSelected: me?.sharingLevel == level,
              isBusy: updateState.isLoading,
            ),
        ],
      ),
    );
  }

  Widget _levelCardBuilder({
    required final BuildContext context,
    required final WidgetRef ref,
    required final FamilySharingLevel level,
    required final bool isSelected,
    required final bool isBusy,
  }) {
    final (title, description, icon) = switch (level) {
      FamilySharingLevel.precise => (
        'Precise',
        'Snapshots you share show street-level accuracy.',
        LucideIcons.locateFixed,
      ),
      FamilySharingLevel.approximate => (
        'Approximate',
        'Only a general area label, never a precise pin.',
        LucideIcons.mapPin,
      ),
      FamilySharingLevel.alertsOnly => (
        'Alerts only',
        'No location shown, but the family is still alerted when a serious hazard is detected near you.',
        LucideIcons.bellRing,
      ),
      FamilySharingLevel.off => (
        'Off',
        'Nothing is shared and no proximity alerts fire.',
        LucideIcons.eyeOff,
      ),
    };

    return GestureDetector(
      onTap: isBusy
          ? null
          : () =>
                ref.read(providerOfFamily.notifier).updateSharingLevel(level),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.spMin),
        padding: EdgeInsets.all(16.spMin),
        decoration: BoxDecoration(
          color: isSelected ? FamilyColors.indigoLight : Colors.white,
          borderRadius: BorderRadius.circular(18.spMin),
          border: Border.all(
            color: isSelected
                ? FamilyColors.indigo
                : Colors.grey.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.spMin,
              height: 42.spMin,
              decoration: BoxDecoration(
                color: isSelected
                    ? FamilyColors.indigo
                    : const Color(0xFFF0F0F2),
                borderRadius: BorderRadius.circular(12.spMin),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.grey,
                size: 20.spMin,
              ),
            ),
            SizedBox(width: 14.spMin),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.spMin),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12.spMin, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: FamilyColors.indigo,
                size: 22.spMin,
              ),
          ],
        ),
      ),
    );
  }
}
