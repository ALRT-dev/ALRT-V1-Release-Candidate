import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/utils/dialogs.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MapKeysButton extends ConsumerStatefulWidget {
  const MapKeysButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MapKeysButtonState();
}

class _MapKeysButtonState extends ConsumerState<MapKeysButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.spMin,
      height: 48.spMin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blue,
            AppColors.darkBlue,
          ],
        ),
      ),
      child: Icon(
        LucideIcons.key,
        size: 18.spMin,
        color: AppColors.white,
      ),
    ).onPressed(_handleTap);
  }

  void _handleTap() {
    showAlrtKeysBottomSheet(context: context);
  }
}
