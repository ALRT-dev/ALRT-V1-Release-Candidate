import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/shared/providers/service_providers.dart';
import 'package:hazard_app/features/shared/services/media_service.dart';
import 'package:hazard_app/features/shared/views/widgets/base_bottomsheet.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBottomsheet extends ConsumerStatefulWidget {
  const ImagePickerBottomsheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ImagePickerBottomsheetState();
}

class _ImagePickerBottomsheetState
    extends ConsumerState<ImagePickerBottomsheet> {
  MediaService get _mediaService => ref.read(providerOfMediaService);

  @override
  Widget build(BuildContext context) {
    return BaseBottomsheet(
      child: Padding(
        padding: EdgeInsets.all(20.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            24.spMin.verticalSpace,
            _buildOptions(),
            16.spMin.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40.spMin,
      height: 4.spMin,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(2.spMin),
      ),
    );
  }

  Widget _buildOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionCard(
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            color: AppColors.blue,
            onTap: _handleCameraPress,
          ),
        ),
        16.spMin.horizontalSpace,
        Expanded(
          child: _buildOptionCard(
            icon: Icons.photo_library_rounded,
            label: 'Gallery',
            color: AppColors.purple,
            onTap: _handleGalleryPress,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 24.spMin,
          horizontal: 16.spMin,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.spMin),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 28.spMin,
              ),
            ),
            12.spMin.verticalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraPress() async {
    final result = await _mediaService.pickImage(
      source: ImageSource.camera,
    );
    if (!mounted) return;

    result.when(
      (media) {
        if (media != null) {
          context.pop([media]);
        } else {
          context.pop();
        }
      },
      (error) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${error.message}'),
            backgroundColor: AppColors.red,
          ),
        );
      },
    );
  }

  Future<void> _handleGalleryPress() async {
    final result = await _mediaService.pickMedias();
    if (!mounted) return;

    result.when(
      (medias) {
        if (medias.isNotEmpty) {
          context.pop(medias);
        } else {
          context.pop();
        }
      },
      (error) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: ${error.message}'),
            backgroundColor: AppColors.red,
          ),
        );
      },
    );
  }
}
