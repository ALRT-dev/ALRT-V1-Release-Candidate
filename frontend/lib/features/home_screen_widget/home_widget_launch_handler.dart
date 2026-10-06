import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_keys.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_service.dart';
import 'package:hazard_app/features/home_screen_widget/family_widget_model.dart';
import 'package:hazard_app/features/family/providers/family_provider.dart';
import 'package:hazard_app/features/family/providers/selected_circle_provider.dart';
import 'package:hazard_app/features/family/views/screens/family_check_in_roll_call_screen.dart';
import 'package:hazard_app/features/shared/providers/navigator_key_provider.dart';

/// Routes taps on the home-screen widget into the app.
///
/// A widget tap only ever *navigates* — it never triggers a side effect such as
/// firing SOS (locked rule 3). The payload's deeplink is a
/// [HomeWidgetKeys.deeplinkScheme] URI, e.g.
/// `alrtwidget://open?screen=alerts`.
class HomeWidgetLaunchHandler {
  HomeWidgetLaunchHandler(this._ref);

  final WidgetRef _ref;
  StreamSubscription<Uri?>? _sub;

  /// Wire up both cold-start and warm-tap handling. Call once from a widget
  /// that lives for the app's lifetime (see HOME_WIDGET_SETUP.md).
  Future<void> attach() async {
    // Warm taps while the app is already running.
    _sub = HomeWidgetService.clicks.listen(_handle);

    // Cold start: the app was launched by tapping the widget.
    final launchUri = await HomeWidgetService.initiallyLaunchedUri();
    _handle(launchUri);
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  void _handle(final Uri? uri) {
    final tap = FamilyWidgetTap.parse(uri);
    if (tap == null) return;
    final navigatorKey = _ref.read(providerOfGlobalNavigatorKey);
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Everything the widget surfaces lives on the home shell. A tap only
    // ever navigates: it never checks in, shares a location, acknowledges
    // an SOS or ends one; those stay behind their own consent steps.
    context.go(HomeScreen.route);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (tap) {
        case OpenAlertsTap():
          _ref.read(providerOfHomeTab.notifier).state = HomeTab.notifications;
        case OpenMapTap():
          _ref.read(providerOfHomeTab.notifier).state = HomeTab.map;
        case OpenFamilyTap(:final circleId):
          _selectCircle(circleId);
          _ref.read(providerOfHomeTab.notifier).state = HomeTab.family;
        case OpenCheckInTap(:final circleId):
          _selectCircle(circleId);
          _ref.read(providerOfHomeTab.notifier).state = HomeTab.family;
          // The roll call shows who asked and offers the one Check in
          // button, with its consent sheet; nothing is sent by the tap.
          final ctx = navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            ctx.push(FamilyCheckInRollCallScreen.route);
          }
        case OpenSosTap(:final circleId, :final sosId):
          _selectCircle(circleId);
          _ref.read(providerOfHomeTab.notifier).state = HomeTab.family;
          if (sosId != null && sosId.isNotEmpty) {
            unawaited(_ref.read(providerOfFamily.notifier).openSos(sosId));
          }
      }
    });
  }

  /// Puts [circleId] in scope when it is one of the account's circles; a
  /// stale id from an old widget payload is ignored.
  void _selectCircle(final String? circleId) {
    if (circleId == null || circleId.isEmpty) return;
    final state = _ref.read(providerOfFamily);
    final known =
        state.circle?.id == circleId ||
        state.circles.any((c) => c.circleId == circleId);
    if (!known) return;
    if (state.circle?.id == circleId) return;
    _ref.read(providerOfSelectedCircleId.notifier).select(circleId);
    unawaited(_ref.read(providerOfFamily.notifier).load(silent: true));
  }
}
