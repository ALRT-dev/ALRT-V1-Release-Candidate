import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the "Add a widget" setup step is finished with.
///
/// The OS never tells the app whether a home screen widget was placed, so the
/// step counts as done once the user has opened it (or dismissed it). The flag
/// lives on the device only. [loaded] is false until the preference has been
/// read, so the Finish setting up strip can wait instead of flashing a step
/// that is already done.
class WidgetStepState {
  const WidgetStepState({this.done = false, this.loaded = false});

  final bool done;
  final bool loaded;
}

class WidgetStepNotifier extends Notifier<WidgetStepState> {
  static const prefsKey = 'setup_widget_step_done';

  @override
  WidgetStepState build() {
    _load();
    return const WidgetStepState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(prefsKey) ?? false;
    // A step marked done while the read was in flight must not be undone.
    state = WidgetStepState(done: done || state.done, loaded: true);
  }

  /// The user opened or dismissed the step: it never comes back.
  Future<void> markDone() async {
    state = WidgetStepState(done: true, loaded: state.loaded);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
  }
}

final providerOfWidgetStep =
    NotifierProvider<WidgetStepNotifier, WidgetStepState>(
      WidgetStepNotifier.new,
    );

/// The "Add a widget" step is offered on Android only: the iOS widget
/// target is not in the Xcode project yet.
bool widgetStepAvailableOn(final TargetPlatform platform) =>
    platform == TargetPlatform.android;
