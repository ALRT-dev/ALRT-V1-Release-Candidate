import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/confirmation_buttons.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/features/shared/extensions/color_extension.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_item_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_item_provider_state.dart';
import 'package:hazard_app/features/shared/utils/share_alert.dart';
import 'package:hazard_app/features/shared/views/widgets/freshness_chip.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/features/shared/views/widgets/hazard_shape_badge.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommonHazardsListItem extends ConsumerStatefulWidget {
  const CommonHazardsListItem({
    super.key,
    required this.hazard,
    this.showCloseButton = false,
    this.onClosePressed,
    this.showTrustMeter = true,
    this.showSourceHeader = true,
    this.horizontalPadding = 20.0,
    this.isInfoWindow = false,
  });

  /// The hazard to display in this list item.
  final Hazard hazard;

  /// Whether to show a close button on the list item.
  final bool showCloseButton;

  /// Callback when the close button is pressed.
  final void Function()? onClosePressed;

  /// Whether to show the trust meter widget.
  final bool showTrustMeter;

  /// Whether to show the source information in the header.
  final bool showSourceHeader;

  /// The horizontal padding around the list item.
  final double horizontalPadding;

  /// Whether this list item is being shown inside an InfoWindow.
  final bool isInfoWindow;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommonHazardsListItemState();
}

