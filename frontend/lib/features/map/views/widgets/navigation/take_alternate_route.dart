import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/states/map_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/widgets/app_cached_network_image.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TakeAlternateRoute extends ConsumerStatefulWidget {
  const TakeAlternateRoute({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TakeAlternateRouteState();
}

class _TakeAlternateRouteState extends ConsumerState<TakeAlternateRoute>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hazard = ref.watch(
      providerOfMap.select(
        (s) => s.hazardCorridorsAhead.first.hazards.first,
      ),
    );

    return Column(
      spacing: 8.spMin,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColorDark,
                blurRadius: 10.0,
                offset: Offset(0.0, 0.0),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14.spMin),
                    topRight: Radius.circular(14.spMin),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.orange300,
                      AppColors.red200,
                    ],
                  ),
                ),
                padding: EdgeInsets.all(10.spMin),
                child: Row(
                  children: [
                    _buildIcon(hazard),
                    10.wSizedBox,
                    Expanded(child: _buildTitle(hazard)),
                    10.wSizedBox,
                    _buildDistance(hazard),
                  ],
                ),
              ),
              _buildActionButtons().pad(10.0),
            ],
          ),
        ),
        _buildLinearProgressIndicator(),
      ],
    );
  }

  Widget _buildIcon(final Hazard hazard) {
    return Consumer(
      builder: (context, ref, child) {
        final categoryImage = hazard.categoryImage;
        final hazardColor = hazard.color;
        final fallbackIconPath = hazard.fallbackIconPath;

        return SizedBox(
          width: 38.spMin,
          height: 38.spMin,
          child: AppCachedNetworkImage(
            imageUrl: categoryImage?.url ?? '',
            cacheKey: categoryImage?.s3Key,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) => Image.asset(
              fallbackIconPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: hazardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Icon(
                  Icons.error,
                  size: 24.spMin,
                  color: hazardColor == AppColors.transparent
                      ? AppColors.grey
                      : hazardColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(final Hazard hazard) {
    final awsAlertLevel = (hazard.isAwsCompliant ?? false)
        ? hazard.severityTitle
        : '';
    final locationName = hazard.locationName ?? '';

    final subtitle = [
      if (awsAlertLevel.isNotEmpty) awsAlertLevel,
      if (locationName.isNotEmpty) locationName,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${hazard.category?.name ?? ''} alert ahead in your route',
          style: TextStyle(
            fontSize: 12.spMin,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.spMin,
              color: AppColors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildDistance(final Hazard hazard) {
    return Consumer(
      builder: (context, ref, child) {
        final distance = ref.watch(
          providerOfLocation.select(
            (value) => hazard.latitude == null || hazard.longitude == null
                ? 0.0
                : value.distanceTo(hazard.latitude!, hazard.longitude!),
          ),
        );

        final distanceText = distance == 0.0
            ? 'Nearby'
            : distance < 1000
            ? '${distance.toStringAsFixed(1)} m'
            : '${(distance / 1000).toStringAsFixed(1)} km';

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 9.spMin,
            vertical: 4.spMin,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Text(
            distanceText,
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return IntrinsicHeight(
      child: Row(
        spacing: 10.spMin,
        children: [
          // Take Alternate Route Button
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(
                  providerOfMap.select(
                    (value) => value.takeAlternateRouteState.maybeWhen(
                      orElse: () => false,
                      loading: () => true,
                    ),
                  ),
                );

                return Container(
                  padding: EdgeInsets.all(10.spMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.spMin),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColorDark,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 0.0),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: [
                        AppColors.orange300,
                        AppColors.red200,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5.spMin,
                    children: [
                      if (isLoading)
                        SizedBox(
                          width: 20.spMin,
                          height: 20.spMin,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      else
                        Icon(
                          LucideIcons.arrowLeftRight,
                          size: 20.spMin,
                          color: AppColors.white,
                        ),
                      Text(
                        'Take Alternate Route',
                        style: TextStyle(
                          fontSize: 12.spMin,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ).onPressed(() {
                  if (!isLoading) {
                    _handleTakeAlternateRoute();
                  }
                });
              },
            ),
          ),
          // Continue Button
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.spMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.spMin),
                color: AppColors.extraLightGrey,
              ),
              child: Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ).pY(1.0).onPressed(_handleContinue),
          ),
        ],
      ),
    );
  }

  Widget _buildLinearProgressIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _animation.value,
          color: AppColors.orange300,
          backgroundColor: AppColors.transparent,
          borderRadius: BorderRadius.circular(100.spMin),
          minHeight: 5.spMin,
        ).pX(5.0);
      },
    );
  }

  void _handleTakeAlternateRoute() {
    ref.read(providerOfMap.notifier).takeAlternateRoute();
  }

  void _handleContinue() {
    ref.read(providerOfMap.notifier).updateShowTakeAlternateRouteButton(false);
  }
}
