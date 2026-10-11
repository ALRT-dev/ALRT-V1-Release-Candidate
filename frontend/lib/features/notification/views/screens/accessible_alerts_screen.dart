import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/notification/views/widgets/accessible_alerts_section.dart';

/// Standalone screen for sound and vibration settings. Wraps the existing
/// [AccessibleAlertsSection] widget in a Scaffold so it can be reached from
/// the Me screen's Preferences section.
class AccessibleAlertsScreen extends StatelessWidget {
  const AccessibleAlertsScreen({super.key});

  static const route = '/accessible-alerts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Accessible alerts',
          style: TextStyle(fontSize: 17.spMin, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.spMin),
        children: const [
          AccessibleAlertsSection(),
        ],
      ),
    );
  }
}
