import 'package:flutter/material.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_choose_screen.dart';
import 'package:hazard_app/features/shared/views/widgets/agency_content_sections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/family/views/widgets/family_choose_circle_sheet.dart';
import 'package:hazard_app/features/family/repositories/family_repository.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/views/widgets/access_refusal_sheet.dart';
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
import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/utils/alert_guidance_library.dart';
import 'package:hazard_app/features/shared/enums/video_priority_types.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/states/view_hazard_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/date_time_extension.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/features/shared/extensions/widget_extension.dart';
import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/profile/views/widgets/for_you_card.dart';
import 'package:hazard_app/features/profile/views/widgets/share_alrt_sheet.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/providers/followed_alerts_provider.dart';
import 'package:hazard_app/features/shared/models/video_id_priority_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/providers/video_preview_lifecycle_provider.dart';
import 'package:hazard_app/features/shared/providers/view_hazard_provider.dart';
import 'package:hazard_app/features/shared/utils/dialogs.dart';
import 'package:hazard_app/features/shared/utils/open_link.dart';
import 'package:hazard_app/features/shared/utils/share_alert.dart';
import 'package:hazard_app/features/shared/utils/alert_text_util.dart';
import 'package:hazard_app/features/shared/views/widgets/alert_card_style.dart';
import 'package:hazard_app/features/shared/views/widgets/category_glyph.dart';
import 'package:hazard_app/features/shared/views/widgets/report_content_sheet.dart';
import 'package:hazard_app/features/shared/views/widgets/small_map_view.dart';
import 'package:hazard_app/features/shared/views/widgets/view_hazard_widgets/hazard_medias_carousel.dart';
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
  bool _sendingToGroup = false;
  late final AlertSpeechService _speech;

  /// The lit state of Follow and Listen: the brand orange.
  static const _litInk = Color(0xFFFF6B01);
  static const _litWash = Color(0xFFFFF0E4);

  /// Following: a green outline (owner review, 17 November 2026).
  static const _followingLine = Color(0xFF1E9E5A);
  static const _followingInk = Color(0xFF17643B);
  static const _followingWash = Color(0xFFE9F7EF);

  @override
  void initState() {
    super.initState();
    _speech = ref.read(providerOfAlertSpeech);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onInit());
  }

  @override
  void dispose() {
    // Leaving the alert stops it being read. Speech that follows you out
    // of the screen it belongs to is the kind of thing people turn the
    // whole feature off over. Unconditional: _isSpeaking can be stale if
    // the flag reset raced the engine, and stop() on silence is a no-op.
    _speech.stop();
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
                  _buildUpdatedNotificationBox(),

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

  /// Updates (owner design, 24 November 2026), straight under the alert's
  /// heading. Not following: "Get every update as it happens." and Follow
  /// this alert. Following: the green Following chip and the alert's own
  /// timeline: posted, each agency update (the newest marked NEW, with what
  /// changed one tap away), and when it expires unless updated. A database
  /// refresh is never shown as an update: only source updates are listed.
  Widget _buildUpdatedNotificationBox() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        final id = hazard?.id;
        if (hazard == null || id == null) return const SizedBox.shrink();
        final isFollowing = ref.watch(providerOfFollowedAlerts).contains(id);
        void toggle() =>
            ref.read(providerOfFollowedAlerts.notifier).toggle(id);
        final agency = hazard.displaySourceName;

        if (!isFollowing) {
          return _detailSectionCard(
            children: [
              _detailSectionLabel('UPDATES'),
              8.hSizedBox,
              Text(
                'Get every update as it happens.',
                style: TextStyle(
                  fontSize: 18.spMin,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppColors.ink,
                ),
              ),
              6.hSizedBox,
              Text(
                hazard.isUserReported
                    ? "Follow and we'll notify you when this report changes, and show each update here."
                    : "Follow and we'll notify you when $agency changes this alert, and show each update here.",
                style: TextStyle(
                  fontSize: 13.5.spMin,
                  height: 1.45,
                  color: AppColors.mediumGrey,
                ),
              ),
              14.hSizedBox,
              _gradientPillButton(
                icon: LucideIcons.bell,
                label: 'Follow this alert',
                onTap: toggle,
              ),
            ],
          );
        }

        final now = DateTime.now();
        final posted = (hazard.createdAt ?? hazard.occurredAt)?.toLocal();
        final isToday = posted != null && _sameDay(posted, now);
        // Newest first in the model; the timeline reads oldest to newest.
        final updates = hazard.sourceUpdates.reversed.toList();
        final expires = hazard.expiresAt?.toLocal();
        final showExpiry = expires != null && expires.isAfter(now);
        return _detailSectionCard(
          children: [
            Row(
              children: [
                Expanded(
                  child: _detailSectionLabel(
                    isToday ? 'UPDATES · TODAY' : 'UPDATES',
                  ),
                ),
                _followPill(isFollowing: true, onTap: toggle),
              ],
            ),
            12.hSizedBox,
            if (posted != null)
              _updateRow(
                dot: _UpdateDot.past,
                title: hazard.isUserReported
                    ? 'Posted to ALRT'
                    : 'Posted by $agency',
                time: _clock(posted),
                last: updates.isEmpty && !showExpiry,
              ),
            for (var i = 0; i < updates.length; i++)
              _updateRow(
                dot: i == updates.length - 1
                    ? _UpdateDot.latest
                    : _UpdateDot.past,
                title: 'Updated with new information',
                time: _clock(updates[i].at.toLocal()),
                isNew: i == updates.length - 1 &&
                    now.difference(updates[i].at).inHours < 24,
                detail: updates[i].summary,
                detailKey: '${updates[i].at.toIso8601String()}-$i',
                last: i == updates.length - 1 && !showExpiry,
              ),
            if (showExpiry)
              _updateRow(
                dot: _UpdateDot.future,
                title: 'Expires, unless updated',
                time: _clock(expires),
                last: true,
              ),
          ],
        );
      },
    );
  }

  /// Which "See what changed" lines are open in the Updates timeline.
  final Set<String> _openUpdates = <String>{};

  static bool _sameDay(final DateTime a, final DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// "12:45 am" today, "17 Nov, 12:45 am" on another day.
  String _clock(final DateTime t) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final time =
        '$hour:${t.minute.toString().padLeft(2, '0')} ${t.hour < 12 ? 'am' : 'pm'}';
    return _sameDay(t, DateTime.now())
        ? time
        : '${t.day} ${months[t.month - 1]}, $time';
  }

  /// One line of the Updates timeline: a dot on a thin line, the event,
  /// its time on the right; the newest update carries NEW and its change
  /// summary one tap away.
  Widget _updateRow({
    required final _UpdateDot dot,
    required final String title,
    required final String time,
    final bool isNew = false,
    final String? detail,
    final String? detailKey,
    final bool last = false,
  }) {
    const grey = Color(0xFFB8BCC6);
    final open = detailKey != null && _openUpdates.contains(detailKey);
    final dotWidget = switch (dot) {
      _UpdateDot.latest => Container(
        width: 12.spMin,
        height: 12.spMin,
        decoration: const BoxDecoration(
          color: AppColors.orange300,
          shape: BoxShape.circle,
        ),
      ),
      _UpdateDot.past => Container(
        width: 8.spMin,
        height: 8.spMin,
        decoration: const BoxDecoration(color: grey, shape: BoxShape.circle),
      ),
      _UpdateDot.future => Container(
        width: 8.spMin,
        height: 8.spMin,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: grey, width: 1.5),
        ),
      ),
    };
    final hasDetail =
        detail != null && detail.trim().isNotEmpty && detailKey != null;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20.spMin,
            child: Column(
              children: [
                4.hSizedBox,
                SizedBox(height: 12.spMin, child: Center(child: dotWidget)),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFE3E5EA),
                    ),
                  ),
              ],
            ),
          ),
          10.wSizedBox,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 12.spMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.spMin,
                            height: 1.35,
                            fontWeight: dot == _UpdateDot.latest
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      8.wSizedBox,
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12.5.spMin,
                          height: 1.5,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                  if (isNew)
                    Padding(
                      padding: EdgeInsets.only(top: 4.spMin),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.spMin,
                          vertical: 1.spMin,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orange300,
                          borderRadius: BorderRadius.circular(4.spMin),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 10.spMin,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  if (hasDetail) ...[
                    Semantics(
                      button: true,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          if (open) {
                            _openUpdates.remove(detailKey);
                          } else {
                            _openUpdates.add(detailKey);
                          }
                        }),
                        child: Padding(
                          padding: EdgeInsets.only(top: 4.spMin),
                          child: Text(
                            open ? 'Hide what changed' : 'See what changed',
                            style: TextStyle(
                              fontSize: 12.5.spMin,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC2410C),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (open)
                      Padding(
                        padding: EdgeInsets.only(top: 4.spMin),
                        child: Text(
                          detail,
                          style: TextStyle(
                            fontSize: 13.spMin,
                            height: 1.45,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The orange gradient pill (the locked header gradient), full width.
  Widget _gradientPillButton({
    required final IconData icon,
    required final String label,
    required final VoidCallback onTap,
  }) {
    final radius = BorderRadius.circular(999);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.orange300, AppColors.red200],
          ),
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33FF6B00),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 48.spMin,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 17.spMin, color: AppColors.white),
                  8.wSizedBox,
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows structured timeline with event/posted/updated/expiry times
  Widget _buildTimelineSection() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        if (hazard == null) return const SizedBox.shrink();
        // Part of the alert's updates: shown once the person follows it
        // (owner review, 17 November 2026).
        if (!ref.watch(providerOfFollowedAlerts).contains(hazard.id)) {
          return const SizedBox.shrink();
        }
        return Card(
          elevation: 0,
          child: ExpansionTile(
            title: const Text('Source & time details'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              if (hazard.occurredAt != null)
                _timelineRow(
                  icon: LucideIcons.clock,
                  label: hazard.source?.id == 'waDfes'
                      ? 'Agency reported'
                      : _eventLabel(hazard.occurredAt!),
                  value: _formatTimestamp(hazard.occurredAt!),
                  color: AppColors.mediumGrey,
                ),
              if (hazard.createdAt != null)
                _timelineRow(
                  icon: LucideIcons.send,
                  label: 'Posted',
                  value: _formatTimestamp(hazard.createdAt!),
                  color: AppColors.mediumGrey,
                ),
              if (hazard.updatedAt != null)
                _timelineRow(
                  icon: LucideIcons.refreshCw,
                  label: 'Record refreshed',
                  value: _formatTimestamp(hazard.updatedAt!),
                  color: AppColors.mediumGrey,
                ),
              if (hazard.expiresAt != null)
                _timelineRow(
                  icon: LucideIcons.clock,
                  label: 'Listing until',
                  value: _formatTimestamp(hazard.expiresAt!),
                  color: AppColors.mediumGrey,
                ),
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

    final timeStr =
        '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';

    if (dtDate == today) {
      return 'Today $timeStr';
    } else if (dtDate == tomorrow) {
      return 'Tomorrow $timeStr';
    } else if (dt.isBefore(now) && now.difference(dt).inHours < 24) {
      return dt.timeAgo;
    } else {
      final weekday = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ][dt.weekday - 1];
      final month = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][dt.month - 1];
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
        if (hazard == null || hazard.id == null) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            _roundControl(
              icon: LucideIcons.chevronLeft,
              semanticLabel: 'Back',
              onTap: () => context.pop(),
            ),
            const Spacer(),
            // Follow lives in What to do (owner review, 17 November 2026);
            // the top bar keeps back, share and listen.
            if (isAlertShareable(hazard)) ...[
              _roundControl(
                icon: LucideIcons.share2,
                semanticLabel: 'Share',
                onTap: () =>
                    shareAlert(ref: ref, hazard: hazard, from: 'detail'),
              ),
              8.wSizedBox,
            ],
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

  /// The Follow pill on the right of WHAT TO DO (owner review, 17
  /// November 2026): a small rounded-corner pill, bell plus "Follow";
  /// once followed it turns a green outline with a tick and "Following".
  /// Tapping again unfollows. A dot shows when a followed alert has a
  /// source update.
  Widget _followPill({
    required final bool isFollowing,
    required final VoidCallback onTap,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((value) => value.hazard));
        final hasUpdate = hazard != null && _hasSourceUpdate(hazard);
        final ink = isFollowing ? _followingInk : AppColors.ink;
        final radius = BorderRadius.circular(8.spMin);

        return Semantics(
          button: true,
          toggled: isFollowing,
          label: isFollowing ? 'Following. Tap to unfollow' : 'Follow this alert',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 32.spMin,
                decoration: BoxDecoration(
                  color: isFollowing ? _followingWash : AppColors.white,
                  borderRadius: radius,
                  border: Border.all(
                    color: isFollowing ? _followingLine : AppColors.ink,
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: AppColors.transparent,
                  borderRadius: radius,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.spMin),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFollowing ? LucideIcons.check : LucideIcons.bell,
                            size: 14.spMin,
                            color: ink,
                          ),
                          6.wSizedBox,
                          Text(
                            isFollowing ? 'Following' : 'Follow',
                            style: TextStyle(
                              fontSize: 13.spMin,
                              fontWeight: FontWeight.w700,
                              color: ink,
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
                  top: -3.spMin,
                  right: -3.spMin,
                  child: Container(
                    width: 9.spMin,
                    height: 9.spMin,
                    decoration: BoxDecoration(
                      color: _litInk,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Check if alert has updates the user hasn't seen yet.
  bool _hasSourceUpdate(Hazard hazard) => hazard.latestSourceUpdate != null;

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
              if (!hazard.isUserReported &&
                  hazard.contentDetails?['extractionMethod'] !=
                      'dfes-incident-fields')
                Container(
                  width: double.infinity,
                  height: AlertCardStyle.detailBandStripHeight.spMin,
                  color: hazard.isGdacs
                      ? AlertCardStyle.gdacsShapeColor(
                          hazard.nativeWarningLevel,
                        )
                      : hazard.color,
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
                    // The agency's action words under the heading (owner,
                    // 17 November 2026): "Storm Advice" then "Threat is
                    // reduced" or "Monitor conditions". Agency words only.
                    if (hazard.awsActionStatement case final action?) ...[
                      4.hSizedBox,
                      Text(
                        action,
                        style: TextStyle(
                          fontSize: 16.spMin,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          // Dark text: the Advice yellow is unreadable as
                          // text on white.
                          color: const Color(0xFF3A3A44),
                        ),
                      ),
                    ],
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
    final label = hazard.displayMainCategoryName;
    final category = hazard.category?.copyWith(name: label);
    final color = category?.resolvedColor ?? AppColors.grey;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.spMin,
        vertical: 6.spMin,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        // Less rounded than a pill (owner review, 17 November 2026).
        borderRadius: BorderRadius.circular(8.spMin),
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
  /// none, its category. An Australian Warning System alert shows only what
  /// it is and its level, such as "Storm Advice" (owner, 17 November 2026).
  String _titleOf(final Hazard hazard) => hazard.detailHeading;

  /// Official and AWS: shape glyph, the label (only the Australian Warning
  /// System writes a level word), and "source · ago" on the right.
  Widget _officialSourceRow(final Hazard hazard) {
    final isAws = hazard.isAwsCompliant ?? false;
    final severityTitle = hazard.severityTitle;
    final hasAwsLevel =
        isAws && severityTitle.isNotEmpty && severityTitle != 'Unknown';

    // Owner review, 13 November 2026: a level is written only when the
    // source designates one (an AWS level, the source's own level, a GDACS
    // level, or the WAQI air quality rating). It then sits on a solid pill
    // in the level colour. Anything else writes no level word: the band
    // colour on the card and map shape carries it, and the label is the
    // plain "OFFICIAL" it always was.
    String label;
    Color? pillColor;
    if (hazard.isAlrtIntel) {
      label = 'ALRT ASSESSMENT';
    } else if (hazard.isGlobalHumanitarian) {
      final level = hazard.nativeWarningLevel?.trim();
      if (level == null || level.isEmpty) {
        label = 'GDACS';
      } else {
        label = level.toUpperCase().startsWith('GDACS')
            ? level.toUpperCase()
            : 'GDACS ${level.toUpperCase()}';
        pillColor = AlertCardStyle.gdacsShapeColor(hazard.nativeWarningLevel);
      }
    } else {
      final band = hazard.severityBand ?? HazardSeverityBand.info;
      final named = hazard.displayWarningLevel;
      final airRating = _airQualityRating(hazard);
      final gdacsImpact = hazard.isGdacs
          ? switch ((named ?? hazard.nativeWarningLevel ?? '').toLowerCase()) {
              final v when v.contains('red') => 'HIGH IMPACT',
              final v when v.contains('orange') => 'MEDIUM IMPACT',
              final v when v.contains('green') => 'LOW IMPACT',
              _ => null,
            }
          : null;
      if (gdacsImpact != null) {
        // GDACS colours mean humanitarian impact, so the pill says so
        // ("orange earthquake doesn't make sense", owner, 13 Nov 2026).
        label = 'GDACS: $gdacsImpact';
        pillColor = AlertCardStyle.gdacsShapeColor(hazard.nativeWarningLevel);
      } else if (named != null && named.isNotEmpty && named != 'Unknown') {
        label = named.toUpperCase();
        pillColor = isAws ? band.colorAws : band.colorNonAws;
      } else if (hasAwsLevel) {
        label = severityTitle.toUpperCase();
        pillColor = band.colorAws;
      } else if (airRating != null) {
        label = 'AIR QUALITY: ${airRating.toUpperCase()}';
        pillColor = band.colorNonAws;
      } else {
        label = isAws ? 'AWS' : 'OFFICIAL';
      }
    }

    final postedAt = hazard.createdAt;
    final sourceName = hazard.displaySourceName;
    final right = [
      if (sourceName.isNotEmpty) sourceName,
      if (postedAt != null) 'Posted ${postedAt.timeAgo}',
    ].join(' · ');
    final Widget labelText = pillColor == null
        ? Text(
            label,
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AlertCardStyle.labelInkNeutral,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10.spMin,
              vertical: 5.spMin,
            ),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(8.spMin),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AlertCardStyle.inkOn(pillColor),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );

    return Row(
      children: [
        SourceShapeGlyph(
          isAws: isAws,
          isOfficial: hazard.source != null,
          isGlobalHumanitarian: hazard.isGlobalHumanitarian,
          isAlrtIntel: hazard.isAlrtIntel,
          color: hazard.isGdacs
              ? AlertCardStyle.gdacsShapeColor(hazard.nativeWarningLevel)
              : hazard.color,
          // 14 read as a speck next to the source (phone review, 14 Oct).
          size: 20.spMin,
        ),
        8.wSizedBox,
        // The level pill is a short fixed word ("MONITOR", "EMERGENCY WARNING")
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

  /// The WAQI rating the source publishes ("Air quality: poor (World Air
  /// Quality Index rating)"), which is a designated scale. Null otherwise.
  static String? _airQualityRating(final Hazard hazard) {
    if (hazard.source?.id != 'waqi') return null;
    final match = RegExp(
      r'Air quality:\s*(.+?)\s*\(World Air Quality Index rating\)',
      caseSensitive: false,
    ).firstMatch(hazard.description ?? '');
    final rating = match?.group(1)?.trim();
    return rating == null || rating.isEmpty ? null : rating;
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
              borderRadius: BorderRadius.circular(8.spMin),
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
          categoryName: hazard.displayCategoryName,
          sourceName: hazard.displaySourceName,
          locationName: hazard.locationName,
          title: hazard.displayTitle,
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
                  borderRadius: BorderRadius.circular(10.spMin),
                  boxShadow: const [AlertCardStyle.cardShadow],
                ),
                child: Material(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(10.spMin),
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

  /// One location line: "place · 8.4 km from you". Source changes live above.
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
        final fragments = [
          if (place != null && place.isNotEmpty) place,
          if (distanceText != null) distanceText,
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
            if (hazard == null) return const SizedBox.shrink();
            // One alert display (owner review, 13 November 2026): every
            // official alert renders through the same structured card.
            // Older records without structured content are adapted on the
            // phone, so no alert falls back to a different layout.
            return AgencyContentSections(
              content: _displayContentOf(hazard),
              showOriginalSource: false,
              sourceName: hazard.displaySourceName,
              warningLevel: hazard.displayWarningLevel,
              officialIntro: AlertTextUtil.issuedLine(
                hazard.source?.name,
                hazard.category?.name ?? hazard.title,
                hazard.locationName,
              ),
              severityColor: hazard.color,
              // The safety guide sits at the bottom of the What to do box
              // (owner, 17 November 2026), so the next step is one tap from
              // the advice.
              whatToDoFooter: GuideStripCard(
                categoryId: hazard.category?.id,
                level: hazard.displayWarningLevel,
              ),
            );
          },
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


        _buildTellYourPeopleSection(),

        // Community alerts: I see it / I don't see it voting, the
        // unverified note, then Follow / Listen / Report.
        _buildCommunityVoteSection(),
        12.hSizedBox,

        // Attribution
        Consumer(
          builder: (context, ref, child) {
            final hazard = ref.watch(provider.select((value) => value.hazard));
            if (hazard == null || hazard.isUserReported) {
              return const SizedBox.shrink();
            }
            final content = _displayContentOf(hazard);
            final source =
                content['originalSourceText'] ?? content['sourceDescription'];
            return source is String
                ? AgencyOriginalSourceDetails(text: source)
                : const SizedBox.shrink();
          },
        ),
        _buildTimelineSection(),
        _buildSourceSection(),
        _buildSourceFootnote(),

        // Data Attribution Footer (new)
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
      sourceName: hazard.displaySourceName,
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

  /// One tap: shares the alert with the chosen group. No note sheet, no
  /// second sheet, and never a location: the owner adds location from
  /// Family when she wants to. ("I'm safe" was dropped from Tell your
  /// people, owner review 17 November 2026.)
  Future<void> _quickSendToCircle(
    final Hazard hazard,
    final FamilyCircleSummary circle,
  ) async {
    if (_sendingToGroup || hazard.id == null) return;
    setState(() => _sendingToGroup = true);
    try {
      final result = await ref
          .read(providerOfFamilyRepository)
          .shareHazardWithCircle(
            circleId: circle.circleId,
            hazardId: hazard.id!,
            note: null,
          );
      if (!mounted) return;
      if (!result.isSuccess) {
        if (AccessRefusal.fromError(result.failure) != null) {
          await showFamilyActionError(
            context,
            ref,
            result.failure,
            circleId: circle.circleId,
          );
          return;
        }
        context.showErrorToast(
          message: 'That could not be sent. Please try again.',
        );
        return;
      }
      context.showSuccessToast(message: 'Alert sent to ${circle.name}.');
    } finally {
      if (mounted) setState(() => _sendingToGroup = false);
    }
  }

  /// The structured content the alert card reads: the stored content when
  /// the alert has it, otherwise the same shape built from the older fields.
  Map<String, dynamic> _displayContentOf(final Hazard hazard) {
    if (hazard.hasStructuredAgencyContent) return hazard.contentDetails!;
    return AlertTextUtil.legacyDisplayContent(
      description: hazard.description,
      aiSummary: hazard.aiSummary,
      callsToAction: hazard.callsToAction,
      nativeLevel: hazard.displayWarningLevel,
      issuedLine: AlertTextUtil.issuedLine(
        hazard.source?.name,
        hazard.category?.name ?? hazard.title,
        hazard.locationName,
      ),
      hazardBucket: AlertGuidanceLibrary.bucketFor(
        categoryName: hazard.category?.name,
        parentCategoryName: hazard.category?.parent?.name,
        title: hazard.title,
      ),
    );
  }

  /// Tell your people (owner review, 17 November 2026): one card with a
  /// purple outline and three rows. Row one sends the alert to the group
  /// (the arrow beside it changes the group); people without a group see
  /// "Send to your group" with the ALRT + badge instead. Then Send link and
  /// Invite, each with what it does, split by a thin line. Small and
  /// streamlined, never a stack of big buttons.
  Widget _buildTellYourPeopleSection() {
    return Consumer(
      builder: (context, ref, child) {
        final hazard = ref.watch(provider.select((v) => v.hazard));
        if (hazard == null) return const SizedBox.shrink();
        final circles = ref.watch(providerOfFamily.select((s) => s.circles));
        final activeCircleId = ref.watch(
          providerOfFamily.select((s) => s.circle?.id),
        );
        final hasPlus = ref.watch(providerOfAlrtPlus).value ?? false;
        final selected = circles.isEmpty
            ? null
            : circles.firstWhere(
                (c) => c.circleId == activeCircleId,
                orElse: () => circles.first,
              );

        // Tell your people (owner design, 24 November 2026): one white
        // card; the orange Send to {group} pill, Send link and Invite side
        // by side, and the privacy line.
        return Padding(
          padding: EdgeInsets.only(top: 24.spMin),
          child: _detailSectionCard(
            children: [
              _detailSectionLabel('TELL YOUR PEOPLE'),
              6.hSizedBox,
              Text(
                'Let your people know.',
                style: TextStyle(
                  fontSize: 20.spMin,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppColors.ink,
                ),
              ),
              14.hSizedBox,
              if (selected != null)
                _sendToGroupRow(hazard, selected)
              else
                _getGroupRow(hasPlus: hasPlus),
              10.hSizedBox,
              Row(
                children: [
                  Expanded(
                    child: _shareOutlinePill(
                      icon: LucideIcons.link,
                      label: 'Send link',
                      semantics:
                          'Send link. By text, WhatsApp or email. No app needed.',
                      onTap: () =>
                          shareAlert(ref: ref, hazard: hazard, from: 'detail'),
                    ),
                  ),
                  10.wSizedBox,
                  Expanded(
                    child: _shareOutlinePill(
                      icon: LucideIcons.userPlus,
                      label: 'Invite',
                      semantics:
                          'Invite. They join ALRT and get alerts automatically next time.',
                      onTap: () => showShareAlrtSheet(context),
                    ),
                  ),
                ],
              ),
              12.hSizedBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.lock,
                    size: 13.spMin,
                    color: AppColors.mediumGrey,
                  ),
                  6.wSizedBox,
                  Flexible(
                    child: Text(
                      selected != null
                          ? 'Private to your group. No location unless you add it.'
                          : 'No location shared unless you add it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.spMin,
                        color: AppColors.mediumGrey,
                      ),
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

  static const _shareGradient = LinearGradient(
    colors: [AppColors.orange300, AppColors.red200],
  );

  /// The orange gradient pill of Tell your people: the main part sends
  /// the alert to the group, the arrow behind a thin divider changes group.
  Widget _sendToGroupRow(
    final Hazard hazard,
    final FamilyCircleSummary selected,
  ) {
    final busy = _sendingToGroup;
    final radius = BorderRadius.circular(999);
    final initial = selected.name.trim().isEmpty
        ? '?'
        : selected.name.trim().characters.first.toUpperCase();
    final count = selected.memberCount;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _shareGradient,
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF6B00),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60.spMin,
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Send this alert to ${selected.name}',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: busy
                        ? null
                        : () => _quickSendToCircle(hazard, selected),
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.spMin, right: 14.spMin),
                      child: Row(
                        children: [
                          Container(
                            width: 44.spMin,
                            height: 44.spMin,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              initial,
                              style: TextStyle(
                                fontSize: 17.spMin,
                                fontWeight: FontWeight.w800,
                                color: AppColors.orange300,
                              ),
                            ),
                          ),
                          12.wSizedBox,
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Send to ${selected.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                                if (count > 0)
                                  Text(
                                    count == 1 ? '1 person' : '$count people',
                                    style: TextStyle(
                                      fontSize: 12.5.spMin,
                                      color: AppColors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (busy)
                            SizedBox(
                              width: 18.spMin,
                              height: 18.spMin,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          else
                            Icon(
                              LucideIcons.send,
                              size: 20.spMin,
                              color: AppColors.white,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                margin: EdgeInsets.symmetric(vertical: 14.spMin),
                color: AppColors.white.withValues(alpha: 0.45),
              ),
              Semantics(
                button: true,
                label: 'Change group',
                child: InkWell(
                  onTap: busy ? null : () => showChooseCircleSheet(context, ref),
                  child: SizedBox(
                    width: 52.spMin,
                    height: double.infinity,
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: 20.spMin,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The same orange pill for someone with no group yet. Without ALRT +
  /// it carries the badge and opens the plans; with it, the group chooser.
  Widget _getGroupRow({required final bool hasPlus}) {
    final radius = BorderRadius.circular(999);
    return Semantics(
      button: true,
      label: hasPlus
          ? 'Send to your group. Choose or start a group'
          : 'Send to your group. Needs ALRT +',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: _shareGradient, borderRadius: radius),
        child: Material(
          color: AppColors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => hasPlus
                ? showChooseCircleSheet(context, ref)
                : context.push(AlrtPlusChooseScreen.route),
            child: SizedBox(
              height: 60.spMin,
              child: Padding(
                padding: EdgeInsets.only(left: 8.spMin, right: 16.spMin),
                child: Row(
                  children: [
                    Container(
                      width: 44.spMin,
                      height: 44.spMin,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.users,
                        size: 20.spMin,
                        color: AppColors.orange300,
                      ),
                    ),
                    12.wSizedBox,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Send to your group',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.spMin,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              if (!hasPlus) ...[
                                8.wSizedBox,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.spMin,
                                    vertical: 2.spMin,
                                  ),
                                  decoration: BoxDecoration(
                                    // The ALRT + plan purple (CLAUDE.md,
                                    // plan names and colours).
                                    color: const Color(0xFF7B359A),
                                    borderRadius: BorderRadius.circular(
                                      6.spMin,
                                    ),
                                  ),
                                  child: Text(
                                    'ALRT +',
                                    style: TextStyle(
                                      fontSize: 11.spMin,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            'Alert your family in one tap.',
                            style: TextStyle(
                              fontSize: 12.5.spMin,
                              color: AppColors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 20.spMin,
                      color: AppColors.white,
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

  /// Send link / Invite: outlined pills side by side.
  Widget _shareOutlinePill({
    required final IconData icon,
    required final String label,
    required final String semantics,
    required final VoidCallback onTap,
  }) {
    final radius = BorderRadius.circular(999);
    return Semantics(
      button: true,
      label: semantics,
      excludeSemantics: true,
      child: Material(
        color: AppColors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 46.spMin,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: const Color(0xFFDADDE3), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17.spMin, color: AppColors.ink),
                8.wSizedBox,
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                    icon: isFollowing ? LucideIcons.check : LucideIcons.bell,
                    highlighted: isFollowing,
                    highlightInk: _followingInk,
                    highlightLine: _followingLine,
                    highlightWash: _followingWash,
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
    final Color highlightInk = _litInk,
    final Color highlightLine = _litInk,
    final Color highlightWash = _litWash,
  }) {
    // Community board: 48 high, radius 14, a hairline warm-grey border.
    final ink = highlighted ? highlightInk : AppColors.ink;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.spMin),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48.spMin,
          decoration: BoxDecoration(
            color: highlighted ? highlightWash : AppColors.white,
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(
              color: highlighted ? highlightLine : const Color(0xFFD9D6D0),
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

/// Dot styles in the Updates timeline.
enum _UpdateDot { past, latest, future }
