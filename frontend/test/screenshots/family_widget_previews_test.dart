// Previews of the home-screen Family circles widget for six states.
//
// These are Flutter replicas of the Android layout
// (android/app/src/main/res/layout/alrt_family_widget.xml) drawn from the
// real payload the app would hand the launcher (FamilyWidgetModel.build).
// They prove the words, ordering, colours and glyphs the widget receives.
// They do NOT prove on-device rendering: the launcher draws the payload
// with RemoteViews, so Android and iOS must still be checked on a phone.
//
// Opt-in only: `ALRT_SCREENSHOTS=1 flutter test --update-goldens
// test/screenshots` writes test/screenshots/goldens/*.png (git-ignored).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'screenshot_fonts.dart';
import 'package:hazard_app/features/family/providers/states/family_provider_state.dart';
import 'package:hazard_app/features/home_screen_widget/family_widget_model.dart';
import 'package:hazard_app/features/home_screen_widget/models/family_widget_payload.dart';

final _enabled = Platform.environment['ALRT_SCREENSHOTS'] == '1';

final _now = DateTime(2026, 9, 9, 9, 42);

FamilyMember _member(
  String id, {
  DateTime? lastCheckInAt,
  String name = 'Someone',
}) => FamilyMember(
  id: id,
  userId: 'u-$id',
  name: name,
  lastCheckInAt: lastCheckInAt,
);

FamilyCircle _circle({
  String id = 'c1',
  String name = 'Nixons',
  List<FamilyMember>? members,
  List<FamilyCheckInRequest> requests = const [],
}) => FamilyCircle(
  id: id,
  name: name,
  myMemberId: 'me',
  members:
      members ??
      [
        _member('me', name: 'Me'),
        _member('amy', name: 'Amy Nixon'),
        _member(
          'tom',
          name: 'Tom',
          lastCheckInAt: _now.subtract(const Duration(minutes: 40)),
        ),
      ],
  checkInRequests: requests,
);

FamilyCircleSummary _summary(
  String id,
  String name, {
  int pending = 0,
  FamilyCircleSosSummary? sos,
  int members = 3,
  int checkedIn = 1,
}) => FamilyCircleSummary(
  circleId: id,
  name: name,
  myMemberId: 'me-$id',
  memberCount: members,
  checkedInCount: checkedIn,
  pendingCheckInRequests: pending,
  activeSos: sos,
);

/// The six states the brief asks to preview.
Map<String, FamilyWidgetPayload> _scenes() => {
  '1 No pending requests': FamilyWidgetModel.build(
    FamilyProviderState(
      hasLoadedOnce: true,
      circle: _circle(),
      circles: [_summary('c1', 'Nixons')],
    ),
    now: _now,
  ),
  '2 One check-in request': FamilyWidgetModel.build(
    FamilyProviderState(
      hasLoadedOnce: true,
      circle: _circle(
        requests: [
          FamilyCheckInRequest(
            id: 'r1',
            circleId: 'c1',
            requestedById: 'amy',
            createdAt: _now.subtract(const Duration(minutes: 5)),
          ),
        ],
      ),
      circles: [_summary('c1', 'Nixons', pending: 1)],
    ),
    now: _now,
  ),
  '3 Several requests across circles': FamilyWidgetModel.build(
    FamilyProviderState(
      hasLoadedOnce: true,
      circle: _circle(),
      circles: [
        _summary('c1', 'Nixons'),
        _summary('c2', 'Weekend crew', pending: 1),
        _summary(
          'c3',
          'The very long school run circle name',
          pending: 3,
          members: 6,
          checkedIn: 4,
        ),
      ],
    ),
    now: _now,
  ),
  '4 Your SOS is active': FamilyWidgetModel.build(
    FamilyProviderState(
      hasLoadedOnce: true,
      circle: _circle(),
      circles: [
        _summary('c1', 'Nixons', pending: 2),
        _summary('c2', 'Weekend crew'),
      ],
      activeSosEvents: const [
        FamilySosEvent(id: 'sos-1', circleId: 'c1', memberId: 'me'),
      ],
    ),
    now: _now,
  ),
  "5 Another member's SOS": FamilyWidgetModel.build(
    FamilyProviderState(
      hasLoadedOnce: true,
      circle: _circle(),
      circles: [
        _summary('c1', 'Nixons'),
        _summary(
          'c2',
          'Weekend crew',
          sos: FamilyCircleSosSummary(
            id: 'sos-9',
            memberId: 'other',
            memberName: 'Amy Nixon',
            createdAt: _now,
          ),
        ),
      ],
    ),
    now: _now,
  ),
  '6 Signed out': FamilyWidgetModel.signedOut(_now),
};

// Colours copied from the Android drawables and provider.
const _purpleTop = Color(0xFF7A4BF5);
const _purpleMid = Color(0xFF5238DE);
const _purpleEnd = Color(0xFF1B1470);
const _criticalTop = Color(0xFFFF5247);
const _criticalEnd = Color(0xFFB80000);
const _rowSos = Color(0xFFD7263D);
const _rowRequest = Color(0xFFF5C518);
const _rowNeutral = Color(0x26FFFFFF);
const _amberHeadline = Color(0xFFF5C518);

