import 'package:collection/collection.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_keys.dart';
import 'package:hazard_app/features/home_screen_widget/models/family_widget_payload.dart';

/// Pure builder for the Family widget: state in, payload out, no I/O, so
/// every row and every word can be tested. Wording rules (owner, 9 Sep):
/// say "circle"; put a live SOS first, then a check-in someone is waiting
/// on from me, then asks I am waiting on, then ordinary status; never
/// claim everyone is safe because of an old check-in; never show a
/// member's name, a location or a safety-profile detail.
abstract final class FamilyWidgetModel {
  static const scheme = HomeWidgetKeys.deeplinkScheme;

  static String familyLink([final String? circleId]) => circleId == null
      ? '$scheme://open?screen=family'
      : '$scheme://open?screen=family&circleId=$circleId';
  static String checkInLink(final String circleId) =>
      '$scheme://open?screen=family_checkin&circleId=$circleId';
  static String sosLink({
    required final String circleId,
    required final String sosId,
  }) => '$scheme://open?screen=family_sos&circleId=$circleId&sosId=$sosId';

  static FamilyWidgetPayload signedOut(final DateTime now) =>
      FamilyWidgetPayload(
        state: 'signed_out',
        headline: 'Signed out',
        sub: 'Open ALRT and sign in to see your circles',
        deeplink: familyLink(),
        generatedAt: now,
      );

