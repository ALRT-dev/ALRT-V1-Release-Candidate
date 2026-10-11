import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows a bottom sheet when the server refuses a community report because the
/// user has hit the posting limit (3 per hour or 10 per day, HTTP 429).
Future<void> showReportRateLimitSheet({
  required BuildContext context,
  required String message,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ReportRateLimitSheet(message: message),
  );
}

class _ReportRateLimitSheet extends StatelessWidget {
  const _ReportRateLimitSheet({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.spMin),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.spMin,
            vertical: 28.spMin,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2.spMin),
                ),
              ),
              24.hSizedBox,
              Container(
                width: 56.spMin,
                height: 56.spMin,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E5),
                  borderRadius: BorderRadius.circular(16.spMin),
                ),
                child: Icon(
                  LucideIcons.timer,
                  size: 28.spMin,
                  color: const Color(0xFFFF6B01),
                ),
              ),
              16.hSizedBox,
              Text(
                'Slow down a bit',
                style: TextStyle(
                  fontSize: 18.spMin,
                  fontWeight: FontWeight.w800,
                ),
              ),
              10.hSizedBox,
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5.spMin,
                  height: 1.45,
                  color: AppColors.mediumGrey,
                ),
              ),
              24.hSizedBox,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B01),
                    padding: EdgeInsets.symmetric(vertical: 14.spMin),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.spMin),
                    ),
                  ),
                  child: Text(
                    'OK, got it',
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
