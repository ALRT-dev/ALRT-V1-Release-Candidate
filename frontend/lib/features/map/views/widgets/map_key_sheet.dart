import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_key_content.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Shows the "Map key" bottom sheet (prototype board "Main", 9 Oct 2026):
/// a white sheet with the title, one line on how to read the pins, and THE
/// shared [AlertKeyContent] so the key cannot disagree with the feed's.
Future<void> showMapKeySheet({
  required final BuildContext context,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.35),
    builder: (context) => const MapKeySheet(),
  );
}

/// How much of the screen the sheet takes when it opens, and its bounds.
const kMapKeySheetInitialSize = 0.7;
const kMapKeySheetMinSize = 0.4;
const kMapKeySheetMaxSize = 0.92;

class MapKeySheet extends StatelessWidget {
  const MapKeySheet({super.key});

  static const _subtitleColor = Color(0xFF5C5C66);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: kMapKeySheetInitialSize,
      minChildSize: kMapKeySheetMinSize,
      maxChildSize: kMapKeySheetMaxSize,
      expand: false,
      builder: (context, scrollController) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.spMin),
            topRight: Radius.circular(24.spMin),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20.spMin, 10.spMin, 20.spMin, 16.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _dragHandleBuilder()),
            SizedBox(height: 16.spMin),
            Text(
              'Map key',
              style: TextStyle(
                fontSize: 24.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 6.spMin),
            Text(
              'Shape says who is speaking. Colour says how serious.',
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w400,
                color: _subtitleColor,
                height: 1.35,
              ),
            ),
            SizedBox(height: 18.spMin),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AlertKeyContent(isDark: false),
                    SizedBox(height: 12.spMin),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dragHandleBuilder() {
    return Container(
      width: 40.spMin,
      height: 4.spMin,
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
