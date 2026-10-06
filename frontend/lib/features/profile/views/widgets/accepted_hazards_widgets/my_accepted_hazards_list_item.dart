import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyAcceptedHazardsListItem extends ConsumerStatefulWidget {
  const MyAcceptedHazardsListItem({
    super.key,
    required this.hazard,
  });

  /// The hazard to display in this list item.
  final Hazard hazard;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyAcceptedHazardsListItemState();
}

class _MyAcceptedHazardsListItemState
    extends ConsumerState<MyAcceptedHazardsListItem> {
  @override
  Widget build(BuildContext context) {
    final title = widget.hazard.isUserReported
        ? widget.hazard.category?.name ?? 'Alert Report'
        : widget.hazard.title ?? 'Alert';

    return Row(
      children: [
        Container(
          width: 10.spMin,
          height: 10.spMin,
          decoration: BoxDecoration(
            color: widget.hazard.category?.effectiveColor,
            shape: BoxShape.circle,
          ),
        ),
        10.wSizedBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              Row(
                children: [
                  _buildDistance(),
                  _buildTime(),
                ],
              ),
            ],
          ),
        ),
        _buildStatus(),
      ],
    ).pad(16.0).onPressed(_gotoViewHazard);
  }

  Widget _buildDistance() {
    return Consumer(
      builder: (context, ref, child) {
        final latitude = widget.hazard.latitude;
        final longitude = widget.hazard.longitude;

        if (latitude == null || longitude == null) {
          return const SizedBox.shrink();
        }

        final distance = ref.watch(
          providerOfLocation.select(
            (value) => value.distanceTo(
              widget.hazard.latitude!,
              widget.hazard.longitude!,
            ),
          ),
        );

        return Text(
          '${(distance < 1000 ? '${distance.toStringAsFixed(1)} m' : '${(distance / 1000).toStringAsFixed(1)} km')} away',
          style: TextStyle(
            fontSize: 12.spMin,
            color: AppColors.grey,
          ),
        );
      },
    );
  }

  Widget _buildTime() {
    final createdAt = widget.hazard.createdAt;
    if (createdAt == null) {
      return const SizedBox.shrink();
    }

    return Text(
      ', ${timeago.format(createdAt)}',
      style: TextStyle(
        fontSize: 12.spMin,
        color: AppColors.grey,
      ),
    );
  }

  Widget _buildStatus() {
    final hasExpired = widget.hazard.isExpired;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.spMin,
        vertical: 4.spMin,
      ),
      decoration: BoxDecoration(
        color: hasExpired
            ? AppColors.extraLightGrey
            : AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.spMin),
      ),
      child: Text(
        hasExpired ? 'Expired' : 'Active',
        style: TextStyle(
          fontSize: 12.spMin,
          color: hasExpired
              ? AppColors.grey.withValues(alpha: 0.6)
              : AppColors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Navigate to the View Hazard screen with the current hazard as an argument.
  void _gotoViewHazard() {
    context.unfocusInputs();
    context.push(
      ViewHazardScreen.route,
      extra: ViewHazardScreenArgs(
        hazard: widget.hazard,
      ),
    );
  }
}
