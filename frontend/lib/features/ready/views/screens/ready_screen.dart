import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The Ready tab — readiness score and five preparation steps.
///
/// This is the placeholder scaffold; the full screen (readiness score,
/// Plan, Drill, Learn, Safety Profile entry points) ships in a later
/// Layer 2 task.
class ReadyScreen extends ConsumerWidget {
  const ReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.shieldCheck,
                size: 48.spMin,
                color: AppColors.orange,
              ),
              SizedBox(height: 16.spMin),
              Text(
                'Ready',
                style: TextStyle(
                  fontSize: 24.spMin,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: 8.spMin),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.spMin),
                child: Text(
                  'Your readiness score and preparation steps are coming soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.spMin,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
