import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/home_screen_widget/widget_pinning_service.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// "Add widget to your home screen" sheet.
///
/// Android with a supporting launcher: one tap per widget opens the system
/// pin dialog. iOS (or an unsupported launcher): step-by-step instructions,
/// since there is no pin API there.
Future<void> showAddWidgetSheet(final BuildContext context) async {
  final canPin = await WidgetPinningService.isPinSupported();
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.spMin, 18.spMin, 20.spMin, 20.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a widget to your home screen',
              style: TextStyle(
                fontSize: 17.spMin,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6.spMin),
            Text(
              canPin
                  ? 'Pick a widget — your launcher will ask you to confirm.'
                  : _manualInstructions(),
              style: TextStyle(
                fontSize: 12.5.spMin,
                height: 1.5,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 14.spMin),
            if (canPin) ...[
              _widgetTileBuilder(
                sheetContext,
                icon: LucideIcons.triangleAlert,
                color: AppColors.orange,
                title: 'Nearby Alerts widget',
                subtitle: 'Warnings near you, or a green all-clear',
                widget: PinnableWidget.alerts,
              ),
              SizedBox(height: 8.spMin),
              _widgetTileBuilder(
                sheetContext,
                icon: LucideIcons.users,
                color: const Color(0xFF5B5BD6),
                title: 'Family widget',
                subtitle: 'Your circle at a glance',
                widget: PinnableWidget.family,
              ),
            ],
          ],
        ),
      ),
    ),
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

Widget _widgetTileBuilder(
  final BuildContext sheetContext, {
  required final IconData icon,
  required final Color color,
  required final String title,
  required final String subtitle,
  required final PinnableWidget widget,
}) {
  return ListTile(
    onTap: () {
      Navigator.of(sheetContext).pop();
      WidgetPinningService.requestPin(widget);
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.spMin),
      side: BorderSide(color: AppColors.grey.withValues(alpha: 0.25)),
    ),
    leading: CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.14),
      child: Icon(icon, color: color, size: 20.spMin),
    ),
    title: Text(
      title,
      style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w700),
    ),
    subtitle: Text(
      subtitle,
      style: TextStyle(fontSize: 11.5.spMin, color: AppColors.grey),
    ),
    trailing: Icon(LucideIcons.plus, size: 18.spMin, color: color),
  );
}
