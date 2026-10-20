import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/home_screen_widget/widget_pinning_service.dart';
import 'package:hazard_app/features/profile/providers/widget_step_provider.dart';
import 'package:hazard_app/features/profile/views/widgets/profile_page_kit.dart';
import 'package:hazard_app/others/app_colors.dart';

/// "Home screen widgets", as on the prototype "Widgets" board: a white
/// header ("Nothing is ever sent from a widget. A tap opens the app."),
/// labelled previews of each widget look (Emergency Warning, Near you
/// small, Family, Family SOS), the rules note, then "Add to home screen".
///
/// The previews are illustrations of the layouts only; the live widgets
/// are drawn natively (ios/AlrtWidget and the Android res layouts).
/// Opening this screen finishes the "Add a widget" setup step, because the
/// OS never tells the app whether a widget was placed.
class AddWidgetScreen extends ConsumerStatefulWidget {
  const AddWidgetScreen({super.key});

  static const route = '/add-widget';

  @override
  ConsumerState<AddWidgetScreen> createState() => _AddWidgetScreenState();
}

class _AddWidgetScreenState extends ConsumerState<AddWidgetScreen> {
  static const _emergencyStart = Color(0xFFC8102E);
  static const _emergencyEnd = Color(0xFF7A0012);
  static const _okGreen = Color(0xFF16A34A);
  static const _amber = Color(0xFFB45309);

