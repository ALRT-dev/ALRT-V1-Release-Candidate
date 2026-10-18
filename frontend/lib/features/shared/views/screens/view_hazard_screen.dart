import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/utils/alert_text_util.dart';
import 'package:hazard_app/features/shared/utils/alert_guidance_library.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_check_in_consent_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_choose_circle_sheet.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/learn/views/widgets/guide_strip_card.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/notification/views/widgets/confirmation_buttons.dart';
import 'package:hazard_app/features/shared/providers/hazard_item_provider.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/shared/enums/ai_confidence_types.dart';
import 'package:hazard_app/features/shared/enums/alrt_media_types.dart';
import 'package:hazard_app/features/shared/enums/hazard_review_status_types.dart';
import 'package:hazard_app/features/shared/enums/video_priority_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/states/view_hazard_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/date_time_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/profile/views/widgets/for_you_card.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/followed_alerts_provider.dart';
import 'package:hazard_app/features/shared/models/video_id_priority_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/video_preview_lifecycle_provider.dart';
import 'package:hazard_app/features/shared/providers/view_hazard_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/features/shared/utils/share_alert.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/features/shared/views/widgets/category_glyph.dart';
import 'package:hazard_app/features/shared/views/widgets/report_content_sheet.dart';
import 'package:hazard_app/features/shared/views/widgets/small_map_view.dart';
import 'package:hazard_app/features/shared/views/widgets/view_hazard_widgets/hazard_medias_carousel.dart';
import 'package:hazard_app/features/shared/views/widgets/view_hazard_widgets/send_to_group_sheet.dart';
import 'package:hazard_app/features/shared/views/widgets/view_hazard_widgets/source_shape_glyph.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'dart:math' as math;

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hazard_app/features/shared/services/alert_speech_service.dart';

class ViewHazardScreenArgs {
  ViewHazardScreenArgs({required this.hazard});

  /// The hazard to be viewed.
  final Hazard hazard;
}

class ViewHazardScreen extends ConsumerStatefulWidget {
  const ViewHazardScreen({
    super.key,
    required this.args,
  });

  /// The arguments for the screen.
  final ViewHazardScreenArgs args;

  static const route = '/view-hazard';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewHazardScreenState();
}

class _ViewHazardScreenState extends ConsumerState<ViewHazardScreen> {
  late final provider = providerOfViewHazard(widget.args.hazard.id!);

  /// Attribution shows one compact line until the reader asks for the
  /// licence and copyright detail.
  bool _attributionExpanded = false;
  bool _whatToDoExpanded = false;
  bool _whatWeKnowExpanded = false;
  bool _fullAlertExpanded = false;

  /// Whether this alert is being read aloud right now. Drives the lit
  /// Listen button, and is cleared when the speech ends on its own.
  bool _isSpeaking = false;

  /// Whether the user has already checked in near this alert.
  bool _checkInSent = false;

