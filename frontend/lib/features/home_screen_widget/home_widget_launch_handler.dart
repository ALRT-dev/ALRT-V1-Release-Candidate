import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/home/views/screens/home_screen.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_keys.dart';
import 'package:hazard_app/features/home_screen_widget/home_widget_service.dart';
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
    if (uri == null || uri.scheme != HomeWidgetKeys.deeplinkScheme) return;

    final screen = uri.queryParameters['screen'];
    final navigatorKey = _ref.read(providerOfGlobalNavigatorKey);
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Everything the widget surfaces lives on the home shell.
    context.go(HomeScreen.route);

    // Select the tab the widget points at, after the route settles.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (screen) {
        case 'alerts':
          _ref.read(providerOfHomeTab.notifier).state = HomeTab.notifications;
          break;
        case 'map':
          _ref.read(providerOfHomeTab.notifier).state = HomeTab.map;
          break;
        // Both family cases land on the Family tab, where an active SOS is
        // surfaced by the app's own banner. The widget never opens SOS directly.
        case 'family':
        case 'family_sos':
          _ref.read(providerOfHomeTab.notifier).state = HomeTab.family;
          break;
        default:
          break;
      }
    });
  }
}
