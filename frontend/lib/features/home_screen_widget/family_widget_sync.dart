import 'dart:async';

import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/home_screen_widget/family_group_icon_renderer.dart';
import 'package:hazard_app/features/home_screen_widget/family_widget_model.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_keys.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_service.dart';
import 'package:hazard_app/features/home_screen_widget/models/family_widget_payload.dart';

/// Builds the Family status widget payload from [FamilyProviderState] and
/// pushes it. Wired via a listener on the family provider, so it runs on every
/// state change — a cheap signature guard suppresses redundant writes.
class FamilyWidgetSync {
  const FamilyWidgetSync._();

  static String? _lastSignature;

  /// Renders are serialized: the listener fires often, and two overlapping
  /// renders would race on the same icon files.
  static Future<void> _pending = Future<void>.value();

  static void push(final FamilyProviderState state) {
    final payload = FamilyWidgetModel.build(state);
    // Signature covers only what the widget renders — skip disk writes for
    // unrelated state churn (loading flags, etc.).
    final signature =
        '${payload.state}|${payload.headline}|${payload.sub}|'
        '${payload.rows.map((r) => '${r.circleId}:${r.kind.wire}:${r.headline}:${r.sub}').join(',')}|'
        '${payload.moreCircles}|${_groupSignature(state)}';
    if (signature == _lastSignature) return;
    _lastSignature = signature;

    _pending = _pending.then((_) => _pushWithIcons(state, payload));
  }

  /// Clears the widget on sign-out (and account deletion), so a signed-out
  /// phone never keeps showing the last signed-in person's circles, and the
  /// next person to sign in on this device does not briefly inherit them.
  static Future<void> clear() {
    _lastSignature = null;
    return HomeWidgetService.updateFamily(
      FamilyWidgetModel.signedOut(DateTime.now()),
    );
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
    final iconByCircle = <String, String?>{};

    for (var index = 0; index < summaries.length; index++) {
      final summary = summaries[index];
      final path = await FamilyGroupIconRenderer.render(
        key: '${HomeWidgetKeys.familyGroupIconKeyPrefix}$index',
        name: summary.name,
        photoUrl: summary.photoUrl,
        themeColorHex: summary.themeColor,
      );
      iconByCircle[summary.circleId] = path;
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
        generatedAt: payload.generatedAt,
        circleName: payload.circleName,
        rows: payload.rows
            .map((r) => r.withIcon(iconByCircle[r.circleId]))
            .toList(),
        moreCircles: payload.moreCircles,
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
    final ordered = [...state.circles]
      ..sort((a, b) {
        if (a.circleId == currentId) return -1;
        if (b.circleId == currentId) return 1;
        return 0;
      });
    return ordered.take(FamilyWidgetPayload.maxRows).toList();
  }

  /// Everything about the group row that changes what is drawn.
  static String _groupSignature(final FamilyProviderState state) {
    return _orderedGroups(state)
        .map((s) => '${s.circleId}:${s.name}:${s.photoUrl}:${s.themeColor}')
        .join(',');
  }
}
