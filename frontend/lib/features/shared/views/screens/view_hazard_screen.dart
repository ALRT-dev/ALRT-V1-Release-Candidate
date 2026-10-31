import 'package:flutter/material.dart';
import 'package:hazard_app/features/shared/views/widgets/agency_content_sections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/family/views/widgets/family_choose_circle_sheet.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
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
import 'package:hazard_app/features/shared/utils/general_guidance.dart';
import 'package:hazard_app/features/shared/utils/alert_text_util.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/features/shared/views/widgets/category_glyph.dart';
import 'package:hazard_app/features/shared/views/widgets/report_content_sheet.dart';
import 'package:hazard_app/features/shared/views/widgets/small_map_view.dart';
import 'package:hazard_app/features/shared/views/widgets/view_hazard_widgets/hazard_medias_carousel.dart';
import 'package:hazard_app/features/shared/views/widgets/view_hazard_widgets/send_to_group_sheet.dart';
import 'package:share_plus/share_plus.dart';
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

  /// Whether this alert is being read aloud right now. Drives the lit
  /// Listen button, and is cleared when the speech ends on its own.
  bool _isSpeaking = false;


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
              padding: EdgeInsets.fromLTRB(
                20.spMin,
                4.spMin,
                20.spMin,
                20.spMin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMyReport) ...[
                    _buildEditDeleteRow(),
                    16.hSizedBox,
                  ],
                  _buildHeaderCard(),
                  16.hSizedBox,
                  
                  // Updated notification box
                  _buildUpdatedNotificationBox(),
                  
                  // Timeline section
                  _buildTimelineSection(),

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
  
  /// Shows "Updated" notification box when alert has been updated recently
  Widget _buildUpdatedNotificationBox() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();
        
        // Check if updated more than 5 minutes after created
        if (hazard.updatedAt == null || hazard.createdAt == null) {
          return const SizedBox.shrink();
        }
        
        final timeDiff = hazard.updatedAt!.difference(hazard.createdAt!);
        if (timeDiff.inMinutes <= 5) return const SizedBox.shrink();
        
        final updatedTime = hazard.updatedAt!.timeAgo;
        
        return Container(
          margin: EdgeInsets.only(bottom: 16.spMin),
          padding: EdgeInsets.all(14.spMin),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E4), // Light orange wash
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: const Color(0xFFFF6B01).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32.spMin,
                height: 32.spMin,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B01),
                  borderRadius: BorderRadius.circular(8.spMin),
                ),
                child: Icon(
                  LucideIcons.refreshCw,
                  size: 16.spMin,
                  color: Colors.white,
                ),
              ),
              12.wSizedBox,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Updated',
                      style: TextStyle(
                        fontSize: 13.spMin,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF6B01),
                      ),
                    ),
                    2.hSizedBox,
                    Text(
                      'This alert was updated $updatedTime with new information',
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: const Color(0xFF6B4423),
                        height: 1.3,
                      ),
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
  
  /// Shows structured timeline with event/posted/updated/expiry times
  Widget _buildTimelineSection() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();
        
        // Only show if we have meaningful timestamps
        final hasOccurredAt = hazard.occurredAt != null;
        final hasUpdated = hazard.updatedAt != null && 
            hazard.createdAt != null &&
            hazard.updatedAt!.difference(hazard.createdAt!).inMinutes > 5;
        final hasExpiry = hazard.expiresAt != null;
        
        // Skip if we only have createdAt (already shown elsewhere)
        if (!hasOccurredAt && !hasUpdated && !hasExpiry) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: EdgeInsets.only(bottom: 16.spMin),
          padding: EdgeInsets.all(16.spMin),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TIMELINE',
                style: TextStyle(
                  fontSize: 11.spMin,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.mediumGrey,
                ),
              ),
              12.hSizedBox,
              
              // Event time (when the event occurred/will occur)
              if (hasOccurredAt)
                _timelineRow(
                  icon: LucideIcons.zap,
                  label: _eventLabel(hazard.occurredAt!),
                  value: _formatTimestamp(hazard.occurredAt!),
                  color: hazard.color,
                ),
              
              // Posted time
              if (hazard.createdAt != null) ...[
                if (hasOccurredAt) 8.hSizedBox,
                _timelineRow(
                  icon: LucideIcons.send,
                  label: 'Posted',
                  value: _formatTimestamp(hazard.createdAt!),
                  color: AppColors.mediumGrey,
                ),
              ],
              
              // Updated time
              if (hasUpdated) ...[
                8.hSizedBox,
                _timelineRow(
                  icon: LucideIcons.refreshCw,
                  label: 'Updated',
                  value: _formatTimestamp(hazard.updatedAt!),
                  color: const Color(0xFFFF6B01),
                ),
              ],
              
              // Expiry time
              if (hasExpiry) ...[
                8.hSizedBox,
                _timelineRow(
                  icon: LucideIcons.clock,
                  label: 'Expires',
                  value: _formatTimestamp(hazard.expiresAt!),
                  color: AppColors.mediumGrey,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  /// Timeline row with icon, label, and formatted time
  Widget _timelineRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.spMin,
          color: color,
        ),
        8.wSizedBox,
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.spMin,
                  color: AppColors.mediumGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Format timestamp as "Today 2:15 PM" or "Tomorrow 6:00 PM" or "Thu, 2 Nov 3:45 PM"
  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dtDate = DateTime(dt.year, dt.month, dt.day);
    
    final timeStr = '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    
    if (dtDate == today) {
      return 'Today $timeStr';
    } else if (dtDate == tomorrow) {
      return 'Tomorrow $timeStr';
    } else if (dt.isBefore(now) && now.difference(dt).inHours < 24) {
      return dt.timeAgo;
    } else {
      final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dt.weekday - 1];
      final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][dt.month - 1];
      return '$weekday, ${dt.day} $month $timeStr';
    }
  }
  
  /// Event label: "Event" for past, "Active now" for current, "Starts" for future
  String _eventLabel(DateTime occurredAt) {
    final now = DateTime.now();
    if (occurredAt.isBefore(now.subtract(const Duration(hours: 1)))) {
      return 'Event';
    } else if (occurredAt.isAfter(now.add(const Duration(hours: 1)))) {
      return 'Starts';
    } else {
      return 'Active now';
    }
  }

  // ── White content sections ──────────────────────────────────────────────

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
        final isFollowing = ref.watch(providerOfFollowedAlerts).contains(id);

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
                onTap: () => SharePlus.instance.share(
                  ShareParams(
                    text:
                        '${hazard.title ?? "Alert"} \u00b7 ${hazard.severityTitle}\nhttps://safetyalrt.com/a/${hazard.id}',
                  ),
                ),
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
  /// Shows pulsing orange dot when alert has been updated.
  Widget _followPill({
    required final bool isFollowing,
    required final VoidCallback onTap,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        final hasUpdate = hazard != null && _hasUnseenUpdate(hazard);
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
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
            ),
            if (hasUpdate && isFollowing)
              Positioned(
                top: -2.spMin,
                right: -2.spMin,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1.0),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Container(
                        width: 10.spMin,
                        height: 10.spMin,
                        decoration: BoxDecoration(
                          color: _litInk,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    if (mounted) setState(() {});
                  },
                ),
              ),
          ],
        );
      },
    );
  }
  
  /// Check if alert has updates the user hasn't seen yet.
  bool _hasUnseenUpdate(Hazard hazard) {
    // Simple check: if updated time is more than 5 minutes after created time
    if (hazard.updatedAt == null || hazard.createdAt == null) return false;
    final timeDiff = hazard.updatedAt!.difference(hazard.createdAt!);
    return timeDiff.inMinutes > 5;
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
                      _buildOfficialCategoryPill(hazard),
                      10.hSizedBox,
                      _buildPlainTermsBox(),
                    ],
                    12.hSizedBox,
                    Text(
                      _titleOf(hazard),
                      style: TextStyle(
                        // Community board 22, Detail board 21.
                        fontSize: hazard.isUserReported ? 22.spMin : 21.spMin,
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

  Widget _buildOfficialCategoryPill(final Hazard hazard) {
    final category = hazard.category;
    final label = (category?.name ?? category?.parent?.name ?? 'Other').trim();
    final color = category?.resolvedColor ?? AppColors.grey;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.spMin,
        vertical: 6.spMin,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (category == null)
            Icon(
              LucideIcons.tag,
              size: 14.spMin,
              color: color,
            )
          else
            CategoryGlyph(category: category, size: 16.spMin),
          6.wSizedBox,
          Text(
            label,
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
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
    final labelText = Text(
      label,
      style: TextStyle(
        fontSize: 12.spMin,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: labelInk,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return Row(
      children: [
        SourceShapeGlyph(
          isAws: isAws,
          isOfficial: hazard.source != null,
          isGlobalHumanitarian: hazard.isGlobalHumanitarian,
          isAlrtIntel: hazard.isAlrtIntel,
          color: hazard.color,
          // 14 read as a speck next to the source (phone review, 14 Oct).
          size: 20.spMin,
        ),
        8.wSizedBox,
        // The label is a short fixed word ("OFFICIAL", "EMERGENCY WARNING")
        // and is always shown whole; the source line takes the rest. A
        // flex split here gave the label a quarter of the row whatever
        // the source used, cutting "EMERGENCY WARNING" short.
        if (right.isEmpty) Expanded(child: labelText) else labelText,
        if (right.isNotEmpty) ...[
          12.wSizedBox,
          // A long agency name ("Department of Fire and Emergency Services
          // WA · 6 hours ago") ran off the right edge; it now wraps.
          Expanded(
            child: Text(
              right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.spMin,
                color: AlertCardStyle.metaInk,
              ),
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
    final categoryName = (category?.parent?.name ?? category?.name ?? 'Other')
        .toUpperCase();
    final postedAt = hazard.createdAt ?? hazard.occurredAt;
    final categoryColor = category?.resolvedColor ?? AppColors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Community board: the 40 px category disc on its own.
        category == null
            ? Container(
                width: 40.spMin,
                height: 40.spMin,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.users,
                  size: 20.spMin,
                  color: categoryColor,
                ),
              )
            : CategoryGlyph(category: category, size: 40.spMin),
        10.wSizedBox,
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
                    ? 'Community report'
                    : 'Community report · ${postedAt.timeAgo}',
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
          title: hazard.title,
          hasAdvice: AlertCardStyle.hasAgencyAdvice(hazard.callsToAction),
        );
        if (plainTerms == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // The plain-terms surface is always the dark band (locked).
            color: AlertCardStyle.plainTermsBackground,
            borderRadius: BorderRadius.circular(12.spMin),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12.spMin,
            vertical: 10.spMin,
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
              fontSize: 14.spMin,
              height: 1.5,
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
            : '${AlertCardStyle.distanceLabel(distance)} from you';

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
    context.go(
      HomeScreen.route,
      extra: HomeScreenArgs(initialTab: HomeTab.map),
    );
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
        Consumer(
          builder: (context, ref, child) {
            final hazard = ref.watch(provider.select((value) => value.hazard));
            if (hazard?.isUserReported ?? false) {
              return _buildCommunityDescriptionSection();
            }
            if (hazard?.contentDetails != null) {
              return AgencyContentSections(
                content: hazard!.contentDetails!,
                sourceName: hazard.source?.name,
                officialIntro: AlertTextUtil.issuedLine(
                  hazard.source?.name,
                  hazard.category?.name ?? hazard.title,
                  hazard.locationName,
                ),
                severityColor: hazard.color,
              );
            }
            return Column(
              children: [
                _buildOfficialDescriptionSection(),
                _buildWhatToDoSection(),
              ],
            );
          },
        ),

        Consumer(
          builder: (context, ref, child) {
            final categoryId = ref.watch(
              provider.select((value) => value.hazard?.category?.id),
            );
            final isUserReported = ref.watch(
              provider.select((value) => value.hazard?.isUserReported ?? false),
            );
            if (isUserReported) return const SizedBox.shrink();
            return GuideStripCard(categoryId: categoryId);
          },
        ),

        _buildFollowingAlertReason(),

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
              publishedRows: ref.watch(
                provider.select(
                  (value) => value.hazard?.publishedProfileGuidance,
                ),
              ),
              categoryName: categoryName,
              parentCategoryName: parentCategoryName,
              title: title,
              isAws: isAws,
            );
          },
        ),

        // Tell your people: purple card + Everyone else card.
        _buildTellYourPeopleSection(),

        // Community alerts: I see it / I don't see it voting, the
        // unverified note, then Follow / Listen / Report.
        _buildCommunityVoteSection(),
        12.hSizedBox,

        // Attribution
        _buildSourceSection(),
        _buildSourceFootnote(),
        
        // Data Attribution Footer (new)
        _buildDataAttributionFooter(),
        
        40.hSizedBox,
      ],
    );
  }

  // ── Tell your people ───────────────────────────────────────────────────

  /// Speaks the alert aloud. Tapping Listen again stops it.
  Future<void> _speakAlert(final WidgetRef ref, final Hazard hazard) async {
    final speech = ref.read(providerOfAlertSpeech);
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
      title: hazard.title,
      hasAdvice: AlertCardStyle.hasAgencyAdvice(hazard.callsToAction),
    );
    final text = [
      hazard.isUserReported
          ? 'Community report, unverified.'
          : 'Official alert from ${hazard.source?.name ?? 'an official source'}.',
      hazard.title ?? '',
      if (plainTerms != null) 'In plain terms: $plainTerms',
      hazard.description ?? '',
    ].where((line) => line.trim().isNotEmpty).join(' ');
    setState(() => _isSpeaking = true);
    await speech.speak(text);
    if (mounted) setState(() => _isSpeaking = false);
  }

  static const _tellPurple = Color(0xFF4A1D8C);

  Future<void> _sendAlertToCircle(
    final Hazard hazard,
    final FamilyCircleSummary circle,
  ) async {
    final sent = await showSendToGroupSheet(
      context: context,
      hazard: hazard,
      circleId: circle.circleId,
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

  Widget _buildTellYourPeopleSection() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((v) => v.hazard));
        if (hazard == null) return const SizedBox.shrink();
        final circles = ref.watch(providerOfFamily.select((s) => s.circles));
        final activeCircleId = ref.watch(
          providerOfFamily.select((s) => s.circle?.id),
        );
        if (circles.isEmpty) return const SizedBox.shrink();
        final selected = circles.firstWhere(
          (c) => c.circleId == activeCircleId,
          orElse: () => circles.first,
        );
        return Padding(
          padding: EdgeInsets.only(top: 24.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.spMin),
                child: Text(
                  'TELL YOUR PEOPLE',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFF5B5E6E),
                  ),
                ),
              ),
              _buildYourCircleCard(hazard, circles.length, selected),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYourCircleCard(
    final Hazard hazard,
    final int circleCount,
    final FamilyCircleSummary selected,
  ) {
    return Container(
      padding: EdgeInsets.all(14.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.spMin),
        border: Border.all(color: const Color(0xFFE6E7EE)),
        boxShadow: const [AlertCardStyle.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell your people',
                      style: TextStyle(
                        fontSize: 15.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    2.hSizedBox,
                    Text(
                      'Choose your group, then send or share this alert',
                      style: TextStyle(
                        fontSize: 11.5.spMin,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => showChooseCircleSheet(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.spMin,
                    vertical: 6.spMin,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  circleCount > 1 ? 'Change group' : 'Choose group',
                  style: TextStyle(
                    fontSize: 12.5.spMin,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          10.hSizedBox,
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.spMin,
              vertical: 10.spMin,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7FA),
              borderRadius: BorderRadius.circular(14.spMin),
              border: Border.all(
                color: const Color(0xFFE6E7EE),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.spMin,
                  height: 32.spMin,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEDEAF6),
                  ),
                  child: Center(
                    child: Text(
                      selected.name.isNotEmpty
                          ? selected.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 13.spMin,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
                10.wSizedBox,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.spMin,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4A1D8C),
                        ),
                      ),
                      2.hSizedBox,
                      Text(
                        '${selected.memberCount} ${selected.memberCount == 1 ? 'person' : 'people'}',
                        style: TextStyle(
                          fontSize: 12.spMin,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          10.hSizedBox,
          _tellActionButton(
            label: 'Send to ${selected.name}',
            icon: LucideIcons.send,
            isPrimary: true,
            onTap: () => _sendAlertToCircle(hazard, selected),
          ),
          8.hSizedBox,
          _tellSecondaryShareButton(hazard),
          8.hSizedBox,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.info, size: 13.spMin, color: AppColors.mediumGrey),
              6.wSizedBox,
              Expanded(
                child: Text(
                  'Send to group opens the group sheet where you can add an optional message before sending.',
                  style: TextStyle(
                    fontSize: 12.spMin,
                    height: 1.35,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tellActionButton({
    required final String label,
    required final IconData icon,
    required final bool isPrimary,
    final VoidCallback? onTap,
  }) {
    return Opacity(
      opacity: onTap != null ? 1.0 : 0.55,
      child: Material(
        color: isPrimary
            ? AppColors.white
            : AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12.spMin),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 58.spMin,
            padding: EdgeInsets.symmetric(horizontal: 12.spMin),
            decoration: isPrimary
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(12.spMin),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.45),
                      width: 1.25,
                    ),
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18.spMin,
                  color: isPrimary ? _tellPurple : AppColors.white,
                ),
                8.wSizedBox,
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.spMin,
                      fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                      color: isPrimary ? _tellPurple : AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tellSecondaryShareButton(final Hazard hazard) {
    return Material(
      color: const Color(0xFFFFF7F1),
      borderRadius: BorderRadius.circular(12.spMin),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => SharePlus.instance.share(
          ShareParams(
            text:
                '${hazard.title ?? "Alert"} · ${hazard.severityTitle}\nhttps://safetyalrt.com/a/${hazard.id}',
          ),
        ),
        child: Container(
          height: 52.spMin,
          padding: EdgeInsets.symmetric(horizontal: 12.spMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.spMin),
            border: Border.all(color: const Color(0xFFF1D9C8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.share2,
                size: 18.spMin,
                color: const Color(0xFFE0561A),
              ),
              8.wSizedBox,
              Text(
                'Share outside ALRT',
                style: TextStyle(
                  fontSize: 13.spMin,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE0561A),
                ),
              ),
            ],
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
        final isFollowing = ref.watch(providerOfFollowedAlerts).contains(id);

        return Padding(
          padding: EdgeInsets.only(top: 16.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // One wording everywhere: the same label, helper, buttons
              // and count line as the feed card. The vote handler is the
              // same call the inline buttons made before.
              // Community board: "Can you see it?" sits in its own white
              // card.
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.spMin),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    AlertCardStyle.cardRadius.spMin,
                  ),
                  boxShadow: const [AlertCardStyle.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ConfirmationPrompt(),
                    12.hSizedBox,
                    ConfirmationButtons(
                      key: ValueKey('vote-$id'),
                      initialVoteType: voteType,
                      initialVoteCount: voteCount,
                      onVotePressed: (type) => ref
                          .read(itemProvider.notifier)
                          .voteHazard(voteType: type),
                    ),
                  ],
                ),
              ),
              12.hSizedBox,
              // Community reports are never authority. Said once, plainly.
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.spMin,
                  vertical: 14.spMin,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEEA),
                  borderRadius: BorderRadius.circular(16.spMin),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 18.spMin,
                      color: AppColors.mediumGrey,
                    ),
                    12.wSizedBox,
                    Expanded(
                      child: Text(
                        'Community reports are not verified by authorities '
                        'and can be wrong. Always follow official advice. '
                        'This report disappears when its time runs out.',
                        style: TextStyle(
                          fontSize: 13.spMin,
                          height: 1.5,
                          color: const Color(0xFF3A3A42),
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
    // Community board: 48 high, radius 14, a hairline warm-grey border.
    final ink = highlighted ? _litInk : AppColors.ink;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.spMin),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48.spMin,
          decoration: BoxDecoration(
            color: highlighted ? _litWash : AppColors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: highlighted ? _litInk : const Color(0xFFD9D6D0),
              width: highlighted ? 2.0 : 1.0,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16.spMin, color: ink),
                8.wSizedBox,
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.spMin,
                      fontWeight: FontWeight.w600,
                      color: ink,
                    ),
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
  static final RegExp _attributedActionPattern = RegExp(
    r'^(.{1,60}? advises:)\s*(.*)$',
  );

  /// Bolds the "{Agency} advises:" prefix of a What To Do line so an
  /// attributed source directive reads visibly differently from ALRT's own
  /// wording around it - the classification standard's "attribution
  /// prefixes bold" rule. Falls back to plain text for a line that isn't in
  /// that shape (community reports carry no instructions at all, and older
  /// content may not follow the pattern).
  Widget _attributedActionText(final String action) {
    final match = _attributedActionPattern.firstMatch(action);
    final baseStyle = TextStyle(
      color: AppColors.black.withValues(alpha: 0.9),
      fontSize: 14.spMin,
      height: 1.5,
    );
    if (match == null) {
      return Text(action, style: baseStyle);
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: match.group(1),
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' ${match.group(2)}'),
        ],
      ),
      style: baseStyle,
    );
  }

  Widget _buildWhatToDoSection() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        final isUserReported = hazard?.isUserReported ?? false;
        // Community reports have no advice section at all.
        if (hazard == null || isUserReported) return const SizedBox.shrink();

        var callsToAction = AlertCardStyle.agencyActions(hazard.callsToAction);
        final fromAgency = callsToAction.isNotEmpty;
        if (!fromAgency) {
          // The agency published no instructions: ALRT's general guidance
          // for this kind of alert, labelled as such below (product owner,
          // 16 Oct 2026; replaces the "has not published advice" note).
          callsToAction = GeneralGuidance.forAlert(
            title: hazard.title,
            categoryName: hazard.category?.name,
            parentCategoryName: hazard.category?.parent?.name,
          );
        }
        final agency = hazard.source?.name?.trim();

        // Detail board: WHAT TO DO in a white card, "{agency}, word for
        // word" under the label when the lines are the agency's own, and
        // a band-coloured dot on each line.
        return _detailSectionCard(
          children: [
            _detailSectionLabel('WHAT TO DO'),
            if (fromAgency && agency != null && agency.isNotEmpty) ...[
              2.hSizedBox,
              Text(
                '$agency, word for word',
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: AlertCardStyle.metaInk,
                ),
              ),
            ],
            8.hSizedBox,
            for (var i = 0; i < callsToAction.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < callsToAction.length - 1 ? 6.spMin : 0,
                ),
                child: _bulletRow(
                  dot: hazard.color,
                  child: _attributedActionText(callsToAction[i]),
                ),
              ),
            // ALRT's own lines carry no prefix, so the block says whose
            // words they are (product owner, 16 Oct 2026).
            if (AlertCardStyle.hasAlrtGuidance(callsToAction))
              Padding(
                padding: EdgeInsets.only(top: 10.spMin),
                child: Text(
                  'General guidance from ALRT, not part of the '
                  'official warning.',
                  style: TextStyle(
                    fontSize: 11.5.spMin,
                    color: AlertCardStyle.metaInk,
                    height: 1.35,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFollowingAlertReason() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        final id = hazard?.id;
        if (hazard == null || id == null || hazard.isUserReported) {
          return const SizedBox.shrink();
        }
        final isFollowing = ref.watch(providerOfFollowedAlerts).contains(id);
        if (!isFollowing) return const SizedBox.shrink();

        return _detailSectionCard(
          children: [
            _detailSectionLabel('FOLLOWING THIS ALERT'),
            8.hSizedBox,
            Text(
              'You\'ll get updates for this alert on this device while it stays followed.',
              style: TextStyle(
                color: _factInk,
                fontSize: 14.spMin,
                height: 1.5,
              ),
            ),
          ],
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
        if (isUserReported) return const SizedBox.shrink();

        final description = ref.watch(
          provider.select((value) => value.hazard?.description),
        );
        final sourceName = ref.watch(
          provider.select((value) => value.hazard?.source?.name),
        );
        final locationName = ref.watch(
          provider.select((value) => value.hazard?.locationName),
        );
        final incidentType = ref.watch(
          provider.select(
            (value) => value.hazard?.category?.name ?? value.hazard?.title,
          ),
        );
        final rawFacts = AlertTextUtil.whatWeKnowPoints(description);
        final issuedLine = AlertTextUtil.issuedLine(
          sourceName,
          incidentType,
          locationName,
        );
        final facts = [
          issuedLine,
          ...rawFacts.where((line) => line.trim() != issuedLine),
        ];

        if (facts.isEmpty) return const SizedBox.shrink();

        // Detail board: a white card, the orange V3 label, grey dots.
        return _detailSectionCard(
          children: [
            _detailSectionLabel('WHAT WE KNOW'),
            8.hSizedBox,
            for (var i = 0; i < facts.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < facts.length - 1 ? 6.spMin : 0,
                ),
                child: _bulletRow(
                  dot: _factDot,
                  child: Text(
                    facts[i],
                    style: TextStyle(
                      color: _factInk,
                      fontSize: 14.spMin,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCommunityDescriptionSection() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null || !hazard.isUserReported) {
          return const SizedBox.shrink();
        }

        final facts = AlertTextUtil.communityPoints(
          hazard.title,
          hazard.description,
        );

        return _detailSectionCard(
          children: [
            _detailSectionLabel('WHAT WE KNOW'),
            8.hSizedBox,
            for (var i = 0; i < facts.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < facts.length - 1 ? 6.spMin : 0,
                ),
                child: _bulletRow(
                  dot: _factDot,
                  child: Text(
                    facts[i],
                    style: TextStyle(
                      color: _factInk,
                      fontSize: 14.spMin,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static const _factDot = Color(0xFF9A9AA2);
  static const _factInk = Color(0xFF3A3A42);

  /// The white section card on the Detail board (radius 18, 14 x 16).
  Widget _detailSectionCard({required final List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.spMin),
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AlertCardStyle.cardRadius.spMin),
        boxShadow: const [AlertCardStyle.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// 12 px, bold, letter-spaced, V3 orange.
  Widget _detailSectionLabel(final String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.spMin,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: AppColors.sectionLabel,
      ),
    );
  }

  /// A 6 px dot and the line beside it.
  Widget _bulletRow({required final Color dot, required final Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6.spMin,
          height: 6.spMin,
          margin: EdgeInsets.only(top: 8.spMin),
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        8.wSizedBox,
        Expanded(child: child),
      ],
    );
  }

  /// The board's closing line under an official alert: what ALRT adds and
  /// that it never contacts emergency services.
  Widget _buildSourceFootnote() {
    return Consumer(
      builder: (context, ref, child) {
        final isUserReported = ref.watch(
          provider.select((value) => value.hazard?.isUserReported ?? false),
        );
        return Padding(
          padding: EdgeInsets.fromLTRB(4.spMin, 10.spMin, 4.spMin, 0),
          child: Text(
            isUserReported
                ? 'ALRT never contacts emergency services for you.'
                : 'ALRT adds the plain-terms line, which is not official '
                      'advice. ALRT never contacts emergency services for you.',
            style: TextStyle(
              fontSize: 11.spMin,
              height: 1.5,
              color: AlertCardStyle.metaInk,
            ),
          ),
        );
      },
    );
  }
  
  /// Data attribution footer with source, timestamps, and disclaimer
  Widget _buildDataAttributionFooter() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();
        
        final source = hazard.source;
        final hasUpdate = hazard.updatedAt != null && 
            hazard.createdAt != null &&
            hazard.updatedAt!.difference(hazard.createdAt!).inMinutes > 5;
        
        return Container(
          margin: EdgeInsets.only(top: 16.spMin),
          padding: EdgeInsets.all(14.spMin),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withValues(alpha: 0.3),
            border: Border(
              top: BorderSide(color: AppColors.lightGrey),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _attributionRow(
                'Source',
                source?.name ?? 'Unknown',
              ),
              4.hSizedBox,
              _attributionRow(
                'Posted',
                hazard.createdAt?.timeAgo ?? 'Unknown',
              ),
              if (hasUpdate) ...[
                4.hSizedBox,
                _attributionRow(
                  'Updated',
                  hazard.updatedAt!.timeAgo,
                ),
              ],
              4.hSizedBox,
              Row(
                children: [
                  Text(
                    'Data: ',
                    style: TextStyle(
                      fontSize: 11.spMin,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                  if (source?.url != null)
                    GestureDetector(
                      onTap: () => openLink(
                        context: context,
                        link: source.url!,
                      ),
                      child: Text(
                        source!.name ?? 'Source',
                        style: TextStyle(
                          fontSize: 11.spMin,
                          color: const Color(0xFF5B4FC9),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  else
                    Text(
                      source?.name ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 11.spMin,
                        color: AppColors.grey,
                      ),
                    ),
                  Text(
                    ' · Refreshed every 5 min',
                    style: TextStyle(
                      fontSize: 11.spMin,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              8.hSizedBox,
              Text(
                'The plain-language summary is generated by ALRT and is not '
                'official ${source?.name ?? 'agency'} advice. Always follow '
                'agency instructions.',
                style: TextStyle(
                  fontSize: 11.spMin,
                  fontStyle: FontStyle.italic,
                  color: AppColors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _attributionRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11.spMin,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.spMin,
              color: AppColors.grey,
            ),
          ),
        ),
      ],
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
