import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/confirmation_buttons.dart';
import 'package:hazard_app/features/shared/enums/hazard_vote_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/hazard_item_provider.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/states/hazard_item_provider_state.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/features/shared/views/widgets/category_glyph.dart';
import 'package:hazard_app/features/shared/views/widgets/hazard_artwork.dart';
import 'package:hazard_app/features/shared/views/widgets/view_hazard_widgets/source_shape_glyph.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:hazard_app/features/shared/extensions/date_time_extension.dart';
import 'package:timeago/timeago.dart' as timeago;

/// The feed card (approved Feed board, 12 Oct 2026). One card everywhere
/// it is shown: the alert list, the map callout and the notification list.
///
/// Top to bottom: a band strip (official and AWS only), the source row
/// (shape glyph, label, how long ago), "In plain terms" on the dark
/// surface (official and AWS only, locked rule), the title, then one meta
/// line (source and distance, or corroboration and distance). Community
/// cards keep the "Can you see it?" vote block below that.
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
    this.simplifiedView = false,
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

  /// Whether to show a simplified version (for map popups).
  final bool simplifiedView;

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

    final isUserReported = ref.watch(
      provider.select((value) => value.hazard!.isUserReported),
    );

    final radius = BorderRadius.circular(AlertCardStyle.cardRadius.spMin);

    return InkWell(
      onTap: _gotoViewHazard,
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: radius,
          boxShadow: const [AlertCardStyle.cardShadow],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Band strip: official and AWS cards only. A community card
              // has no band, so it has no strip.
              if (!isUserReported) _bandStripBuilder(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.spMin,
                  14.spMin,
                  16.spMin,
                  16.spMin,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sourceRowBuilder(),
                    10.hSizedBox,
                    _titleBuilder(),
                    if (!isUserReported && !widget.simplifiedView) ...[
                      6.hSizedBox,
                      _summaryBuilder(),
                    ],
                    6.hSizedBox,
                    _metaRowBuilder(),
                    // Every card opens, so every card says so (product
                    // owner, 16 Oct 2026).
                    if (!widget.simplifiedView) _tapForMoreBuilder(),
                    if (widget.showTrustMeter &&
                        isUserReported &&
                        !widget.isInfoWindow)
                      _confirmationButtonsBuilder(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).pX(widget.horizontalPadding);
  }

  /// The 5 px band strip across the top of an official or AWS card, in
  /// the alert's locked band hex.
  Widget _bandStripBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final bandColor = ref.watch(
          provider.select((value) => value.hazard?.color ?? AppColors.info),
        );
        return Container(
          width: double.infinity,
          height: AlertCardStyle.feedBandStripHeight.spMin,
          color: bandColor,
        );
      },
    );
  }

  /// Row 1: the source shape, the label and how long ago.
  ///
  /// Only the Australian Warning System writes a level word, and it is
  /// the whole label: "ADVICE", "WATCH AND ACT", "EMERGENCY WARNING".
  /// Every other source is named without a level.
  Widget _sourceRowBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();

        final isUserReported = hazard.isUserReported;
        final isAws = !isUserReported && (hazard.isAwsCompliant ?? false);
        final isOfficial = hazard.source != null;
        final severityTitle = hazard.severityTitle;
        final hasAwsLevel =
            isAws && severityTitle.isNotEmpty && severityTitle != 'Unknown';

        final String label;
        final Color labelInk;
        if (isUserReported) {
          label = 'COMMUNITY REPORT';
          labelInk = AlertCardStyle.labelInkCommunity;
        } else if (hazard.isAlrtIntel) {
          label = 'ALRT ASSESSMENT';
          labelInk = AlertCardStyle.labelInkNeutral;
        } else if (hazard.isGlobalHumanitarian) {
          label = 'GDACS';
          labelInk = AlertCardStyle.labelInkNeutral;
        } else if (hasAwsLevel) {
          label = severityTitle.toUpperCase();
          labelInk = AlertCardStyle.bandLabelInk(hazard.severityBand);
        } else if (isAws) {
          label = 'AWS';
          labelInk = AlertCardStyle.bandLabelInk(hazard.severityBand);
        } else {
          label = 'OFFICIAL';
          labelInk = AlertCardStyle.labelInkNeutral;
        }

        final category = hazard.category;
        final Widget glyph = isUserReported && category != null
            ? CategoryGlyph(category: category, size: 26.spMin)
            : SourceShapeGlyph(
                isAws: isAws,
                isOfficial: isOfficial,
                isGlobalHumanitarian: hazard.isGlobalHumanitarian,
                isAlrtIntel: hazard.isAlrtIntel,
                color: hazard.color,
                // Was 14: too small to read (phone review, 14 Oct 2026).
                size: 20.spMin,
              );

        return Row(
          children: [
            glyph,
            8.wSizedBox,
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: labelInk,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            8.wSizedBox,
            _agoBuilder(),
          ],
        );
      },
    );
  }

  /// How long ago, right-aligned. An expired alert says so instead.
  Widget _agoBuilder() {
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
        final hasExpired = ref.watch(
          provider.select((value) => value.hazard!.isExpired),
        );
        if (dateTime == null && !hasExpired) return const SizedBox.shrink();

        return Text(
          hasExpired ? 'Expired' : timeago.format(dateTime!),
          style: TextStyle(
            fontSize: 12.spMin,
            color: hasExpired ? AppColors.red : AlertCardStyle.metaInk,
          ),
        );
      },
    );
  }

  /// The agency's own summary, as given (its description), two lines. Only
  /// when the source gave none do we fall back to the neutral line that
  /// names who reported what. Severity is never touched here.
  Widget _summaryBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();

        // Cleaned source facts, never the raw feed fields.
        final given = AlertCardStyle.factLines(
          hazard.description,
          title: hazard.title,
        ).take(2).join('\n');
        final text = given.isNotEmpty
            ? given
            : AlertCardStyle.plainTermsOf(
                isOfficial: !hazard.isUserReported,
                isAws: hazard.isAwsCompliant ?? false,
                severity: hazard.severity,
                band: hazard.severityBand,
                categoryName: hazard.category?.name,
                sourceName: hazard.source?.name,
                locationName: hazard.locationName,
                title: hazard.title,
                hasAdvice: AlertCardStyle.hasAgencyAdvice(hazard.callsToAction),
              );
        if (text == null || text.isEmpty) return const SizedBox.shrink();

        return Text(
          text,
          style: TextStyle(
            fontSize: 12.5.spMin,
            height: 1.4,
            color: AppColors.black.withValues(alpha: 0.85),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  /// A small "Tap for more" with an arrow, so it is clear the card opens.
  Widget _tapForMoreBuilder() {
    return Padding(
      padding: EdgeInsets.only(top: 8.spMin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tap for more',
            style: TextStyle(
              fontSize: 11.5.spMin,
              fontWeight: FontWeight.w600,
              color: AppColors.mediumGrey,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20.spMin,
            color: AppColors.ink,
          ),
        ],
      ),
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

        final hazard = ref.watch(provider.select((value) => value.hazard));

        // Title on the left, the alert's own pin artwork on the right so
        // the card and its map pin match (product owner, 16 Oct 2026).
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17.spMin,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppColors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hazard != null) ...[
              10.wSizedBox,
              HazardArtwork(hazard: hazard, size: 44.spMin),
            ],
          ],
        );
      },
    );
  }

  /// Row 4. Official: a category dot, then "<source> · 8.4 km away".
  /// Community: "Confirmed by ×N · 940 m away", with the corroboration
  /// fragment left out while nobody has confirmed it. "Confirmed by" is
  /// independent community reports, never official verification.
  Widget _metaRowBuilder() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();

        final latitude = hazard.latitude;
        final longitude = hazard.longitude;
        final distance = ref.watch(
          providerOfLocation.select(
            (value) => latitude == null || longitude == null
                ? null
                : value.distanceTo(latitude, longitude),
          ),
        );
        final distanceText = distance == null
            ? null
            : '${AlertCardStyle.distanceLabel(distance)} away';

        final fragments = <String>[];
        if (hazard.isUserReported) {
          if (hazard.corroborationCount > 0) {
            fragments.add('Confirmed by ×${hazard.corroborationCount}');
          }
        } else {
          final sourceName = hazard.source?.name?.trim();
          if (sourceName != null && sourceName.isNotEmpty) {
            fragments.add(sourceName);
          }
        }
        
        // Add "Posted X ago" timestamp
        if (hazard.createdAt != null) {
          fragments.add('Posted ${hazard.createdAt!.timeAgo}');
        }
        
        if (distanceText != null) fragments.add(distanceText);
        if (fragments.isEmpty) return const SizedBox.shrink();

        final categoryColor = hazard.category?.resolvedColor;

        return Row(
          children: [
            if (!hazard.isUserReported && categoryColor != null) ...[
              Container(
                width: 8.spMin,
                height: 8.spMin,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              6.wSizedBox,
            ],
            Expanded(
              child: Text(
                fragments.join(' · '),
                style: TextStyle(
                  fontSize: 13.spMin,
                  color: AlertCardStyle.metaInk,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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

        // One wording everywhere: the same label, helper and buttons as
        // the detail screen's vote section.
        return Padding(
          padding: EdgeInsets.only(top: 14.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10.spMin,
            children: [
              const ConfirmationPrompt(),
              ConfirmationButtons(
                updateOnPressed: !isExpired,
                initialVoteType: voteType,
                initialVoteCount: voteCount,
                onVotePressed: _voteOnHazard,
              ),
            ],
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