class _CommonHazardsListItemState extends ConsumerState<CommonHazardsListItem> {
  late final provider = providerOfHazardItem(widget.hazard.id ?? 'unknown');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isHazardNull = ref.read(provider).hazard == null;
        if (isHazardNull) {
          ref.read(provider.notifier).updateHazard(widget.hazard);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // register this provider to the lifecycle of this widget
    ref.watch(provider.select((value) => null));

    _listenToVoteHazardState();

    final isHazardNull = ref.watch(
      provider.select(
        (value) => value.hazard == null,
      ),
    );
    if (isHazardNull) {
      return const SizedBox.shrink();
    }

    // Locked two-reds rule: solid red + glow is reserved for official
    // CRITICAL; official ACTION gets the dashed needs-attention outline.
    final isOfficialCritical = ref.watch(
      provider.select(
        (value) =>
            value.hazard?.source != null &&
            value.hazard?.severityBand == HazardSeverityBand.critical,
      ),
    );
    final isOfficialAction = ref.watch(
      provider.select(
        (value) =>
            value.hazard?.source != null &&
            value.hazard?.severityBand == HazardSeverityBand.action,
      ),
    );

    return InkWell(
      onTap: widget.isInfoWindow ? null : _gotoViewHazard,
      borderRadius: BorderRadius.circular(14.spMin),
      child: CustomPaint(
        foregroundPainter: isOfficialAction
            ? DashedRRectPainter(
                color: AlertCardStyle.dashedBorderColor,
                radius: 16.spMin,
              )
            : null,
        child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.spMin),
          boxShadow: [
            if (isOfficialCritical)
              AlertCardStyle.criticalGlow
            else
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 5.0,
                offset: const Offset(0.0, 0.0),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // One card, whatever it is shown in. The map callout, the
              // list and the alert list all get the same thing: the
              // coloured heading that says who and how urgent, the title,
              // when and how far, and the way in. What we know and what to
              // do are a read, not a glance, so they wait for the detail
              // screen rather than being half-shown here.
              _coloredHeaderBuilder(),
              // "In plain terms" is mandatory on every card type (locked
              // rule), not just the detail screen — this is the same
              // deterministic line _buildPlainTermsBox shows there.
              _plainTermsBuilder(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _iconBuilder(),
                  12.wSizedBox,
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _titleBuilder(),
                              4.hSizedBox,
                              _dateAndDistanceBuilder(),
                              // How recently this alert was really touched.
                              // Never dressed up: green only inside the
                              // hour, plain grey beyond it.
                              6.hSizedBox,
                              _freshnessRowBuilder(),
                            ],
                          ),
                        ),
                        if (widget.hazard.isUserReported) _votesCountBuilder(),
                      ],
                    ),
                  ),
                ],
              ).pX(16.0).pT(16.0),
              10.hSizedBox,
              if (widget.showTrustMeter &&
                  widget.hazard.isUserReported &&
                  !widget.isInfoWindow) ...[
                _confirmationButtonsBuilder().pX(16.0),
              ],
              _categoryAndViewDetailsBuilder(),
            ],
          ),
        ),
        ),
      ),
    ).pX(widget.horizontalPadding);
  }

  /// The live-freshness chip, plus a community-corroboration chip when this
  /// report has been independently confirmed by other nearby reports. Share
  /// lives in the card's own action row, so it is not repeated here.
  Widget _freshnessRowBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FreshnessChip(
              updatedAt: hazard.updatedAt,
              createdAt: hazard.createdAt,
            ),
            if (hazard.isUserReported && hazard.corroborationCount > 0) ...[
              6.wSizedBox,
              _corroborationChipBuilder(hazard.corroborationCount),
            ],
          ],
        );
      },
    );
  }

  /// "Confirmed by ×N" — independent community reports of the same event,
  /// never official sources and never a severity signal (classification
  /// standard §11: a corroboration indicator, clearly attributed to the
  /// community, not implying official verification).
  Widget _corroborationChipBuilder(final int corroborationCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.spMin),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.spMin, vertical: 3.spMin),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.users,
            size: 11.spMin,
            color: AppColors.grey,
          ),
          3.wSizedBox,
          Text(
            'Confirmed by ×$corroborationCount',
            style: TextStyle(
              fontSize: 10.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _coloredHeaderBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isUserReported = ref.watch(
          provider.select(
            (value) => value.hazard!.isUserReported,
          ),
        );
        final isAwsCompliant = ref.watch(
          provider.select(
            (value) => value.hazard!.isAwsCompliant ?? false,
          ),
        );
        final severityTitle = ref.watch(
          provider.select(
            (value) => value.hazard!.severityTitle,
          ),
        );
        final source = ref.watch(
          provider.select(
            (value) => value.hazard!.source,
          ),
        );
        final hazardColor = ref.watch(
          provider.select(
            (value) => value.hazard?.color ?? AppColors.black,
          ),
        );

        final isVerified = source != null;

        final pillForegroundColor = hazardColor.isLight
            ? AppColors.grey
            : AppColors.white;
        final pillBackgroundColor = isUserReported
            ? AppColors.white
            : hazardColor.isLight
            ? AppColors.grey
            : AppColors.black;
        final pillBackgroundColorAlpha = isUserReported
            ? 0.6
            : hazardColor == AppColors.transparent
            ? 0.06
            : 0.2;
        final pillBorderColor = hazardColor == AppColors.transparent
            ? AppColors.lightGrey
            : null;

        final severityBand = ref.watch(
          provider.select(
            (value) => value.hazard?.severityBand,
          ),
        );
        // Solid red fill is reserved for official CRITICAL (two-reds rule).
        final isOfficialCritical =
            isVerified && severityBand == HazardSeverityBand.critical;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 10.spMin,
            vertical: 6.spMin,
          ),

          decoration: BoxDecoration(
            gradient:
                isOfficialCritical ? AlertCardStyle.solidRedGradient : null,
            color: isOfficialCritical
                ? null
                : hazardColor == AppColors.transparent
                ? AppColors.white
                : hazardColor,
            border: hazardColor == AppColors.transparent
                ? Border(
                    bottom: BorderSide(
                      color: AppColors.lightGrey.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  )
                : null,
          ),
          child: Row(
            spacing: 10.spMin,
            children: [
              // V3 rule: shape identifies the source system, colour carries
              // urgency — never colour alone.
              Icon(
                AlertCardStyle.systemShapeIcon(
                  isAws: isAwsCompliant,
                  isOfficial: isVerified,
                  isGlobalHumanitarian: widget.hazard.isGlobalHumanitarian,
                  isAlrtIntel: widget.hazard.isAlrtIntel,
                ),
                size: 14.spMin,
                // Official shapes carry the locked band hex; community
                // circles take the category colour, never a band hex.
                color: isOfficialCritical
                    ? AppColors.white
                    : hazardColor == AppColors.transparent ||
                            hazardColor.isLight
                        ? (isVerified
                              ? AlertCardStyle.bandShapeColor(severityBand)
                              : widget.hazard.category?.resolvedColor ??
                                    AppColors.grey)
                        : AppColors.white,
              ),
              // Left: the SOURCE system, one badge and only one. Five
              // possible values (AWS/OFFICIAL/COMMUNITY/GDACS/ALRT INTEL) —
              // GDACS and ALRT Intel are official too, but naming them
              // specifically (not folding into generic OFFICIAL) is what
              // lets a reader tell a humanitarian-monitoring feed or ALRT's
              // own assessment apart from a government agency at a glance.
              _headerPillBuilder(
                label: isAwsCompliant
                    ? 'AWS'
                    : widget.hazard.isAlrtIntel
                    ? 'ALRT INTEL'
                    : widget.hazard.isGlobalHumanitarian
                    ? 'GDACS'
                    : isVerified
                    ? 'OFFICIAL'
                    : 'COMMUNITY',
                foregroundColor: pillForegroundColor,
                backgroundColor: pillBackgroundColor,
                backgroundColorAlpha: pillBackgroundColorAlpha,
                borderColor: pillBorderColor,
              ),
              const Spacer(),
              // Right: the severity word, and only the Australian Warning
              // System ever writes one. No other source states a level.
              if (isAwsCompliant &&
                  severityTitle.isNotEmpty &&
                  severityTitle != 'Unknown')
                Text(
                  severityTitle,
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w800,
                    color: isOfficialCritical
                        ? AppColors.white
                        : hazardColor == AppColors.transparent ||
                              hazardColor.isLight
                        ? AppColors.black
                        : AppColors.white,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// "In plain terms" — mandatory on every card type, not just the detail
  /// screen (locked rule). Same deterministic line as
  /// ViewHazardScreen._buildPlainTermsBox, scaled down for a compact card.
  Widget _plainTermsBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();

        final plainTerms = AlertCardStyle.plainTermsOf(
          isOfficial: !hazard.isUserReported,
          isAws: hazard.isAwsCompliant ?? false,
          severity: hazard.severity,
          band: hazard.severityBand,
          categoryName: hazard.category?.name,
          sourceName: hazard.source?.name,
          locationName: hazard.locationName,
        );
        if (plainTerms == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: AlertCardStyle.plainTermsBackground,
          padding: EdgeInsets.symmetric(
            horizontal: 10.spMin,
            vertical: 6.spMin,
          ),
          child: Text(
            plainTerms,
            style: TextStyle(
              fontSize: 11.spMin,
              height: 1.4,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Widget _headerPillBuilder({
    required final String label,
    final Color backgroundColor = AppColors.black,
    final Color foregroundColor = AppColors.white,
    final Color? borderColor,
    final double backgroundColorAlpha = 0.2,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor.withValues(
          alpha: backgroundColorAlpha,
        ),
        borderRadius: BorderRadius.circular(20.spMin),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.0)
            : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.spMin,
        vertical: 4.spMin,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.spMin,
            height: 6.spMin,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: foregroundColor,
            ),
          ),
          5.wSizedBox,
          Text(
            label,
            style: TextStyle(
              fontSize: 11.spMin,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Triage in half a second: the source shape inside a band-tinted
  /// rounded square. Shape = which system, tint = which band.
  Widget _iconBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final isAwsCompliant = ref.watch(
          provider.select(
            (value) => value.hazard?.isAwsCompliant ?? false,
          ),
        );
        final isOfficial = ref.watch(
          provider.select((value) => value.hazard?.source != null),
        );
        final severityBand = ref.watch(
          provider.select((value) => value.hazard?.severityBand),
        );

        return HazardShapeBadge(
          isAws: isAwsCompliant,
          isOfficial: isOfficial,
          isGlobalHumanitarian: widget.hazard.isGlobalHumanitarian,
          isAlrtIntel: widget.hazard.isAlrtIntel,
          band: severityBand,
        );
      },
    );
  }

  Widget _titleBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final title = ref.watch(
          provider.select(
            (value) => value.hazard?.isUserReported ?? false
                ? value.hazard?.category?.name ?? 'Alert Report'
                : value.hazard!.title ?? 'Alert',
          ),
        );

        return Text(
          title,
          style: TextStyle(
            fontSize: 16.spMin,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _votesCountBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final voteCount = ref.watch(
          provider.select(
            (value) => value.hazard!.voteCount,
          ),
        );
        if (voteCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: voteCount > 0 ? AppColors.green : AppColors.red,
            borderRadius: BorderRadius.circular(14.spMin),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 10.spMin,
            vertical: 4.spMin,
          ),
          child: Row(
            children: [
              Icon(
                voteCount > 0
                    ? Icons.thumb_up_alt_rounded
                    : Icons.thumb_down_alt_rounded,
                size: 14.spMin,
                color: AppColors.white,
              ),
              4.wSizedBox,
              Text(
                '$voteCount',
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ).pL(5.0);
      },
    );
  }

  Widget _dateAndDistanceBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final dateTime = ref.watch(
          provider.select(
            (value) =>
                value.hazard!.updatedAt ??
                value.hazard!.occurredAt ??
                value.hazard!.createdAt,
          ),
        );

        final latitude = ref.watch(
          provider.select(
            (value) => value.hazard!.latitude,
          ),
        );
        final longitude = ref.watch(
          provider.select(
            (value) => value.hazard!.longitude,
          ),
        );

        final distance = ref.watch(
          providerOfLocation.select(
            (value) => latitude == null || longitude == null
                ? null
                : value.distanceTo(latitude, longitude),
          ),
        );

        final distanceText = distance == null
            ? null
            : distance < 1000
            ? '${distance.toStringAsFixed(1)} m'
            : '${(distance / 1000).toStringAsFixed(1)} km';

        final hasExpired = ref.watch(
          provider.select(
            (value) => value.hazard!.isExpired,
          ),
        );

        return Row(
          spacing: 8.spMin,
          children: [
            if (dateTime != null)
              Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 12.spMin,
                    color: hasExpired
                        ? AppColors.red
                        : AppColors.grey.withValues(alpha: 0.6),
                  ),
                  4.wSizedBox,
                  Text(
                    hasExpired ? 'Expired' : timeago.format(dateTime),
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: hasExpired ? AppColors.red : AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

            if (distanceText != null)
              Row(
                children: [
                  Icon(
                    LucideIcons.mapPin,
                    size: 12.spMin,
                    color: AppColors.grey.withValues(alpha: 0.6),
                  ),
                  4.wSizedBox,
                  Text(
                    distanceText,
                    style: TextStyle(
                      fontSize: 12.spMin,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _confirmationButtonsBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final loggedinUserId = ref.watch(
          providerOfLoggedInUser.select(
            (value) => value?.id,
          ),
        );
        final isOwnHazard = ref.watch(
          provider.select(
            (value) => value.hazard!.reportedBy?.id == loggedinUserId,
          ),
        );
        if (isOwnHazard) {
          return const SizedBox.shrink();
        }

        final voteType = ref.watch(
          provider.select((value) => value.hazard!.userVoteType),
        );
        final voteCount = ref.watch(
          provider.select((value) => value.hazard!.voteCount),
        );
        final isExpired = ref.watch(
          provider.select((value) => value.hazard!.isExpired),
        );

        final latitude = ref.watch(
          provider.select(
            (value) => value.hazard!.latitude,
          ),
        );
        final longitude = ref.watch(
          provider.select(
            (value) => value.hazard!.longitude,
          ),
        );
        final distance = ref.watch(
          providerOfLocation.select(
            (value) => latitude == null || longitude == null
                ? null
                : value.distanceTo(latitude, longitude),
          ),
        );
        if (distance == null || distance > 1000) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10.spMin,
          children: [
            Text(
              'Is this alert still active?',
              style: TextStyle(
                fontSize: 14.spMin,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            ConfirmationButtons(
              updateOnPressed: !isExpired,
              initialVoteType: voteType,
              initialVoteCount: voteCount,
              onVotePressed: _voteOnHazard,
            ),
          ],
        ).pT(2.0).pB(16.0);
      },
    );
  }

  Widget _categoryAndViewDetailsBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final categoryId = ref.watch(
          provider.select(
            (value) => value.hazard!.category?.id,
          ),
        );
        final categoryName = ref.watch(
          provider.select(
            (value) =>
                value.hazard!.category?.parent?.name ??
                value.hazard!.category?.name ??
                'Other',
          ),
        );
        final categoryColor = ref.watch(
          provider.select(
            (value) =>
                value.hazard!.category?.resolvedColor ?? AppColors.black,
          ),
        );
        final darkenCategoryColor = categoryId == 'utilitiesAndInfrastructure'
            ? categoryColor.darken(0.3)
            : categoryColor.darken(0.2);

        return Column(
          children: [
            Divider(
              color: AppColors.lightGrey.withValues(alpha: 0.5),
              height: 1.0,
              thickness: 1.0,
            ).pX(10.0),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.spMin,
                vertical: 12.spMin,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.spMin,
                      vertical: 6.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.spMin),
                      border: Border.all(
                        color: darkenCategoryColor,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        fontWeight: FontWeight.w600,
                        color: darkenCategoryColor,
                      ),
                    ),
                  ),
                  // Share sits on the map callout too, so an alert can be
                  // passed on without opening it first.
                  const Spacer(),
                  _shareButtonBuilder(),
                  12.wSizedBox,
                  GestureDetector(
                    onTap: _gotoViewHazard,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 14.spMin,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                  height: 1.0,
                                ),
                              ),
                              0.6.hSizedBox,
                              Container(
                                height: 1.0,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                        ),
                        6.wSizedBox,
                        Icon(
                          Icons.arrow_forward,
                          size: 16.spMin,
                          color: AppColors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _shareButtonBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null || !isAlertShareable(hazard)) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => shareAlert(
            ref: ref,
            hazard: hazard,
            from: widget.isInfoWindow ? 'map_callout' : 'card',
          ),
          child: Padding(
            padding: EdgeInsets.all(7.spMin),
            child: Icon(
              LucideIcons.share,
              size: 17.spMin,
              color: AppColors.grey,
            ),
          ),
        );
      },
    );
  }

  /// Listen to changes in the vote hazard state and show error messages if any.
  void _listenToVoteHazardState() {
    ref.listen<VoteHazardState>(
      provider.select(
        (value) => value.voteState,
      ),
      (previous, next) {
        if (previous != next) {
          next.maybeWhen(
            error: _handleErrors,
            orElse: () {},
          );
        }
      },
    );
  }

  /// Handle error messages from the vote hazard state.
  void _handleErrors(final AppError error) {
    context.showErrorToast(
      message: 'Unable to vote. Please try again.',
    );
  }

  /// Navigate to the View Hazard screen with the current hazard as an argument.
  void _gotoViewHazard() {
    final hazard = ref.read(provider).hazard;
    if (hazard == null) return;

    context.unfocusInputs();
    context.push(
      ViewHazardScreen.route,
      extra: ViewHazardScreenArgs(
        hazard: hazard,
      ),
    );
  }

  /// Handle voting on the hazard by updating the provider and calling the vote function.
  void _voteOnHazard(final HazardVoteType type) {
    final isExpired = ref.read(provider).hazard?.isExpired ?? false;
    if (isExpired) {
      context.showErrorToast(
        message: 'Cannot confirm an expired alert.',
      );
      return;
    }

    ref.read(provider.notifier).voteHazard(voteType: type);
  }
}