String _glyph(FamilyWidgetRowKind kind) => switch (kind) {
  FamilyWidgetRowKind.sosMine || FamilyWidgetRowKind.sosOther => 'SOS',
  FamilyWidgetRowKind.checkInRequested => '!',
  FamilyWidgetRowKind.waitingForResponses => '…',
  FamilyWidgetRowKind.ok => '✓',
};

Color _rowBackground(FamilyWidgetRowKind kind) => switch (kind) {
  FamilyWidgetRowKind.sosMine || FamilyWidgetRowKind.sosOther => _rowSos,
  FamilyWidgetRowKind.checkInRequested => _rowRequest,
  _ => _rowNeutral,
};

/// A replica of alrt_family_widget.xml (full size, 4 rows) with the same
/// text sizes, colours, glyphs and freshness line as the Kotlin provider.
class _WidgetReplica extends StatelessWidget {
  const _WidgetReplica(this.payload, {this.stale = false});
  final FamilyWidgetPayload payload;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final critical = payload.isCritical;
    final kicker = payload.state == 'signed_out'
        ? 'FAMILY CIRCLES'
        : (payload.circleName ?? 'FAMILY CIRCLES').toUpperCase();
    final freshness = stale ? 'As of 8:12 am · open ALRT' : 'Updated 9:42 am';
    final subColor = critical
        ? const Color(0xFFFFE3E0)
        : const Color(0xFFCFC7EC);
    final kickerColor = critical
        ? const Color(0xFFFFD9D5)
        : const Color(0xFFD9D0F7);
    final headlineColor = !critical && payload.state == 'check_in_requested'
        ? _amberHeadline
        : Colors.white;

    return Container(
      width: 320,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: critical
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_criticalTop, _criticalEnd],
              )
            : const LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [_purpleTop, _purpleMid, _purpleEnd],
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  kicker,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kickerColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  freshness,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: subColor, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            payload.headline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: headlineColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (payload.sub.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              payload.sub,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: subColor, fontSize: 11),
            ),
          ],
          if (payload.rows.isNotEmpty) const SizedBox(height: 10),
          for (final row in payload.rows) _RowReplica(row),
          if (payload.moreCircles > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+${payload.moreCircles} more circle'
                '${payload.moreCircles > 1 ? 's' : ''} · open ALRT',
                style: TextStyle(color: subColor, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _RowReplica extends StatelessWidget {
  const _RowReplica(this.row);
  final FamilyWidgetRow row;

  @override
  Widget build(BuildContext context) {
    final dark = row.kind == FamilyWidgetRowKind.checkInRequested;
    final ink = dark ? const Color(0xFF231A00) : Colors.white;
    final inkSoft = dark ? const Color(0xFF4A3A00) : const Color(0xFFF2EEFF);
    final status = [
      row.headline,
      row.sub,
    ].where((s) => s.isNotEmpty).join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _rowBackground(row.kind),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            // The launcher's system font has "✓"; the test font does not,
            // so the tick is drawn as an icon here.
            child: row.kind == FamilyWidgetRowKind.ok
                ? Icon(Icons.check, size: 16, color: ink)
                : Text(
                    _glyph(row.kind),
                    style: TextStyle(
                      color: ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  status,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: inkSoft, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.textScale});
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final scenes = _scenes();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          backgroundColor: const Color(0xFFE9E6F2),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family circles widget · Flutter replica of the Android '
                  'layout, drawn from the real payload (text ${textScale}x). '
                  'On-device rendering not yet observed.',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 14),
                for (final entry in scenes.entries) ...[
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _WidgetReplica(entry.value),
                  const SizedBox(height: 18),
                ],
                const Text(
                  '7 Stale payload (over an hour old)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                _WidgetReplica(scenes.values.first, stale: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    if (_enabled) await loadScreenshotFonts();
  });

  Future<void> shoot(WidgetTester tester, String name, double scale) async {
    const size = Size(390, 1700);
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    await tester.pumpWidget(_Sheet(textScale: scale));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('widget previews, six states', (tester) async {
    await shoot(tester, '20_widget_previews', 1.0);
  }, skip: !_enabled);

  testWidgets('widget previews, large text', (tester) async {
    await shoot(tester, '21_widget_previews_large_text', 1.4);
  }, skip: !_enabled);

  // Always-on checks that the six states carry the words the brief asks
  // for, whatever the renderer does with them.
  test('the six preview states say what the brief requires', () {
    final s = _scenes();
    expect(s['1 No pending requests']!.headline, 'No pending requests');
    expect(s['2 One check-in request']!.headline, 'Check-in requested');
    expect(
      s['3 Several requests across circles']!.headline,
      '2 circles asked you to check in',
    );
    expect(s['4 Your SOS is active']!.headline, 'Your SOS is active');
    expect(s["5 Another member's SOS"]!.headline, 'SOS active');
    expect(s['6 Signed out']!.headline, 'Signed out');
    for (final p in s.values) {
      expect(p.toJson().toString(), isNot(contains('Amy Nixon')));
    }
  });
}