  /// The lit state of Follow and Listen: the brand orange.
  static const _litInk = Color(0xFFFF6B01);
  static const _litWash = Color(0xFFFFF0E4);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
  }

  @override
  void dispose() {
    // Leaving the alert stops it being read. Speech that follows you out
    // of the screen it belongs to is the kind of thing people turn the
    // whole feature off over. Unconditional: _isSpeaking can be stale if
    // the flag reset raced the engine, and stop() on silence is a no-op.
    ref.read(providerOfAlertSpeech).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.args.hazard.id == null) {
      throw Exception('Hazard ID is required to view hazard.');
    }
    final hasHazard = ref.watch(
      provider.select(
        (value) => value.hazard != null,
      ),
    );
    if (!hasHazard) {
      return const SizedBox.shrink();
    }

    // register this provider to the lifecycle of this widget
    ref.watch(provider.select((value) => null));
    _registerVideoPriorityProviders();

    _listenToTheDeleteHazardState();

    final loggedInUserId = ref.watch(
      providerOfLoggedInUser.select((value) => value?.id),
    );

    final isMyReport = ref.watch(
      provider.select(
        (value) => value.hazard?.reportedBy?.id == loggedInUserId,
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.spMin, 4.spMin, 20.spMin, 20.spMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMyReport) ...[
                    _buildEditDeleteRow(),
                    16.hSizedBox,
                  ],
                  _buildHeaderCard(),
                  16.hSizedBox,

                  // Review feedback section (if applicable)
                  Consumer(
                    builder: (context, ref, child) {
                      final reportedById = ref.watch(
                        provider.select(
                          (value) => value.hazard?.reportedBy?.id,
                        ),
                      );
                      final reviewFeedback = ref.watch(
                        provider.select(
                          (value) => value.hazard?.reviewFeedback,
                        ),
                      );

                      final hasFeedback =
                          reportedById == loggedInUserId &&
                          (reviewFeedback?.isNotEmpty ?? false);

                      if (!hasFeedback) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: [
                          _buildReviewFeedbackSectionNew(),
                          24.spMin.hSizedBox,
                        ],
                      );
                    },
                  ),

                  // White Content Section
                  _buildWhiteContentSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top controls ───────────────────────────────────────────────────────

  /// Page-coloured bar with floating white round controls (approved Detail
  /// board, 12 Oct 2026). Official: back left; Follow pill and Listen
  /// right. Community: back, a centred "Community report" title, share.
  Widget _buildAppBar() {
    final isUserReported = ref.watch(
      provider.select((value) => value.hazard!.isUserReported),
    );

    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: AppColors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 56.spMin,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.spMin),
        child: isUserReported
            ? _buildCommunityTopControls()
            : _buildOfficialTopControls(),
      ),
    );
  }

  Widget _buildOfficialTopControls() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        final id = hazard?.id;
        if (hazard == null || id == null) return const SizedBox.shrink();
        final isFollowing =
            ref.watch(providerOfFollowedAlerts).contains(id);

        return Row(
          children: [
            _roundControl(
              icon: LucideIcons.chevronLeft,
              semanticLabel: 'Back',
              onTap: () => context.pop(),
            ),
            const Spacer(),
            _followPill(
              isFollowing: isFollowing,
              onTap: () =>
                  ref.read(providerOfFollowedAlerts.notifier).toggle(id),
            ),
            8.wSizedBox,
            _roundControl(
              icon: LucideIcons.volume2,
              semanticLabel: _isSpeaking ? 'Stop' : 'Listen',
              lit: _isSpeaking,
              onTap: () => _speakAlert(ref, hazard),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommunityTopControls() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();
        final canShare = isAlertShareable(hazard);

        return Row(
          children: [
            _roundControl(
              icon: LucideIcons.chevronLeft,
              semanticLabel: 'Back',
              onTap: () => context.pop(),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Community report',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            if (canShare)
              _roundControl(
                icon: LucideIcons.share2,
                semanticLabel: 'Share',
                onTap: () =>
                    shareAlert(ref: ref, hazard: hazard, from: 'detail'),
              )
            else
              SizedBox(width: 40.spMin),
          ],
        );
      },
    );
  }

  /// A 40 px floating white round control.
  Widget _roundControl({
    required final IconData icon,
    required final VoidCallback onTap,
    final String? semanticLabel,
    final bool lit = false,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Container(
        width: 40.spMin,
        height: 40.spMin,
        decoration: BoxDecoration(
          color: lit ? _litWash : AppColors.white,
          shape: BoxShape.circle,
          border: lit ? Border.all(color: _litInk, width: 1.5) : null,
          boxShadow: const [AlertCardStyle.cardShadow],
        ),
        child: Material(
          color: AppColors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Icon(
                icon,
                size: 18.spMin,
                color: lit ? _litInk : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The Follow pill: bell plus "Follow", filled orange-tint once followed.
  Widget _followPill({
    required final bool isFollowing,
    required final VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 40.spMin,
      decoration: BoxDecoration(
        color: isFollowing ? _litWash : AppColors.white,
        borderRadius: BorderRadius.circular(20.spMin),
        border: isFollowing ? Border.all(color: _litInk, width: 1.5) : null,
        boxShadow: const [AlertCardStyle.cardShadow],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(20.spMin),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.spMin),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.bell,
                  size: 16.spMin,
                  color: isFollowing ? _litInk : AppColors.ink,
                ),
                6.wSizedBox,
                Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    fontWeight: FontWeight.w600,
                    color: isFollowing ? _litInk : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditDeleteRow() {
    return Row(
      spacing: 12.spMin,
      children: [
        // Editing a published alert is off: an edit would skip review.
        // The poster can delete it and post a new one.
        Expanded(child: _buildDeleteButton()),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: const [AlertCardStyle.cardShadow],
      ),
      padding: EdgeInsets.all(16.spMin),
      child: Icon(
        LucideIcons.trash2,
        color: AppColors.red,
        size: 20.spMin,
      ),
    ).onPressed(() => _handleDeleteHazard());
  }

  // ── Header card ────────────────────────────────────────────────────────

  /// The header card (approved Detail board): band strip, source row,
  /// "In plain terms", title, the small map with "Show on map", and one
  /// location line. Community reports get the category header instead.
  Widget _buildHeaderCard() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();

        final radius = BorderRadius.circular(AlertCardStyle.cardRadius.spMin);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: radius,
            boxShadow: const [AlertCardStyle.cardShadow],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!hazard.isUserReported)
                Container(
                  width: double.infinity,
                  height: AlertCardStyle.detailBandStripHeight.spMin,
                  color: hazard.color,
                ),
              Padding(
                padding: EdgeInsets.all(16.spMin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hazard.isUserReported)
                      _communitySourceRow(hazard)
                    else ...[
                      _officialSourceRow(hazard),
                      10.hSizedBox,
                      _buildPlainTermsBox(),
                    ],
                    12.hSizedBox,
                    Text(
                      _titleOf(hazard),
                      style: TextStyle(
                        fontSize: 21.spMin,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: AppColors.black,
                      ),
                    ),
                    if (hazard.latitude != null &&
                        hazard.longitude != null) ...[
                      14.hSizedBox,
                      _buildSmallMap(hazard),
                    ],
                    10.hSizedBox,
                    _buildLocationLine(hazard),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// The headline: the alert's own title, or, for a community report with
  /// none, its category.
  String _titleOf(final Hazard hazard) {
    final title = hazard.title?.trim();
    if (title != null && title.isNotEmpty) return title;
    if (hazard.isUserReported) {
      return hazard.category?.name ?? 'Community report';
    }
    return 'Alert';
  }

  /// Official and AWS: shape glyph, the label (only the Australian Warning
  /// System writes a level word), and "source · ago" on the right.
  Widget _officialSourceRow(final Hazard hazard) {
    final isAws = hazard.isAwsCompliant ?? false;
    final severityTitle = hazard.severityTitle;
    final hasAwsLevel =
        isAws && severityTitle.isNotEmpty && severityTitle != 'Unknown';

    final String label;
    final Color labelInk;
    if (hazard.isAlrtIntel) {
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

    final postedAt = hazard.createdAt ?? hazard.occurredAt;
    final sourceName = hazard.source?.name?.trim();
    final right = [
      if (sourceName != null && sourceName.isNotEmpty) sourceName,
      if (postedAt != null) postedAt.timeAgo,
    ].join(' · ');

    return Row(
      children: [
        SourceShapeGlyph(
          isAws: isAws,
          isOfficial: hazard.source != null,
          isGlobalHumanitarian: hazard.isGlobalHumanitarian,
          isAlrtIntel: hazard.isAlrtIntel,
          color: hazard.color,
          size: 14.spMin,
        ),
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
        if (right.isNotEmpty) ...[
          8.wSizedBox,
          Text(
            right,
            style: TextStyle(
              fontSize: 12.spMin,
              color: AlertCardStyle.metaInk,
            ),
          ),
        ],
      ],
    );
  }

  /// Community: the category disc in a rounded square, the category name
  /// in the V3 label orange, "Unverified · ago", and the corroboration
  /// pill on the right ("Confirmed by ×N" is independent community
  /// reports, never official verification).
  Widget _communitySourceRow(final Hazard hazard) {
    final category = hazard.category;
    final categoryName =
        (category?.parent?.name ?? category?.name ?? 'Other').toUpperCase();
    final postedAt = hazard.createdAt ?? hazard.occurredAt;
    final categoryColor = category?.resolvedColor ?? AppColors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56.spMin,
          height: 56.spMin,
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14.spMin),
          ),
          alignment: Alignment.center,
          child: category == null
              ? Icon(LucideIcons.users, size: 24.spMin, color: categoryColor)
              : CategoryGlyph(category: category, size: 40.spMin),
        ),
        12.wSizedBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 12.spMin,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AlertCardStyle.labelInkCommunity,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              3.hSizedBox,
              Text(
                postedAt == null
                    ? 'Unverified'
                    : 'Unverified · ${postedAt.timeAgo}',
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: AlertCardStyle.metaInk,
                ),
              ),
            ],
          ),
        ),
        if (hazard.corroborationCount > 0) ...[
          8.wSizedBox,
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.spMin,
              vertical: 4.spMin,
            ),
            decoration: BoxDecoration(
              color: AppColors.extraLightGrey,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Confirmed by ×${hazard.corroborationCount}',
              style: TextStyle(
                fontSize: 11.spMin,
                fontWeight: FontWeight.w600,
                color: AlertCardStyle.metaInk,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// The "In plain terms" box on the dark surface.
  Widget _buildPlainTermsBox() {
    return Consumer(
      builder: (context, ref, child) {
        // Locked rule (product owner, 2026-08-05): In plain terms states
        // only what has been reported and that the agency is giving
        // advice. This box used to print the AI summary, which is ALRT
        // writing its own statements about a hazard: exactly what we do
        // not do. The deterministic line is the same one the list card
        // shows, so both surfaces say the same thing.
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
          hasAdvice: hazard.callsToAction?.isNotEmpty ?? false,
        );
        if (plainTerms == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // The plain-terms surface is always the dark band (locked).
            color: AlertCardStyle.plainTermsBackground,
            borderRadius: BorderRadius.circular(10.spMin),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 11.spMin,
            vertical: 9.spMin,
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'In plain terms ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AlertCardStyle.plainTermsLeadInk,
                  ),
                ),
                TextSpan(text: plainTerms),
              ],
            ),
            style: TextStyle(
              fontSize: 12.spMin,
              height: 1.55,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  /// The small map inside the header, with a white "Show on map" pill
  /// bottom-right that opens the Map tab centred on this alert.
  Widget _buildSmallMap(final Hazard hazard) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.spMin),
      child: SizedBox(
        height: 130.spMin,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.extraLightGrey,
                child: SmallMapView(hazard: hazard, height: 130.0),
              ),
            ),
            Positioned(
              right: 10.spMin,
              bottom: 10.spMin,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [AlertCardStyle.cardShadow],
                ),
                child: Material(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showOnMap(hazard),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.spMin,
                        vertical: 7.spMin,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.map,
                            size: 14.spMin,
                            color: AppColors.ink,
                          ),
                          6.wSizedBox,
                          Text(
                            'Show on map',
                            style: TextStyle(
                              fontSize: 12.spMin,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One location line: "place · 8.4 km from you", with "Updated ago"
  /// trailing when the alert has been touched since it was posted.
  Widget _buildLocationLine(final Hazard hazard) {
    return Consumer(
      builder: (context, ref, child) {
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
            : distance < 1000
            ? '${distance.toStringAsFixed(0)} m from you'
            : '${(distance / 1000).toStringAsFixed(1)} km from you';

        final place = hazard.locationName?.trim();
        final updatedAt = hazard.updatedAt;
        final fragments = [
          if (place != null && place.isNotEmpty) place,
          if (distanceText != null) distanceText,
          if (updatedAt != null) 'Updated ${updatedAt.timeAgo}',
        ];
        if (fragments.isEmpty) return const SizedBox.shrink();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.mapPin,
              size: 14.spMin,
              color: AlertCardStyle.metaInk,
            ).pT(1.0),
            6.wSizedBox,
            Expanded(
              child: Text(
                fragments.join(' · '),
                style: TextStyle(
                  fontSize: 13.spMin,
                  height: 1.35,
                  color: AlertCardStyle.metaInk,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Leaves the alert for the Map tab, centred on this alert with it
  /// selected, so the callout opens where the pin is.
  void _showOnMap(final Hazard hazard) {
    final latitude = hazard.latitude;
    final longitude = hazard.longitude;
    if (latitude == null || longitude == null) return;

    ref.read(providerOfHomeTab.notifier).state = HomeTab.map;
    final map = ref.read(providerOfMap.notifier);
    map.updateSelectedHazard(hazard);
    map.focusOnPosition(
      position: LatLng(latitude, longitude),
      zoom: 13.0,
    );
    context.go(HomeScreen.route, extra: HomeScreenArgs(initialTab: HomeTab.map));
  }

  // ── Body ───────────────────────────────────────────────────────────────

  Widget _buildWhiteContentSection() {
    // Section order per ruling L46 (8 Oct 2026, approved Detail board):
    // Source strip, In plain terms, title, map and location - all in the
    // header above - then: What we know, What to do (verbatim), For you,
    // Tell your people, the community vote, attribution.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Medias: photos/video attached to the alert.
        _buildMediasSection(),

        // What we know: the SOURCE's own description, verbatim. Not our
        // words and not an AI summary.
        _buildOfficialDescriptionSection(),

        // What To Do Section (verbatim from source)
        _buildWhatToDoSection(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.spMin),
          child: Text(
            AlertTextUtil.standingEmergencyLine,
            style: TextStyle(
              fontSize: 13.spMin,
              height: 1.4,
              color: AppColors.mediumGrey,
            ),
          ),
        ),

        // For You: profile-pinned guidance. On-device matching, zero AI.
        Consumer(
          builder: (context, ref, child) {
            final categoryName = ref.watch(
              provider.select((value) => value.hazard?.category?.name),
            );
            final parentCategoryName = ref.watch(
              provider.select((value) => value.hazard?.category?.parent?.name),
            );
            final isAws = ref.watch(
              provider.select(
                (value) => value.hazard?.isAwsCompliant ?? false,
              ),
            );
            final title = ref.watch(
              provider.select((value) => value.hazard?.title),
            );
            return ForYouCard(
              categoryName: categoryName,
              parentCategoryName: parentCategoryName,
              title: title,
              isAws: isAws,
            );
          },
        ),

        // Tell your people: Send to my group, Check in, Share a link.
        _buildTellYourPeopleSection(),

        // Community alerts: I see it / I don't see it voting, the
        // unverified note, then Follow / Listen / Report.
        _buildCommunityVoteSection(),
        12.hSizedBox,

        // Attribution
        _buildSourceSection(),
        40.hSizedBox,
      ],
    );
  }

  /// "Send to my group": opens the send sheet for the active group.
  /// Everyone in it gets the alert and the sender's optional note.
  Future<void> _sendAlertToGroup(final Hazard hazard) async {
    final circle = ref.read(providerOfFamily).circle;
    if (circle == null) return;

    final sent = await showSendToGroupSheet(
      context: context,
      hazard: hazard,
      circleId: circle.id,
      circleName: circle.name,
    );
    if (!mounted || sent == null) return;
    if (sent) {
      context.showSuccessToast(message: 'Sent to ${circle.name}.');
    } else {
      context.showErrorToast(
        message: 'That could not be sent. Please try again.',
      );
    }
  }

  /// Sends a personal check-in near this alert to the user's family circle.
  Future<void> _sendCheckIn(final Hazard hazard) async {
    final title = hazard.title;
    final choice = await showCheckInConsentSheet(
      context,
      contextLine: title == null ? null : 'About the alert: $title',
      sharingLevel: ref.read(providerOfFamily).circle?.me?.sharingLevel,
    );
    if (choice == null || !mounted) return;
    await ref.read(providerOfFamily.notifier).checkIn(
          message: title == null
              ? 'Checked in'
              : 'Checked in near "$title"',
          shareLocation:
              choice == CheckInConsentChoice.checkInAndShareLocation,
          hazardId: hazard.id,
        );
    if (!mounted) return;
    final result = ref.read(providerOfFamily).checkInState;
    if (result.isError && result.error != null) {
      await showFamilyActionError(context, ref, result.error!);
      return;
    }
    if (result.isSuccess) setState(() => _checkInSent = true);
  }

  /// Speaks the alert: source, title, plain terms, then the description.
  /// Tapping Listen again while speaking stops it.
  Future<void> _speakAlert(final WidgetRef ref, final Hazard hazard) async {
    final speech = ref.read(providerOfAlertSpeech);
    // Pressing it again stops it.
    if (_isSpeaking || speech.isSpeaking) {
      await speech.stop();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }
    final plainTerms = AlertCardStyle.plainTermsOf(
      isOfficial: !hazard.isUserReported,
      isAws: hazard.isAwsCompliant ?? false,
      severity: hazard.severity,
      band: hazard.severityBand,
      categoryName: hazard.category?.name,
      sourceName: hazard.source?.name,
      locationName: hazard.locationName,
      hasAdvice: hazard.callsToAction?.isNotEmpty ?? false,
    );
    final text = [
      hazard.isUserReported
          ? 'Community report, unverified.'
          : 'Official alert from ${hazard.source?.name ?? 'an official source'}.',
      hazard.title ?? '',
      if (plainTerms != null) 'In plain terms: $plainTerms.',
      hazard.description ?? '',
    ].where((line) => line.trim().isNotEmpty).join(' ');

    setState(() => _isSpeaking = true);
    await speech.speak(text);
    // speak() completes when the voice finishes, so the button drops back
    // to Listen on its own rather than staying lit forever.
    if (mounted) setState(() => _isSpeaking = false);
  }

  // ── Tell your people ───────────────────────────────────────────────────

  /// TELL YOUR PEOPLE (approved Detail board): the indigo group card with
  /// "Send to my group", "Check in" and "Share a link". Nothing is shown
  /// when the user has no group.
  Widget _buildTellYourPeopleSection() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();

        final circleName = ref.watch(
          providerOfFamily.select((s) => s.circle?.name),
        );
        if (circleName == null) return const SizedBox.shrink();

        final memberCount = ref.watch(
          providerOfFamily.select((s) => s.circle?.members.length ?? 0),
        );
        final circleCount = ref.watch(
          providerOfFamily.select((s) => s.circles.length),
        );
        final isSending = ref.watch(
          providerOfFamily.select((s) => s.checkInState.isLoading),
        );
        final canShare = isAlertShareable(hazard);
        final canPickGroup = circleCount > 1;
        final peopleLine =
            '$circleName · $memberCount ${memberCount == 1 ? 'person' : 'people'}';

        return Padding(
          padding: EdgeInsets.only(top: 16.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // V3 section label
              Padding(
                padding: EdgeInsets.only(bottom: 10.spMin),
                child: Text(
                  'TELL YOUR PEOPLE',
                  style: TextStyle(
                    fontSize: 11.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: AlertCardStyle.officialSectionHeaderColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(14.spMin),
                decoration: BoxDecoration(
                  gradient: FamilyColors.headerGradient,
                  borderRadius:
                      BorderRadius.circular(AlertCardStyle.cardRadius.spMin),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group line. More than one group: tap to change.
                    InkWell(
                      onTap: canPickGroup
                          ? () => showChooseCircleSheet(context, ref)
                          : null,
                      borderRadius: BorderRadius.circular(8.spMin),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.users,
                            size: 15.spMin,
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                          8.wSizedBox,
                          Expanded(
                            child: Text(
                              peopleLine,
                              style: TextStyle(
                                fontSize: 14.spMin,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (canPickGroup) ...[
                            Text(
                              'tap to change',
                              style: TextStyle(
                                fontSize: 12.spMin,
                                color: AppColors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 14.spMin,
                              color: AppColors.white.withValues(alpha: 0.85),
                            ),
                          ],
                        ],
                      ),
                    ),
                    14.hSizedBox,
                    // One compact row: Check in, Send to group, Share.
                    Row(
                      children: [
                        Expanded(
                          child: _groupButton(
                            label: _checkInSent ? 'Checked in' : 'Check in',
                            icon: _checkInSent
                                ? LucideIcons.circleCheck
                                : LucideIcons.heartHandshake,
                            onTap: _checkInSent || isSending
                                ? null
                                : () => _sendCheckIn(hazard),
                          ),
                        ),
                        8.wSizedBox,
                        Expanded(
                          child: _groupButton(
                            label: 'Send to group',
                            icon: LucideIcons.send,
                            filled: true,
                            loading: isSending,
                            onTap: isSending
                                ? null
                                : () => _sendAlertToGroup(hazard),
                          ),
                        ),
                        if (canShare) ...[
                          8.wSizedBox,
                          Expanded(
                            child: _groupButton(
                              label: 'Share',
                              icon: LucideIcons.share2,
                              onTap: () => shareAlert(
                                ref: ref,
                                hazard: hazard,
                                from: 'detail',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// A compact tile on the indigo card: icon over a short label. White
  /// with indigo ink when [filled], otherwise translucent white.
  Widget _groupButton({
    required final String label,
    required final IconData icon,
    final bool filled = false,
    final bool loading = false,
    final VoidCallback? onTap,
  }) {
    const filledInk = Color(0xFF3229C4);
    final ink = filled ? filledInk : AppColors.white;
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled || loading ? 1.0 : 0.6,
      child: Container(
        height: 56.spMin,
        decoration: BoxDecoration(
          color: filled
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12.spMin),
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(12.spMin),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 18.spMin,
                      height: 18.spMin,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ink,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.spMin),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 18.spMin, color: ink),
                          3.hSizedBox,
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12.spMin,
                                  fontWeight: FontWeight.w700,
                                  color: ink,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Community vote ─────────────────────────────────────────────────────

  /// Community reports: "I see it / I don't see it" voting, the unverified
  /// note, then Follow / Listen / Report as three outlined pills.
  Widget _buildCommunityVoteSection() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        final id = hazard?.id;
        if (hazard == null || id == null || !hazard.isUserReported) {
          return const SizedBox.shrink();
        }

        final itemProvider = providerOfHazardItem(id);
        final voteType = ref.watch(
          itemProvider.select((value) => value.hazard?.userVoteType),
        );
        final voteCount = ref.watch(
          itemProvider.select((value) => value.hazard?.voteCount ?? 0),
        );
        final isFollowing =
            ref.watch(providerOfFollowedAlerts).contains(id);

        return Padding(
          padding: EdgeInsets.only(top: 16.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // One wording everywhere: the same label, helper, buttons
              // and count line as the feed card. The vote handler is the
              // same call the inline buttons made before.
              const ConfirmationPrompt(),
              10.hSizedBox,
              ConfirmationButtons(
                key: ValueKey('vote-$id'),
                initialVoteType: voteType,
                initialVoteCount: voteCount,
                onVotePressed: (type) => ref
                    .read(itemProvider.notifier)
                    .voteHazard(voteType: type),
              ),
              12.hSizedBox,
              // Community reports are never authority. Said once, plainly.
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.spMin),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEEA),
                  borderRadius: BorderRadius.circular(12.spMin),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 16.spMin,
                      color: AppColors.mediumGrey,
                    ),
                    8.wSizedBox,
                    Expanded(
                      child: Text(
                        'Community reports are not verified by authorities '
                        'and can be wrong. Always follow official advice. '
                        'This report disappears when its time runs out.',
                        style: TextStyle(
                          fontSize: 12.5.spMin,
                          height: 1.4,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              12.hSizedBox,
              // Follow / Listen / Report: one row of three outlined pills.
              // Report opens the review-or-block sheet (3 flags sends the
              // report back to review).
              Row(
                children: [
                  _outlinedPill(
                    label: isFollowing ? 'Following' : 'Follow',
                    icon: LucideIcons.bell,
                    highlighted: isFollowing,
                    onTap: () =>
                        ref.read(providerOfFollowedAlerts.notifier).toggle(id),
                  ),
                  8.wSizedBox,
                  _outlinedPill(
                    label: _isSpeaking ? 'Stop' : 'Listen',
                    icon: LucideIcons.volume2,
                    highlighted: _isSpeaking,
                    onTap: () => _speakAlert(ref, hazard),
                  ),
                  8.wSizedBox,
                  _outlinedPill(
                    label: 'Report',
                    icon: LucideIcons.flag,
                    onTap: () => showReportContentSheet(
                      context: context,
                      hazard: hazard,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// One of the three outlined pills under the community note.
  Widget _outlinedPill({
    required final String label,
    required final IconData icon,
    required final VoidCallback onTap,
    final bool highlighted = false,
  }) {
    final ink = highlighted ? _litInk : const Color(0xFF5F5C66);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11.spMin),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40.spMin,
          decoration: BoxDecoration(
            color: highlighted ? _litWash : AppColors.white,
            borderRadius: BorderRadius.circular(11.spMin),
            border: Border.all(
              color: highlighted ? _litInk : const Color(0xFFD8D4DE),
              width: highlighted ? 2.0 : 1.5,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14.spMin, color: ink),
                6.wSizedBox,
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildMediasSection() {
    return Consumer(
      builder: (context, ref, child) {
        final hazardId = ref.watch(
          provider.select((value) => value.hazard?.id),
        );
        final processedMedias = ref.watch(
          provider.select((value) => value.hazard?.processedMedias ?? []),
        );

        if (processedMedias.isEmpty || hazardId == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploaded Medias',
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w600,
              ),
            ),
            12.spMin.hSizedBox,
            HazardMediasCarousel(
              id: hazardId,
              medias: processedMedias,
              videoPriority: VideoPriority.level1,
              registerVideoLifecycle: true,
            ),
            16.hSizedBox,
          ],
        );
      },
    );
  }

  /// Matches a What To Do line the backend built as an attribution prefix
  /// relaying a source's own instruction, e.g. "NSW SES advises: do not
  /// drive through floodwater." - see the classification standard's
  /// directive-extraction rule (every relayed instruction is prefixed with
  /// the issuing agency's name and the word "advises:").
  /// A "What to do" card. Used for DIRECTED (the agency's own ranked words),
  /// CONSIDER (ALRT's general guidance when the agency gave no directive) and
  /// community reports. A small pill says whose words these are, a "Show all"
  /// expander reveals anything past the 3-point cap, and a "See full alert"
  /// expander shows the complete original source text.
  Widget _buildGuidanceCard({
    required final String label,
    required final Color color,
    required final List<String> items,
    required final int totalItems,
    required final bool expanded,
    required final VoidCallback onToggle,
    required final bool showAll,
    final String? pill,
    final Color? pillBg,
    final Color? pillFg,
    final String? fullText,
    final String? fullLink,
    final String? lead,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColorLight,
            blurRadius: 2.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.spMin),
          border: Border(
            left: BorderSide(color: color, width: 4),
            right: BorderSide(color: color, width: 1),
            bottom: BorderSide(color: color, width: 1),
            top: BorderSide(color: color, width: 1),
          ),
        ),
        padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 8.spMin, 16.spMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 13.spMin,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (pill != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.spMin,
                      vertical: 2.spMin,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(6.spMin),
                      border: Border.all(color: pillFg!.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      pill,
                      style: TextStyle(
                        fontSize: 9.5.spMin,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: pillFg,
                      ),
                    ),
                  ),
              ],
            ),
            12.spMin.hSizedBox,
            if (lead != null) ...[ 
              Padding(
                padding: EdgeInsets.only(bottom: 10.spMin),
                child: Text(
                  lead,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < items.length - 1 ? 8.spMin : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: AppColors.black.withValues(alpha: 0.9),
                        fontSize: 14.spMin,
                        height: 1.5,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: AppColors.black.withValues(alpha: 0.9),
                          fontSize: 14.spMin,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (showAll)
              InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.spMin),
                  child: Row(
                    children: [
                      Text(
                        expanded ? 'Show less' : 'Show all $totalItems',
                        style: TextStyle(
                          fontSize: 12.5.spMin,
                          fontWeight: FontWeight.w700,
                          color: AlertCardStyle.officialSectionHeaderColor,
                        ),
                      ),
                      SizedBox(width: 4.spMin),
                      Icon(
                        expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                        size: 14.spMin,
                        color: AlertCardStyle.officialSectionHeaderColor,
                      ),
                    ],
                  ),
                ),
              ),
            // Deep link into the matching safety guide, if any.
            Consumer(
              builder: (context, ref, child) {
                final categoryId = ref.watch(
                  provider.select((value) => value.hazard?.category?.id),
                );
                return GuideStripCard(categoryId: categoryId);
              },
            ),
            _buildSeeFullAlert(fullText, fullLink),
          ],
        ),
      ),
    ).pB(16.0);
  }

  /// The "See full alert" expander: reveals the agency's complete original text
  /// and links to the source page. Guarantees nothing the source published is
  /// ever hidden by the 3-point cap.
  Widget _buildSeeFullAlert(final String? fullText, final String? fullLink) {
    if (fullText == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 12.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _fullAlertExpanded = !_fullAlertExpanded),
            child: Row(
              children: [
                Icon(
                  _fullAlertExpanded
                      ? LucideIcons.chevronUp
                      : LucideIcons.chevronDown,
                  size: 14.spMin,
                  color: AppColors.blue,
                ),
                SizedBox(width: 4.spMin),
                Text(
                  'See full alert',
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (_fullAlertExpanded) ...[
            8.spMin.hSizedBox,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.spMin),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FA),
                borderRadius: BorderRadius.circular(10.spMin),
                border: Border.all(color: const Color(0xFFE5E5EC)),
              ),
              child: Text(
                fullText,
                style: TextStyle(
                  fontSize: 12.spMin,
                  height: 1.55,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
            if (fullLink != null) ...[
              7.spMin.hSizedBox,
              InkWell(
                onTap: () => openLink(context: context, link: fullLink),
                child: Text(
                  'View source page ↗',
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    color: AppColors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEmptySectionCard({
    required final String label,
    required final String body,
  }) {
    final color = AppColors.orange200;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border(
          left: BorderSide(color: color.withValues(alpha: 0.6), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColorLight,
            blurRadius: 2.0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5.spMin,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          8.hSizedBox,
          Text(
            body,
            style: TextStyle(
              fontSize: 13.5.spMin,
              height: 1.45,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatToDoSection() {
    return Consumer(
      builder: (context, ref, child) {
        final allActions = ref.watch(
          provider.select((value) => value.hazard?.callsToAction),
        );
        final isUserReported = ref.watch(
          provider.select(
            (value) => value.hazard?.isUserReported ?? false,
          ),
        );
        final categoryName = ref.watch(
          provider.select((value) => value.hazard?.category?.name),
        );
        final parentCategoryName = ref.watch(
          provider.select((value) => value.hazard?.category?.parent?.name),
        );
        final title = ref.watch(
          provider.select((value) => value.hazard?.title),
        );
        final description = ref.watch(
          provider.select((value) => value.hazard?.description),
        );
        final sourceLink = ref.watch(
          provider.select(
            (value) => value.hazard?.link ?? value.hazard?.source?.url,
          ),
        );
        final sourceName = ref.watch(
          provider.select((value) => value.hazard?.source?.name),
        );

        final rawActions = allActions ?? const <String>[];
        final directed = !isUserReported && rawActions.isNotEmpty;
        final bucket = AlertGuidanceLibrary.bucketFor(
          categoryName: categoryName,
          parentCategoryName: parentCategoryName,
          title: title,
        );
        final consider = isUserReported
            ? const <String>[]
            : AlertGuidanceLibrary.considerRows(bucket);

        // Community report carries no agency instruction: one standing line
        // that points at the emergency services.
        if (isUserReported) {
          return _buildGuidanceCard(
            label: 'WHAT TO DO',
            color: AlertCardStyle.communitySectionHeaderColor,
            items: <String>[AlertTextUtil.followAgencyLine(null)],
            totalItems: 1,
            expanded: false,
            onToggle: () {},
            showAll: false,
            fullText: description,
            fullLink: sourceLink,
          );
        }

        // No agency directive and no ALRT guidance for this hazard: an honest
        // neutral line (never the old "no further details" dead-end).
        if (!directed && consider.isEmpty) {
          return _buildEmptySectionCard(
            label: 'WHAT TO DO',
            body: AlertTextUtil.followAgencyLine(
              ref.watch(
                provider.select((value) => value.hazard?.source?.name),
              ),
            ),
          );
        }

        // DIRECTED: the agency's own words, ranked Tier 1 first, capped at 3,
        // the rest behind "Show all". CONSIDER: ALRT's general guidance.
        final items = directed
            ? AlertGuidanceLibrary.rankActions(rawActions)
            : consider;
        final isConsider = !directed;
        final agency = (sourceName ?? '').trim();
        final lead = directed
            ? '${agency.isEmpty ? 'The agency' : agency} advises:'
            : "ALRT's general guidance:";
        final visible = _whatToDoExpanded
            ? items
            : items.take(AlertTextUtil.maxPoints).toList();

        return _buildGuidanceCard(
          label: 'WHAT TO DO',
          color: isConsider
              ? const Color(0xFF17603A)
              : AlertCardStyle.officialSectionHeaderColor,
          items: visible,
          totalItems: items.length,
          expanded: _whatToDoExpanded,
          onToggle: () =>
              setState(() => _whatToDoExpanded = !_whatToDoExpanded),
          showAll: items.length > AlertTextUtil.maxPoints,
          pill: isConsider ? 'CONSIDER' : 'DIRECTED',
          pillBg: isConsider
              ? const Color(0xFFE7F6EC)
              : const Color(0xFFFBE9E9),
          pillFg: isConsider
              ? const Color(0xFF17603A)
              : const Color(0xFFA31F26),
          fullText: description,
          fullLink: sourceLink,
          lead: lead,
        );
      },
    );
  }

  /// The agency's own words, under the V3 "WHAT WE KNOW" label.
  Widget _buildOfficialDescriptionSection() {
    return Consumer(
      builder: (context, ref, child) {
        final isUserReported = ref.watch(
          provider.select(
            (value) => value.hazard?.isUserReported ?? false,
          ),
        );
        final description = ref.watch(
          provider.select((value) => value.hazard?.description),
        );
        final reportTitle = ref.watch(
          provider.select((value) => value.hazard?.title),
        );

        // Facts only: the agency's own instructions and road notes have
        // their own sections, so they are cut from here. A community report
        // always gets at least one point, even with nothing written.
        // The section always shows (owner, 15 Oct 2026): an official alert
        // with nothing beyond its headline gets one honest line instead of
        // no section at all.
        final hasHazard = ref.watch(
          provider.select((value) => value.hazard != null),
        );
        if (!hasHazard) return const SizedBox.shrink();
        final sourceName = ref.watch(
          provider.select((value) => value.hazard?.source?.name),
        );
        final allFacts = isUserReported
            ? AlertTextUtil.communityPoints(reportTitle, description)
            : AlertTextUtil.whatWeKnowAllPoints(description);
        final points = allFacts.isEmpty
            ? <String>[AlertTextUtil.noDetailsLine(sourceName)]
            : (_whatWeKnowExpanded
                ? allFacts
                : allFacts.take(AlertTextUtil.maxPoints).toList());
        final showAllFacts =
            !isUserReported && allFacts.length > AlertTextUtil.maxPoints;

        // Paired with WHAT TO DO, to the pixel. This used to be a blue
        // card with a blue bar and a sentence-case heading: blue is the
        // COMMUNITY colour, so an official agency's own words were wearing
        // the unverified-report treatment, and the two halves of the alert
        // read as parts of two different apps.
        final color = AlertCardStyle.officialSectionHeaderColor;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.spMin),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColorLight,
                blurRadius: 2.0,
                offset: Offset(0.0, 0.0),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.spMin),
              border: Border(
                left: BorderSide(color: color, width: 4),
                right: BorderSide(color: color, width: 1),
                bottom: BorderSide(color: color, width: 1),
                top: BorderSide(color: color, width: 1),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16.spMin,
              16.spMin,
              8.spMin,
              16.spMin,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHAT WE KNOW',
                        style: TextStyle(
                          color: color,
                          fontSize: 13.spMin,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      12.spMin.hSizedBox,
                      for (var i = 0; i < points.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i < points.length - 1 ? 8.spMin : 0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\u2022 ',
                                style: TextStyle(
                                  color: AppColors.black.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontSize: 14.spMin,
                                  height: 1.5,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  points[i],
                                  style: TextStyle(
                                    color: AppColors.black.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontSize: 14.spMin,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showAllFacts)
                        InkWell(
                          onTap: () => setState(
                            () => _whatWeKnowExpanded = !_whatWeKnowExpanded,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.spMin),
                            child: Row(
                              children: [
                                Text(
                                  _whatWeKnowExpanded
                                      ? 'Show less'
                                      : 'Show all facts',
                                  style: TextStyle(
                                    fontSize: 12.5.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                                SizedBox(width: 4.spMin),
                                Icon(
                                  _whatWeKnowExpanded
                                      ? LucideIcons.chevronUp
                                      : LucideIcons.chevronDown,
                                  size: 14.spMin,
                                  color: color,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).pB(16.0);
      },
    );
  }
  Widget _buildSourceSection() {
    return Consumer(
      builder: (context, ref, child) {
        final source = ref.watch(
          provider.select((value) => value.hazard?.source),
        );
        final isUserReported = ref.watch(
          provider.select(
            (value) => value.hazard?.isUserReported ?? false,
          ),
        );
        final sourceLink = ref.watch(
          provider.select(
            (value) => value.hazard?.link ?? value.hazard?.source?.url,
          ),
        );
        final copyrightText = ref.watch(
          provider.select(
            (value) => value.hazard?.source?.copyrightText,
          ),
        );
        final advisoryText = ref.watch(
          provider.select(
            (value) => value.hazard?.source?.advisoryText,
          ),
        );

        final license = ref.watch(
          provider.select(
            (value) => value.hazard?.source?.license,
          ),
        );

        final copyrightLink = ref.watch(
          provider.select(
            (value) => value.hazard?.source?.copyrightLink,
          ),
        );

        final color = const Color(0xFF37CAFF);

        final hasDetail =
            !isUserReported &&
            (license != null ||
                (advisoryText?.isNotEmpty ?? false) ||
                (copyrightText?.isNotEmpty ?? false));

        // Attribution is a footnote, not a section: one compact line by
        // default, with the licence and copyright a tap away. All of it is
        // still here, it just no longer dominates the bottom of the alert.
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.spMin),
            border: Border.all(
              color: AppColors.lightGrey.withValues(alpha: 0.7),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12.spMin,
            vertical: 10.spMin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26.spMin,
                    height: 26.spMin,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7.spMin),
                    ),
                    child: Center(
                      child: isUserReported
                          ? Icon(
                              LucideIcons.userRound,
                              size: 15.spMin,
                              color: AppColors.blue,
                            )
                          : SvgPicture.asset(
                              'assets/icons/shield.svg',
                              width: 15.spMin,
                              height: 15.spMin,
                              colorFilter: ColorFilter.mode(
                                AppColors.blue,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ),
                  10.spMin.wSizedBox,
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: source?.name ?? 'Community report',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          TextSpan(
                            text: isUserReported
                                ? '  ·  Community'
                                : '  ·  Official source',
                          ),
                          if (license != null)
                            TextSpan(text: '  ·  ${license.badgeText}'),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.spMin,
                        height: 1.35,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  if (sourceLink != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => openLink(context: context, link: sourceLink),
                      child: Padding(
                        padding: EdgeInsets.all(5.spMin),
                        child: Icon(
                          LucideIcons.externalLink,
                          size: 15.spMin,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  if (hasDetail)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(
                        () => _attributionExpanded = !_attributionExpanded,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.spMin),
                        child: Icon(
                          _attributionExpanded
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          size: 18.spMin,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              if (hasDetail && _attributionExpanded) ...[
                8.spMin.hSizedBox,
                Divider(
                  height: 1,
                  color: AppColors.lightGrey.withValues(alpha: 0.7),
                ),
                8.spMin.hSizedBox,
                if (license != null)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: license.licenseText),
                        if (copyrightLink != null || license.link != null) ...[
                          const TextSpan(text: '  '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () => openLink(
                                context: context,
                                link: copyrightLink ?? license.link!,
                              ),
                              child: Text(
                                'View licence',
                                style: TextStyle(
                                  fontSize: 11.spMin,
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 11.spMin,
                      height: 1.45,
                      color: AppColors.grey,
                    ),
                  ),
                if (advisoryText?.isNotEmpty ?? false) ...[
                  6.spMin.hSizedBox,
                  Text(
                    advisoryText!,
                    style: TextStyle(
                      fontSize: 11.spMin,
                      height: 1.45,
                      color: AppColors.grey,
                    ),
                  ),
                ],
                if (copyrightText?.isNotEmpty ?? false) ...[
                  6.spMin.hSizedBox,
                  Text(
                    copyrightText!,
                    style: TextStyle(
                      fontSize: 11.spMin,
                      height: 1.45,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewFeedbackSectionNew() {
    return Consumer(
      builder: (context, ref, child) {
        final reviewFeedback = ref.watch(
          provider.select((value) => value.hazard?.reviewFeedback),
        );
        final reviewStatus = ref.watch(
          provider.select((value) => value.hazard?.reviewStatus),
        );

        if (reviewFeedback?.isEmpty ?? true) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5.spMin,
          children: [
            Text(
              'Only visible to you',
              style: TextStyle(
                fontSize: 12.spMin,
                color: AppColors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.spMin),
              decoration: BoxDecoration(
                color: reviewStatus == HazardReviewStatus.accepted
                    ? AppColors.green.withValues(alpha: 0.05)
                    : AppColors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.spMin),
                border: Border.all(
                  color: reviewStatus == HazardReviewStatus.accepted
                      ? AppColors.green.withValues(alpha: 0.2)
                      : AppColors.red.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50.spMin,
                    height: 50.spMin,
                    decoration: BoxDecoration(
                      color: reviewStatus == HazardReviewStatus.accepted
                          ? AppColors.green.withValues(alpha: 0.1)
                          : AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25.spMin),
                      border: Border.all(
                        color: reviewStatus == HazardReviewStatus.accepted
                            ? AppColors.green.withValues(alpha: 0.3)
                            : AppColors.red.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      reviewStatus == HazardReviewStatus.accepted
                          ? LucideIcons.messageSquare
                          : LucideIcons.triangleAlert,
                      color: reviewStatus == HazardReviewStatus.accepted
                          ? AppColors.green
                          : AppColors.red,
                      size: 24.spMin,
                    ),
                  ),
                  16.spMin.wSizedBox,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reviewer Feedback',
                          style: TextStyle(
                            fontSize: 14.spMin,
                            fontWeight: FontWeight.w600,
                            color: reviewStatus == HazardReviewStatus.accepted
                                ? AppColors.green
                                : AppColors.red,
                          ),
                        ),
                        4.hSizedBox,
                        Text(
                          reviewFeedback!,
                          style: TextStyle(
                            fontSize: 14.spMin,
                            color: AppColors.black,
                            height: 1.4,
                          ),
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

  void _onInit() {
    ref.read(provider.notifier).updateHazard(widget.args.hazard);
  }

  /// Register video priority providers for all video medias.
  void _registerVideoPriorityProviders() {
    final videoMedias = ref.read(
      provider.select(
        (value) =>
            value.hazard?.processedMedias
                .where((media) => media.type == AlrtMediaType.video)
                .toList() ??
            [],
      ),
    );

    for (final videoMedia in videoMedias) {
      ref.watch(
        providerOfVideoPreviewLifecycle(
          VideoIdPriority(
            id: videoMedia.id,
            priority: VideoPriority.level1,
          ),
        ).select((value) => null),
      );
    }
  }

  /// Listen to the delete hazard state and handle success or error.
  void _listenToTheDeleteHazardState() {
    ref.listen(
      provider.select(
        (value) => value.deleteHazardState,
      ),
      (previous, next) {
        if (previous != next) {
          next.maybeWhen(
            success: context.pop,
            error: _handleError,
            orElse: () {},
          );
        }
      },
    );
  }

  /// Handle error by showing a toast message.
  void _handleError(final AppError error) {
    context.showErrorToast(
      message: error.message,
    );
  }

  /// Handle delete hazard action.
  void _handleDeleteHazard() {
    showConfirmationSheet(
      context: context,
      title: 'Delete Report',
      description:
          'Are you sure you want to delete this report? This action cannot be undone.',
      onPressedConfirmAsync: (context, ref) =>
          ref.read(provider.notifier).deleteHazard(),
    );
  }
}

class ConfidenceDialPainter extends CustomPainter {
  final AIConfidence confidence;
  final Color backgroundColor;
  final Color activeColor;
  final double animatedPercentage;

  ConfidenceDialPainter({
    required this.confidence,
    required this.backgroundColor,
    required this.activeColor,
    this.animatedPercentage = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final strokeWidth = 6.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Active arc
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (animatedPercentage / 100) * 2 * math.pi;
    const startAngle = -math.pi / 2; // Start from top

    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );

      // Add a subtle glow effect
      final glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ConfidenceDialPainter oldDelegate) {
    return oldDelegate.animatedPercentage != animatedPercentage ||
        oldDelegate.confidence != confidence ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
