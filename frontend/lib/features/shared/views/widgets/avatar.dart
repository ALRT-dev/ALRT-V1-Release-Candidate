import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/views/widgets/app_cached_network_image.dart';
import 'package:hazard_app/others/app_colors.dart';

enum _Type {
  network,
  file,
  asset,
  initials,
  profileMedia,
}

class Avatar extends ConsumerStatefulWidget {
  const Avatar.network({
    super.key,
    required this.imgUrl,
    this.cache = true,
    this.size = 40.0,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.circle,
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    this.boxShadow,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.transparent,
  }) : type = _Type.network,
       filePath = null,
       assetPath = null,
       initials = null,
       profileMedia = null;

  const Avatar.file({
    super.key,
    required this.filePath,
    this.size = 40.0,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.circle,
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    this.boxShadow,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.transparent,
  }) : type = _Type.file,
       cache = false,
       imgUrl = null,
       assetPath = null,
       initials = null,
       profileMedia = null;

  const Avatar.asset({
    super.key,
    required this.assetPath,
    this.size = 40.0,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.circle,
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    this.boxShadow,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.transparent,
  }) : type = _Type.asset,
       cache = false,
       imgUrl = null,
       filePath = null,
       initials = null,
       profileMedia = null;

  const Avatar.initials({
    super.key,
    required this.initials,
    this.size = 40.0,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.circle,
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    this.boxShadow,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.transparent,
  }) : type = _Type.initials,
       cache = false,
       imgUrl = null,
       filePath = null,
       assetPath = null,
       profileMedia = null;

  /// The profile media to display as the avatar if the type is [_Type.profileMedia].
  const Avatar.profileMedia({
    super.key,
    required this.profileMedia,
    this.size = 40.0,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.circle,
    this.borderRadius = BorderRadius.zero,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    this.boxShadow,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = Colors.transparent,
  }) : type = _Type.profileMedia,
       cache = true,
       imgUrl = null,
       filePath = null,
       assetPath = null,
       initials = null;

  /// The type of the avatar.
  final _Type type;

  /// Whether to cache the image.
  ///
  /// Only applicable if the type is [_Type.network].
  final bool cache;

  /// The URL of the image to display as the avatar if the type is [_Type.network].
  final String? imgUrl;

  /// The file of the image to display as the avatar if the type is [_Type.file].
  final String? filePath;

  /// The asset path of the image to display as the avatar if the type is [_Type.asset].
  final String? assetPath;

  /// The name of the image to display as the avatar if the type is [_Type.initials].
  final String? initials;

  /// The profile media to display as the avatar if the type is [_Type.profileMedia].
  final AlrtMedia? profileMedia;

  /// The size of the avatar.
  ///
  /// If [width] and [height] are provided then this parameter is ignored.
  final double size;

  /// The width of the avatar.
  ///
  /// If not null, then [size] will be ignored.
  final double? width;

  /// The height of the avatar.
  ///
  /// If not null, then [size] will be ignored.
  final double? height;

  /// The fit of the avatar.
  final BoxFit fit;

  /// The shape of the avatar.
  final BoxShape shape;

  /// The border radius of the avatar.
  final BorderRadius borderRadius;

  /// The box shadow of the avatar.
  final List<BoxShadow>? boxShadow;

  /// The border width of the avatar.
  final double borderWidth;

  /// The border color of the avatar.
  final Color borderColor;

  /// The background color of the avatar.
  final Color backgroundColor;

  /// The foreground color of the avatar.
  final Color foregroundColor;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AvatarState();
}

class _AvatarState extends ConsumerState<Avatar> {
  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case _Type.network:
        return _networkImageBuilder();
      case _Type.file:
        return _fileImageBuilder();
      case _Type.asset:
        return _assetImageBuilder();
      case _Type.initials:
        return _initialsBuilder();
      case _Type.profileMedia:
        return _profileMediaBuilder();
    }
  }

  Widget _networkImageBuilder() {
    if (widget.imgUrl == null) return _placeholderBuilder();
    return _containerBuilder(
      image: DecorationImage(
        image: widget.cache
            ? AppCachedNetworkImageProvider.fromRef(
                ref: ref,
                widget.imgUrl!,
              )
            : NetworkImage(widget.imgUrl!),
        fit: widget.fit,
      ),
    );
  }

  Widget _fileImageBuilder() {
    if (widget.filePath == null) return _placeholderBuilder();
    return _containerBuilder(
      image: DecorationImage(
        image: FileImage(File(widget.filePath!)),
        fit: widget.fit,
      ),
    );
  }

  Widget _assetImageBuilder() {
    if (widget.assetPath == null) return _placeholderBuilder();
    return _containerBuilder(
      image: DecorationImage(
        image: AssetImage(widget.assetPath!),
        fit: widget.fit,
      ),
    );
  }

  Widget _initialsBuilder() {
    if (widget.initials == null) return _placeholderBuilder();
    return _containerBuilder(
      child: Center(
        child: Text(
          widget.initials!,
          style: TextStyle(
            color: widget.foregroundColor,
            fontSize: widget.size.spMin / 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _profileMediaBuilder() {
    if (widget.profileMedia == null) return _placeholderBuilder();

    if (widget.profileMedia?.source == AlrtMediaSource.file) {
      return _containerBuilder(
        image: DecorationImage(
          image: FileImage(File(widget.profileMedia!.value)),
          fit: widget.fit,
        ),
      );
    } else if (widget.profileMedia?.source == AlrtMediaSource.asset) {
      return _containerBuilder(
        image: DecorationImage(
          image: AssetImage(widget.profileMedia!.value),
          fit: widget.fit,
        ),
      );
    }

    return _containerBuilder(
      image: DecorationImage(
        image: widget.cache
            ? AppCachedNetworkImageProvider.fromRef(
                ref: ref,
                widget.profileMedia!.value,
                cacheKey: widget.profileMedia!.s3Key,
              )
            : NetworkImage(widget.profileMedia!.value),
        fit: widget.fit,
      ),
    );
  }

  Widget _placeholderBuilder() {
    return _containerBuilder(
      image: DecorationImage(
        image: AssetImage(
          'assets/images/empty_avatar.jpeg',
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _containerBuilder({
    final DecorationImage? image,
    final Widget? child,
  }) {
    return Container(
      width: widget.width?.spMin ?? widget.size.spMin,
      height: widget.height?.spMin ?? widget.size.spMin,
      decoration: BoxDecoration(
        shape: widget.shape,
        border: Border.all(
          width: widget.borderWidth,
          color: widget.borderColor,
        ),
        boxShadow:
            widget.boxShadow ??
            [
              BoxShadow(
                color: AppColors.shadowColorDark,
                blurRadius: 5.0,
              ),
            ],
        borderRadius: widget.shape == BoxShape.circle
            ? null
            : widget.borderRadius,
        color: widget.backgroundColor,
        image: image,
      ),
      child: ClipRRect(
        borderRadius: widget.shape == BoxShape.circle
            ? BorderRadius.circular(100.spMin)
            : widget.borderRadius,
        child: child,
      ),
    );
  }
}
