import 'package:flutter/material.dart';
import 'package:hazard_app/features/notification/models/push_notification_settings_model.dart';
import 'package:hazard_app/features/notification/views/widgets/manage_push_notifications_list.dart';
import 'package:hazard_app/features/shared/providers/hazard_filters_provider.dart';

/// The four "which alerts show" choices, one set of words and shapes on the
/// Filters sheet and the Map details sheet (owner, 15 Oct 2026). Emergency
/// warnings are always on whichever is picked.
enum ShowChoice {
  /// Triangle and diamond: every official source, no community reports.
  official('Official warnings only', 'Official', NotificationLevel.officialOnly),

  /// Triangle, diamond and circle: official and community.
  all('All alerts', 'All', NotificationLevel.officialAndCommunity),

  /// Circle: community reports with Emergency Warnings.
  community('Community only', 'Community', NotificationLevel.communityOnly),

  /// Emergency Warnings only.
  quiet('Keep it quiet', 'Quiet', NotificationLevel.quiet);

  const ShowChoice(this.title, this.shortTitle, this.level);

  final String title;
  final String shortTitle;
  final NotificationLevel level;

  /// The shapes the choice stands for: triangle (AWS), diamond (official),
  /// circle (community). Quiet has none (a bell with a line through it).
  List<IconData> get shapes => switch (this) {
        ShowChoice.official => const [Icons.change_history, Icons.diamond_outlined],
        ShowChoice.all => const [
            Icons.change_history,
            Icons.diamond_outlined,
            Icons.circle_outlined,
          ],
        ShowChoice.community => const [Icons.circle_outlined],
        ShowChoice.quiet => const [Icons.notifications_off_outlined],
      };

  /// The choice the current switches amount to.
  static ShowChoice of(final HazardFilterSwitches f) {
    final level = notificationLevelOf(
      PushNotificationSettings(
        awsEmergency: true,
        awsWatchAndAct: f.awsWatchAndAct,
        awsAdvice: f.awsAdvice,
        officialNonAws: f.officialNonAws,
        userReported: f.userReported,
      ),
    );
    return values.firstWhere((c) => c.level == level);
  }

  /// Applies the choice to the shared filters.
  void apply(final HazardFiltersProvider notifier, final HazardFilterSwitches f) {
    final next = settingsForLevel(
      PushNotificationSettings(
        awsEmergency: true,
        awsWatchAndAct: f.awsWatchAndAct,
        awsAdvice: f.awsAdvice,
        officialNonAws: f.officialNonAws,
        userReported: f.userReported,
      ),
      level,
    );
    notifier
      ..updateAwsAdvice(next.awsAdvice)
      ..updateAwsWatchAndAct(next.awsWatchAndAct)
      ..updateOfficialNonAws(next.officialNonAws)
      ..updateUserReported(next.userReported);
  }
}

/// The four switches a choice is derived from, read off the filter state.
class HazardFilterSwitches {
  const HazardFilterSwitches({
    required this.awsWatchAndAct,
    required this.awsAdvice,
    required this.officialNonAws,
    required this.userReported,
  });

  final bool awsWatchAndAct;
  final bool awsAdvice;
  final bool officialNonAws;
  final bool userReported;
}