  bool _canPin = false;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(providerOfWidgetStep.notifier).markDone());
    _checkPinSupport();
  }

  Future<void> _checkPinSupport() async {
    final supported = await WidgetPinningService.isPinSupported();
    if (!mounted) return;
    setState(() => _canPin = supported);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfilePageKit.page,
      body: Column(
        children: [
          const ProfilePageHeader(
            title: 'Home screen widgets',
            subtitle: 'Nothing is ever sent from a widget. A tap opens the app.',
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 32.spMin),
              children: [
                const ProfileSectionLabel(
                  'Emergency Warning (dark red, Critical only)',
                ),
                SizedBox(height: 10.spMin),
                _emergencyPreview(),
                SizedBox(height: 14.spMin),
                const ProfileSectionLabel('Near you, small'),
                SizedBox(height: 10.spMin),
                Row(
                  children: [
                    Expanded(
                      child: _smallPreview(
                        icon: Icons.warning_rounded,
                        iconColor: AppColors.emergency,
                        kicker: 'EMERGENCY WARNING',
                        kickerColor: AppColors.emergency,
                        title: 'Bushfire near you',
                        footer: '8.4 km · 9:26 am',
                      ),
                    ),
                    SizedBox(width: 10.spMin),
                    Expanded(
                      child: _smallPreview(
                        icon: Icons.check_rounded,
                        iconColor: _okGreen,
                        title: 'Nothing near you',
                        body: 'Home and where you are, 5 km',
                        footer: 'as of 9:26 am',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.spMin),
                Row(
                  children: [
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 2,
                      child: _smallPreview(
                        icon: Icons.wifi_off_rounded,
                        iconColor: _amber,
                        title: "Couldn't check",
                        body: 'Last known: nothing near you',
                        footer: 'as of 8:10 am · tap to retry',
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
                SizedBox(height: 14.spMin),
                const ProfileSectionLabel('Family'),
                SizedBox(height: 10.spMin),
                _familyPreview(),
                SizedBox(height: 14.spMin),
                const ProfileSectionLabel('Family SOS (its own look)'),
                SizedBox(height: 10.spMin),
                _sosPreview(),
                SizedBox(height: 14.spMin),
                const ProfileNote(
                  'Your shapes, not emoji. Level word for AWS only. "Nothing '
                  'near you" is the quiet state. Initials only on the Family '
                  'widget: no photos or locations on a home screen. Up to 4 '
                  'groups stack, SOS first.',
                ),
                SizedBox(height: 14.spMin),
                ProfileButton(
                  key: const Key('widget-add'),
                  label: 'Add to home screen',
                  onPressed: _openAddSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Android launchers that support pinning get one button per widget;
  /// everyone else gets the steps for their platform.
  void _openAddSheet() {
    showProfileSheet<void>(
      context: context,
      builder: (sheetContext) => [
        ProfileSheetTitle(
          title: 'Add to home screen',
          subtitle: _canPin
              ? 'Pick a widget. Your launcher will ask you to confirm.'
              : _manualInstructions(),
        ),
        if (_canPin) ...[
          ProfileButton(
            label: 'Nearby alerts widget',
            onPressed: () {
              Navigator.of(sheetContext).pop();
              WidgetPinningService.requestPin(PinnableWidget.alerts);
            },
          ),
          ProfileButton(
            label: 'Family widget',
            kind: ProfileButtonKind.secondary,
            onPressed: () {
              Navigator.of(sheetContext).pop();
              WidgetPinningService.requestPin(PinnableWidget.family);
            },
          ),
        ],
        ProfileButton(
          label: 'Close',
          kind: ProfileButtonKind.ghost,
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
      ],
    );
  }

  String _manualInstructions() {
    final isIos = !kIsWeb && Platform.isIOS;
    if (isIos) {
      return 'Touch and hold an empty spot on your home screen, tap the + '
          'button in the corner, search for ALRT, then choose the Nearby '
          'Alerts or Family widget and tap Add Widget.';
    }
    return 'Touch and hold an empty spot on your home screen, tap Widgets, '
        'find ALRT, then touch and hold the Nearby Alerts or Family widget '
        'and drop it where you want it.';
  }

  // ---------------------------------------------------------------
  // Previews (illustrations of the native layouts)
  // ---------------------------------------------------------------

  BoxDecoration _tileDecoration() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      );

  Widget _emergencyPreview() {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_emergencyStart, _emergencyEnd],
        ),
        borderRadius: BorderRadius.circular(22.spMin),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4DC8102E),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                size: 14.spMin,
                color: AppColors.white,
              ),
              SizedBox(width: 6.spMin),
              Expanded(
                child: Text(
                  'EMERGENCY WARNING · AGENCY',
                  style: TextStyle(
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: AppColors.white,
                  ),
                ),
              ),
              Text(
                'as of 9:26 am',
                style: TextStyle(
                  fontSize: 11.spMin,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.spMin),
          Text(
            'Bushfire near you',
            style: TextStyle(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            '8.4 km · Leave now if the way is clear',
            style: TextStyle(
              fontSize: 13.spMin,
              color: AppColors.white.withValues(alpha: 0.92),
            ),
          ),
          SizedBox(height: 14.spMin),
          Row(
            children: [
              Expanded(
                child: Text(
                  '+2 other alerts near you',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.spMin,
                  vertical: 6.spMin,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
                child: Text(
                  'What to do',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w700,
                    color: _emergencyEnd,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallPreview({
    required final IconData icon,
    required final Color iconColor,
    required final String title,
    required final String footer,
    final String? kicker,
    final Color? kickerColor,
    final String? body,
  }) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: EdgeInsets.all(14.spMin),
        decoration: _tileDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NEAR YOU',
              style: TextStyle(
                fontSize: 10.spMin,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: ProfilePageKit.muted,
              ),
            ),
            SizedBox(height: 8.spMin),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20.spMin, color: iconColor),
                SizedBox(width: 6.spMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (kicker != null)
                        Text(
                          kicker,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.spMin,
                            fontWeight: FontWeight.w800,
                            color: kickerColor ?? AppColors.ink,
                          ),
                        ),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.spMin,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (body != null) ...[
              SizedBox(height: 6.spMin),
              Text(
                body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.spMin,
                  color: ProfilePageKit.muted,
                ),
              ),
            ],
            const Spacer(),
            Text(
              footer,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.spMin, color: ProfilePageKit.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _familyPreview() {
    const people = [
      ('SN', 'Sarah', 'Checked in', Color(0xFFE8622A)),
      ('JN', 'James', 'Checked in', Color(0xFF3D3DDF)),
      ('EN', 'Emma', 'Near', Color(0xFFC233DB)),
      ('TN', 'Tom', 'Checked in', Color(0xFF0A7F4F)),
      ('GN', 'Gran', 'Not yet', Color(0xFF9A9AA2)),
    ];
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: _tileDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, size: 14.spMin, color: FamilyColors.indigo),
              SizedBox(width: 6.spMin),
              Expanded(
                child: Text(
                  'YOUR GROUP',
                  style: TextStyle(
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: FamilyColors.indigo,
                  ),
                ),
              ),
              Text(
                '3 of 5 checked in · 9:42 am',
                style: TextStyle(fontSize: 11.spMin, color: ProfilePageKit.muted),
              ),
            ],
          ),
          SizedBox(height: 12.spMin),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final p in people)
                Column(
                  children: [
                    CircleAvatar(
                      radius: 18.spMin,
                      backgroundColor: p.$4,
                      child: Text(
                        p.$1,
                        style: TextStyle(
                          fontSize: 12.spMin,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.spMin),
                    Text(
                      p.$2,
                      style: TextStyle(
                        fontSize: 10.spMin,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      p.$3,
                      style: TextStyle(
                        fontSize: 9.spMin,
                        fontWeight: FontWeight.w700,
                        color: p.$3 == 'Checked in'
                            ? FamilyColors.checkedInInk
                            : p.$3 == 'Near'
                                ? FamilyColors.amber
                                : ProfilePageKit.muted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sosPreview() {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        gradient: FamilyColors.sosHeaderGradient,
        borderRadius: BorderRadius.circular(22.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOS · YOUR GROUP',
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 6.spMin),
          Text(
            'Emma sent an SOS',
            style: TextStyle(
              fontSize: 18.spMin,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 4.spMin),
          Text(
            '4 min ago · tap to open',
            style: TextStyle(
              fontSize: 12.spMin,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
