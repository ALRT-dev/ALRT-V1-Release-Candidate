import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/home_screen_widget/widget_pinning_service.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Full screen for adding home-screen widgets. Replaces the old bottom sheet
/// ([showAddWidgetSheet]) so it sits in the navigation stack like the other
/// Me sub-screens.
class AddWidgetScreen extends StatefulWidget {
  const AddWidgetScreen({super.key});

  static const route = '/add-widget';

  @override
  State<AddWidgetScreen> createState() => _AddWidgetScreenState();
}

class _AddWidgetScreenState extends State<AddWidgetScreen> {
  bool _canPin = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _checkPinSupport();
  }

  Future<void> _checkPinSupport() async {
    final supported = await WidgetPinningService.isPinSupported();
    if (!mounted) return;
    setState(() {
      _canPin = supported;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Widgets',
          style: TextStyle(fontSize: 17.spMin, fontWeight: FontWeight.w700),
        ),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.spMin),
              children: [
                Text(
                  _canPin
                      ? 'Pick a widget. Your launcher will ask you to confirm.'
                      : _manualInstructions(),
                  style: TextStyle(
                    fontSize: 13.spMin,
                    height: 1.5,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 14.spMin),
                if (_canPin) ...[
                  _widgetTileBuilder(
                    icon: LucideIcons.triangleAlert,
                    color: AppColors.orange,
                    title: 'Nearby Alerts widget',
                    subtitle: 'Warnings near you, or a green all-clear',
                    widget: PinnableWidget.alerts,
                  ),
                  SizedBox(height: 8.spMin),
                  _widgetTileBuilder(
                    icon: LucideIcons.users,
                    color: const Color(0xFF5B5BD6),
                    title: 'Family widget',
                    subtitle: 'Your circle at a glance',
                    widget: PinnableWidget.family,
                  ),
                ],
              ],
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

  Widget _widgetTileBuilder({
    required final IconData icon,
    required final Color color,
    required final String title,
    required final String subtitle,
    required final PinnableWidget widget,
  }) {
    return ListTile(
      onTap: () => WidgetPinningService.requestPin(widget),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.spMin),
        side: BorderSide(color: AppColors.grey.withValues(alpha: 0.25)),
      ),
      tileColor: Colors.white,
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
}