  static FamilyWidgetPayload build(
    final FamilyProviderState state, {
    final DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    final circle = state.circle;
    final summaries = state.circles;

    if (circle == null && summaries.isEmpty) {
      return FamilyWidgetPayload(
        state: 'no_circle',
        headline: 'No family circle yet',
        sub: 'Create or join one in the app',
        deeplink: familyLink(),
        generatedAt: at,
      );
    }

    // One row per circle. The open circle is described from its full
    // detail; the others from the circle list the server keeps for the
    // switcher (open asks owed by me, checked-in counts, the live SOS).
    final rows = <FamilyWidgetRow>[];
    final seen = <String>{};
    if (circle != null) {
      rows.add(_rowForOpenCircle(circle, state));
      seen.add(circle.id);
    }
    for (final summary in summaries) {
      if (!seen.add(summary.circleId)) continue;
      rows.add(_rowForSummary(summary, state));
    }
    rows.sort((a, b) {
      final byPriority = a.kind.priority.compareTo(b.kind.priority);
      if (byPriority != 0) return byPriority;
      if (a.isCurrent != b.isCurrent) return a.isCurrent ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    final shown = rows.take(FamilyWidgetPayload.maxRows).toList();
    final top = rows.first;
    final sosCount = rows
        .where(
          (r) =>
              r.kind == FamilyWidgetRowKind.sosMine ||
              r.kind == FamilyWidgetRowKind.sosOther,
        )
        .length;
    final requestCount = rows
        .where((r) => r.kind == FamilyWidgetRowKind.checkInRequested)
        .length;
    final waitingCount = rows
        .where((r) => r.kind == FamilyWidgetRowKind.waitingForResponses)
        .length;

    final String cardState;
    final String headline;
    final String sub;
    final String deeplink;
    switch (top.kind) {
      case FamilyWidgetRowKind.sosMine:
        cardState = 'sos';
        headline = 'Your SOS is active';
        sub = '${top.name} · tap to open it';
        deeplink = top.deeplink;
      case FamilyWidgetRowKind.sosOther:
        cardState = 'sos';
        headline = sosCount > 1 ? '$sosCount SOS active' : 'SOS active';
        sub = sosCount > 1
            ? 'Across $sosCount circles · tap to respond'
            : '${top.name} · tap to see who and respond';
        deeplink = top.deeplink;
      case FamilyWidgetRowKind.checkInRequested:
        cardState = 'check_in_requested';
        headline = requestCount > 1
            ? '$requestCount circles asked you to check in'
            : 'Check-in requested';
        sub = requestCount > 1
            ? 'Tap a circle to check in'
            : '${top.name} · tap to check in';
        deeplink = top.deeplink;
      case FamilyWidgetRowKind.waitingForResponses:
        cardState = 'waiting';
        headline = 'Waiting for responses';
        sub = waitingCount > 1
            ? 'Your asks in $waitingCount circles'
            : '${top.name} · ${top.sub}';
        deeplink = top.deeplink;
      case FamilyWidgetRowKind.ok:
        cardState = 'ok';
        headline = 'No pending requests';
        sub = rows.length > 1
            ? 'Across ${rows.length} circles'
            : '${top.name} · ${top.sub}';
        deeplink = top.deeplink;
    }

    return FamilyWidgetPayload(
      state: cardState,
      headline: headline,
      sub: sub,
      deeplink: deeplink,
      generatedAt: at,
      circleName: rows.length == 1 ? top.name : null,
      rows: shown,
      moreCircles: rows.length - shown.length,
    );
  }

  static FamilyWidgetRow _rowForOpenCircle(
    final FamilyCircle circle,
    final FamilyProviderState state,
  ) {
    final myMemberId = circle.myMemberId;
    final liveHere = state.activeSosEvents
        .where((e) => e.circleId == circle.id)
        .toList();
    final mine = liveHere.where((e) => e.memberId == myMemberId).firstOrNull;
    if (mine != null) {
      return FamilyWidgetRow(
        circleId: circle.id,
        name: circle.name,
        kind: FamilyWidgetRowKind.sosMine,
        headline: 'Your SOS is active',
        sub: 'Tap to open it',
        deeplink: sosLink(circleId: circle.id, sosId: mine.id),
        isCurrent: true,
      );
    }
    final other = liveHere.firstOrNull;
    if (other != null) {
      return FamilyWidgetRow(
        circleId: circle.id,
        name: circle.name,
        kind: FamilyWidgetRowKind.sosOther,
        headline: 'SOS active',
        sub: 'Tap to see who and respond',
        deeplink: sosLink(circleId: circle.id, sosId: other.id),
        isCurrent: true,
      );
    }
    final owed = circle.checkInRequestsOwedByMe;
    if (owed.isNotEmpty) {
      return FamilyWidgetRow(
        circleId: circle.id,
        name: circle.name,
        kind: FamilyWidgetRowKind.checkInRequested,
        headline: 'Check-in requested',
        sub: owed.length > 1
            ? '${owed.length} requests · tap to check in'
            : 'Tap to check in',
        deeplink: checkInLink(circle.id),
        isCurrent: true,
      );
    }
    // An ask I made that people have not all answered.
    final myAsks = circle.openCheckInRequests
        .where((r) => r.requestedById == myMemberId)
        .toList();
    if (myAsks.isNotEmpty) {
      final ask = myAsks.first;
      final askedAt = ask.createdAt;
      final targets = ask.targetMemberIds.isEmpty
          ? circle.others
          : circle.others
                .where((m) => ask.targetMemberIds.contains(m.id))
                .toList();
      final answered = targets.where((m) {
        final last = m.lastCheckInAt;
        return last != null && (askedAt == null || last.isAfter(askedAt));
      }).length;
      if (answered < targets.length) {
        return FamilyWidgetRow(
          circleId: circle.id,
          name: circle.name,
          kind: FamilyWidgetRowKind.waitingForResponses,
          headline: 'Waiting for responses',
          sub: '$answered of ${targets.length} answered',
          deeplink: familyLink(circle.id),
          isCurrent: true,
        );
      }
    }
    final others = circle.others;
    final recent = others.where((m) => m.isCheckedInRecently).length;
    return FamilyWidgetRow(
      circleId: circle.id,
      name: circle.name,
      kind: FamilyWidgetRowKind.ok,
      headline: 'No pending requests',
      sub: others.isEmpty
          ? 'Just you so far'
          : '$recent of ${others.length} checked in today',
      deeplink: familyLink(circle.id),
      isCurrent: true,
    );
  }

  static FamilyWidgetRow _rowForSummary(
    final FamilyCircleSummary summary,
    final FamilyProviderState state,
  ) {
    final live = state.activeSosEvents
        .where((e) => e.circleId == summary.circleId)
        .toList();
    final mine = live
        .where((e) => e.memberId == summary.myMemberId)
        .firstOrNull;
    if (mine != null) {
      return FamilyWidgetRow(
        circleId: summary.circleId,
        name: summary.name,
        kind: FamilyWidgetRowKind.sosMine,
        headline: 'Your SOS is active',
        sub: 'Tap to open it',
        deeplink: sosLink(circleId: summary.circleId, sosId: mine.id),
      );
    }
    final otherId = live.firstOrNull?.id ?? summary.activeSos?.id;
    if (otherId != null) {
      final summaryMine =
          live.isEmpty && summary.activeSos?.memberId == summary.myMemberId;
      return FamilyWidgetRow(
        circleId: summary.circleId,
        name: summary.name,
        kind: summaryMine
            ? FamilyWidgetRowKind.sosMine
            : FamilyWidgetRowKind.sosOther,
        headline: summaryMine ? 'Your SOS is active' : 'SOS active',
        sub: summaryMine ? 'Tap to open it' : 'Tap to see who and respond',
        deeplink: sosLink(circleId: summary.circleId, sosId: otherId),
      );
    }
    if (summary.pendingCheckInRequests > 0) {
      final n = summary.pendingCheckInRequests;
      return FamilyWidgetRow(
        circleId: summary.circleId,
        name: summary.name,
        kind: FamilyWidgetRowKind.checkInRequested,
        headline: 'Check-in requested',
        sub: n > 1 ? '$n requests · tap to check in' : 'Tap to check in',
        deeplink: checkInLink(summary.circleId),
      );
    }
    final othersCount = (summary.memberCount - 1).clamp(0, 1 << 30);
    return FamilyWidgetRow(
      circleId: summary.circleId,
      name: summary.name,
      kind: FamilyWidgetRowKind.ok,
      headline: 'No pending requests',
      sub: othersCount == 0
          ? 'Just you so far'
          : '${summary.checkedInCount.clamp(0, othersCount)} of $othersCount checked in today',
      deeplink: familyLink(summary.circleId),
    );
  }
}

/// What a widget tap asks the app to do. Parsed from the deep link so the
/// launch handler and the tests read one rule.
sealed class FamilyWidgetTap {
  const FamilyWidgetTap();

  static FamilyWidgetTap? parse(final Uri? uri) {
    if (uri == null || uri.scheme != HomeWidgetKeys.deeplinkScheme) return null;
    final q = uri.queryParameters;
    final circleId = q['circleId'];
    switch (q['screen']) {
      case 'alerts':
        return const OpenAlertsTap();
      case 'map':
        return const OpenMapTap();
      case 'family':
        return OpenFamilyTap(circleId: circleId);
      case 'family_checkin':
        return OpenCheckInTap(circleId: circleId);
      case 'family_sos':
        return OpenSosTap(circleId: circleId, sosId: q['sosId']);
      default:
        return null;
    }
  }
}

class OpenAlertsTap extends FamilyWidgetTap {
  const OpenAlertsTap();
}

class OpenMapTap extends FamilyWidgetTap {
  const OpenMapTap();
}

class OpenFamilyTap extends FamilyWidgetTap {
  const OpenFamilyTap({this.circleId});
  final String? circleId;
}

class OpenCheckInTap extends FamilyWidgetTap {
  const OpenCheckInTap({this.circleId});
  final String? circleId;
}

class OpenSosTap extends FamilyWidgetTap {
  const OpenSosTap({this.circleId, this.sosId});
  final String? circleId;
  final String? sosId;
}
