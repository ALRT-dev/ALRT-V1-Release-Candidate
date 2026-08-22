import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/report/providers/create_update_report_provider.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/views/widgets/app_cached_network_image.dart';
import 'package:hazard_app/features/shared/views/widgets/round_button.dart';
import 'package:hazard_app/features/shared/views/widgets/video_thumbnail.dart';
import 'package:hazard_app/others/app_colors.dart';

class CreateReportMediasListItem extends ConsumerStatefulWidget {
  const CreateReportMediasListItem({
    super.key,
    required this.media,
  });

  /// The media item (image/video) to be displayed.
  final AlrtMedia media;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateReportMediasListItemState();
}

class _CreateReportMediasListItemState
    extends ConsumerState<CreateReportMediasListItem> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: _mainBuilder(),
        ),
        _removeButtonBuilder(),
      ],
    );
  }

  Widget _mainBuilder() {
    return switch (widget.media.type) {
      AlrtMediaType.image => _imageBuilder(),
      AlrtMediaType.video => _videoBuilder(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _removeButtonBuilder() {
    return Positioned(
      top: -5.spMin,
      right: -5.spMin,
      child: RoundButton(
        size: 30.spMin,
        icon: Icon(
          Icons.remove,
          color: AppColors.white,
        ),
        backgroundColor: AppColors.black,
        onPressed: _handleRemove,
      ),
    );
  }

  Widget _imageBuilder() {
    return Container(
      width: 100.spMin,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(14.spMin),
        image: widget.media.type != AlrtMediaType.image
            ? null
            : DecorationImage(
                image: widget.media.source == AlrtMediaSource.file
                    ? FileImage(File(widget.media.value))
                    : AppCachedNetworkImageProvider.fromRef(
                        widget.media.value,
                        cacheKey: widget.media.s3Key,
                        ref: ref,
                      ),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _videoBuilder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.spMin),
      child: VideoThumbnail(
        videoMedia: widget.media,
        playIconSize: 35.0,
      ),
    );
  }

  /// Handles the removal of the media item from the report.
  void _handleRemove() {
    ref.read(providerOfCreateReport.notifier).removeMedia(widget.media.id);
  }
}
