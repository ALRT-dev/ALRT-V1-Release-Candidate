import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/shared/extensions/date_time_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/features/shared/views/widgets/category_glyph.dart';
import 'package:hazard_app/features/shared/views/widgets/view_hazard_widgets/source_shape_glyph.dart';
import 'package:hazard_app/others/app_colors.dart';

/// One alert as a compact feed row, in the boards' language (prototype
/// Search and SearchResults sheets, 16 Oct 2026): a 5 px band strip for
/// official alerts, the source shape and label, how long ago, the title,
/// and "agency · distance" (or "Confirmed by ×N · distance" for a
/// community report). Tapping opens the alert.
class AlertFeedRow extends ConsumerWidget {
  const AlertFeedRow({super.key, required this.hazard, this.onOpen});

  final Hazard hazard;

  /// Called before the alert opens, e.g. to close the sheet it sits in.
  final VoidCallback? onOpen;

  static const _ink = Color(0xFF1C1C1E);

  String _label() {
    if (hazard.isUserReported) return 'COMMUNITY REPORT';
    if (hazard.isAlrtIntel) return 'ALRT ASSESSMENT';
    if (hazard.isGlobalHumanitarian) return 'GDACS';
    final level = hazard.severityTitle;
    if (hazard.isAwsCompliant == true &&
        level.isNotEmpty &&
        level != 'Unknown') {
      return level.toUpperCase();
    }
    return 'OFFICIAL';
  }

  Color _labelInk() {
    if (hazard.isUserReported) return AlertCardStyle.labelInkCommunity;
    if (hazard.isAwsCompliant == true && !hazard.isAlrtIntel) {
      return AlertCardStyle.bandLabelInk(hazard.severityBand);
    }
    return AlertCardStyle.labelInkNeutral;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latitude = hazard.latitude;
    final longitude = hazard.longitude;
    final distance = ref.watch(
      providerOfLocation.select(
        (value) => latitude == null || longitude == null
            ? null
            : value.distanceTo(latitude, longitude),
      ),
    );
    final postedAt = hazard.createdAt ?? hazard.occurredAt;
    final category = hazard.category;
    final sourceName = hazard.source?.name?.trim();
    final distanceText =
        distance == null ? null : AlertCardStyle.distanceLabel(distance);
    final sub = [
      if (hazard.isUserReported && hazard.corroborationCount > 0)
        'Confirmed by ×${hazard.corroborationCount}',
      if (!hazard.isUserReported && sourceName != null && sourceName.isNotEmpty)
        sourceName,
      if (distanceText != null) distanceText,
    ].join(' · ');

    return Semantics(
      button: true,
      label: hazard.title,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AlertCardStyle.cardRadius.spMin),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            onOpen?.call();
            context.push(
              ViewHazardScreen.route,
              extra: ViewHazardScreenArgs(hazard: hazard),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hazard.isUserReported)
                Container(
                  height: AlertCardStyle.feedBandStripHeight.spMin,
                  color: hazard.color,
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.spMin,
                  vertical: 12.spMin,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (hazard.isUserReported && category != null)
                          CategoryGlyph(category: category, size: 22.spMin)
                        else if (!hazard.isUserReported)
                          SourceShapeGlyph(
                            isAws: hazard.isAwsCompliant ?? false,
                            isOfficial: hazard.source != null,
                            isGlobalHumanitarian: hazard.isGlobalHumanitarian,
                            isAlrtIntel: hazard.isAlrtIntel,
                            color: hazard.color,
                            size: 14.spMin,
                          ),
                        SizedBox(width: 8.spMin),
                        Expanded(
                          child: Text(
                            _label(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.spMin,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: _labelInk(),
                            ),
                          ),
                        ),
                        if (postedAt != null)
                          Text(
                            postedAt.timeAgo,
                            style: TextStyle(
                              fontSize: 12.spMin,
                              color: AlertCardStyle.metaInk,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.spMin),
                    Text(
                      hazard.title ?? 'Alert',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17.spMin,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: _ink,
                      ),
                    ),
                    if (sub.isNotEmpty) ...[
                      SizedBox(height: 6.spMin),
                      Row(
                        children: [
                          if (!hazard.isUserReported && category != null) ...[
                            Container(
                              width: 8.spMin,
                              height: 8.spMin,
                              decoration: BoxDecoration(
                                color: category.resolvedColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.spMin),
                          ],
                          Expanded(
                            child: Text(
                              sub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.spMin,
                                color: AlertCardStyle.metaInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
