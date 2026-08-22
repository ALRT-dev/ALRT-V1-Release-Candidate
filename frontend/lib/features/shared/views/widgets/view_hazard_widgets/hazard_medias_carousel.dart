import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_source_types.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_types.dart';
import 'package:hazard_app/features/shared/enums/video_priority_types.dart';
import 'package:hazard_app/features/shared/models/alrt_media_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_medias_carousel_index_provider.dart';
import 'package:hazard_app/features/shared/views/widgets/app_cached_network_image.dart';
import 'package:hazard_app/features/shared/views/widgets/video_preview.dart';
import 'package:hazard_app/others/app_colors.dart';

class HazardMediasCarousel extends ConsumerStatefulWidget {
  const HazardMediasCarousel({
    super.key,
    required this.id,
    required this.medias,
    this.videoPriority = VideoPriority.level1,
    this.registerVideoLifecycle = true,
  });

  /// Unique identifier for the carousel instance.
  final String id;

  /// The list of media items to display in the carousel.
  final List<AlrtMedia> medias;

  /// The priority assigned to video media within the carousel.
  final VideoPriority videoPriority;

  /// Whether to register the video lifecycle for video previews.
  final bool registerVideoLifecycle;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HazardMediasCarouselState();
}

class _HazardMediasCarouselState extends ConsumerState<HazardMediasCarousel>
    with TickerProviderStateMixin {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  late final currentIndexProvider = providerOfHazardMediasCarouselIndex(
    widget.id,
  );

  @override
  Widget build(BuildContext context) {
    final imageMedias = _filterImageMedias(widget.medias);
    return SizedBox(
      height: 300.spMin,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.spMin),
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildCarousel(imageMedias),
            ),
            _buildIndicators(imageMedias),
          ],
        ),
      ),
    );
  }

  /// Filters media to only include images
  List<AlrtMedia> _filterImageMedias(List<AlrtMedia> medias) {
    return medias;
  }

  /// Builds the main carousel widget
  Widget _buildCarousel(List<AlrtMedia> imageMedias) {
    return CarouselSlider.builder(
      carouselController: _carouselController,
      itemCount: imageMedias.length,
      itemBuilder: (context, index, realIndex) {
        final media = imageMedias[index];
        return Hero(
          tag: media.id,
          child: Stack(
            children: [
              _buildItemWidget(media),
              _buildGradientOverlay(),
            ],
          ),
          flightShuttleBuilder:
              (
                flightContext,
                animation,
                flightDirection,
                fromHeroContext,
                toHeroContext,
              ) => ClipRRect(
                borderRadius: BorderRadius.circular(16.spMin),
                child: toHeroContext.widget,
              ),
        );
      },
      options: CarouselOptions(
        height: double.infinity,
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        scrollPhysics: ClampingScrollPhysics(),
        initialPage: ref.read(currentIndexProvider),
        onPageChanged: (index, reason) {
          ref.read(currentIndexProvider.notifier).state = index;
        },
      ),
    );
  }

  Widget _buildItemWidget(AlrtMedia media) {
    return media.type == AlrtMediaType.image
        ? _buildImageWidget(media)
        : _buildVideoWidget(media);
  }

  /// Builds the appropriate image widget based on source type
  Widget _buildImageWidget(final AlrtMedia media) {
    Widget imageWidget;

    switch (media.source) {
      case AlrtMediaSource.networkUrl:
        imageWidget = AppCachedNetworkImage(
          imageUrl: media.value,
          cacheKey: media.s3Key,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorWidget: (context, url, error) => _buildImageError(),
        );
        break;
      case AlrtMediaSource.file:
        imageWidget = Image.file(
          File(media.value),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
        break;
      case AlrtMediaSource.asset:
        imageWidget = Image.asset(
          media.value,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
        break;
    }

    return imageWidget;
  }

  Widget _buildVideoWidget(final AlrtMedia media) {
    return VideoAlrtMediaPreview(
      videoMedia: media,
      priority: widget.videoPriority,
      registerLifecycle: widget.registerVideoLifecycle,
      muteButtonPositionedWidget: (muteButton) {
        return Positioned(
          bottom: 15.spMin,
          right: 15.spMin,
          child: muteButton,
        );
      },
    );
  }

  /// Builds error widget for failed image loads
  Widget _buildImageError() {
    return Container(
      color: AppColors.extraLightGrey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 48.spMin,
              color: Colors.grey.shade500,
            ),
            SizedBox(height: 8.spMin),
            Text(
              'Failed to load image',
              style: TextStyle(
                fontSize: 12.spMin,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds gradient overlay for better text readability
  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.transparent,
                AppColors.black.withValues(alpha: 0.3),
              ],
              stops: const [0.6, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds page indicators
  Widget _buildIndicators(List<AlrtMedia> imageMedias) {
    if (imageMedias.length <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: 16.spMin,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageMedias.asMap().entries.map((entry) {
          int index = entry.key;
          return Consumer(
            builder: (context, ref, child) {
              final currentIndex = ref.watch(currentIndexProvider);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: currentIndex == index ? 24.spMin : 8.spMin,
                height: 8.spMin,
                margin: EdgeInsets.symmetric(horizontal: 2.spMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.spMin),
                  color: currentIndex == index
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.2),
                      blurRadius: 4.spMin,
                      offset: Offset(0, 2.spMin),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
