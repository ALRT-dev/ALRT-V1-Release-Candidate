import 'dart:async';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/home_screen_widget/family_group_icon_renderer.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_keys.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_service.dart';
import 'package:hazard_app/features/home_screen_widget/models/family_widget_payload.dart';

/// Builds the Family status widget payload from [FamilyProviderState] and
/// pushes it. Wired via a listener on the family provider, so it runs on every
/// state change — a cheap signature guard suppresses redundant writes.
class FamilyWidgetSync {
  const FamilyWidgetSync._();

  static const _familyDeeplink =
      '${HomeWidgetKeys.deeplinkScheme}://open?screen=family';
  static const _sosDeeplink =
      '${HomeWidgetKeys.deeplinkScheme}://open?screen=family_sos';

  static String? _lastSignature;

  /// Renders are serialized: the listener fires often, and two overlapping
  /// renders would race on the same icon files.
  static Future<void> _pending = Future<void>.value();

  static void push(final FamilyProviderState state) {
    final payload = _build(state);
    // Signature covers only what the widget renders — skip disk writes for
    // unrelated state churn (loading flags, etc.). The group row is part of
    // it, so a new group or a changed picture repaints.
    final signature = '${payload.state}|${payload.circleName}|'
        '${payload.headline}|${payload.sub}|${_groupSignature(state)}';
    if (signature == _lastSignature) return;
    _lastSignature = signature;

    _pending = _pending.then((_) => _pushWithIcons(state, payload));
  }

  /// Renders each group's icon to a file the widget process can read, then
  /// writes the payload. The text is never held hostage by an image: a
  /// failed render just leaves that slot without an icon.
  static Future<void> _pushWithIcons(
    final FamilyProviderState state,
    final FamilyWidgetPayload payload,
  ) async {
    final summaries = _orderedGroups(state);
    final groups = <FamilyWidgetGroup>[];

    for (var index = 0; index < summaries.length; index++) {
      final summary = summaries[index];
      final path = await FamilyGroupIconRenderer.render(
        key: '${HomeWidgetKeys.familyGroupIconKeyPrefix}$index',
        name: summary.name,
        photoUrl: summary.photoUrl,
        themeColorHex: summary.themeColor,
      );
      groups.add(
        FamilyWidgetGroup(
          circleId: summary.circleId,
          name: summary.name,
          isCurrent: summary.circleId == state.circle?.id,
          iconPath: path,
        ),
      );
    }

    await HomeWidgetService.updateFamily(
      FamilyWidgetPayload(
        state: payload.state,
        headline: payload.headline,
        sub: payload.sub,
        deeplink: payload.deeplink,
        circleName: payload.circleName,
        groups: groups,
      ),
    );
  }

  /// The groups the widget draws: the one in scope first, so the icon that
  /// matches the headline is the one nearest it.
  static List<FamilyCircleSummary> _orderedGroups(
    final FamilyProviderState state,
  ) {
    final currentId = state.circle?.id;
    final ordered = [...state.circles]..sort((a, b) {
        if (a.circleId == currentId) return -1;
        if (b.circleId == currentId) return 1;
        return 0;
      });
    return ordered.take(FamilyWidgetPayload.maxGroups).toList();
  }

  /// Everything about the group row that changes what is drawn.
  static String _groupSignature(final FamilyProviderState state) {
    return _orderedGroups(state)
        .map((s) => '${s.circleId}:${s.name}:${s.photoUrl}:${s.themeColor}')
        .join(',');
  }

  static FamilyWidgetPayload _build(final FamilyProviderState state) {
    final circle = state.circle;

    if (circle == null) {
      return const FamilyWidgetPayload(
        state: 'no_circle',
        headline: 'No family circle',
        sub: 'Set up in the app',
        deeplink: _familyDeeplink,
      );
    }

    // Live SOS from someone else is the one critical state.
    final sos = state.activeSosFromOthers.firstOrNull;
    if (sos != null) {
      final member =
          circle.members.firstWhereOrNull((m) => m.id == sos.memberId);
      final name = member?.name ?? 'A family member';
      final when = sos.createdAt != null ? timeago.format(sos.createdAt!) : null;
      final sub = [sos.locationLabel, when]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join('  ·  ');
      return FamilyWidgetPayload(
        state: 'sos',
        headline: '$name needs help',
        sub: sub.isEmpty ? 'SOS active' : sub,
        deeplink: _sosDeeplink,
        circleName: circle.name,
      );
    }

    // A check-in the user has not answered outranks the roll call: the
    // widget is where they will see it if the app is closed, and the
    // action they owe is their own.
    final request = circle.latestCheckInRequest;
    final askedAt = request?.createdAt;
    if (request != null && !_hasAnsweredSince(circle.me, askedAt)) {
      final who = request.requestedBy?.displayName ?? 'Your circle';
      return FamilyWidgetPayload(
        state: 'check_in_requested',
        headline: '$who asked for a check-in',
        sub: askedAt == null
            ? 'Tap to say you are safe'
            : '${timeago.format(askedAt)} · tap to say you are safe',
        deeplink: _familyDeeplink,
        circleName: circle.name,
      );
    }

    final others = circle.others;
    if (others.isEmpty) {
      return FamilyWidgetPayload(
        state: 'safe',
        headline: 'No one to check on yet',
        sub: 'Invite family in the app',
        deeplink: _familyDeeplink,
        circleName: circle.name,
      );
    }

    // With an ask on record, "checked in" means since the ask, so the
    // count on the home screen matches the roll call inside the app.
    final checkedIn = others
        .where((m) => _hasAnsweredSince(m, askedAt))
        .length;
    final total = others.length;
    final updated = 'Updated ${DateFormat.jm().format(DateTime.now())}';

    if (checkedIn == total) {
      return FamilyWidgetPayload(
        state: 'safe',
        headline: "Everyone's safe",
        sub: '$total of $total checked in',
        deeplink: _familyDeeplink,
        circleName: circle.name,
      );
    }

    return FamilyWidgetPayload(
      state: 'partial',
      headline: '$checkedIn of $total checked in',
      sub: askedAt == null ? updated : 'Waiting on ${total - checkedIn}',
      deeplink: _familyDeeplink,
      circleName: circle.name,
    );
  }

  /// Whether [member] has checked in since [askedAt]. With no ask on
  /// record the usual 24-hour "recently" window stands in.
  static bool _hasAnsweredSince(
    final FamilyMember? member,
    final DateTime? askedAt,
  ) {
    if (member == null) return true;
    if (askedAt == null) return member.isCheckedInRecently;
    final last = member.lastCheckInAt;
    return last != null && last.isAfter(askedAt);
  }
}
