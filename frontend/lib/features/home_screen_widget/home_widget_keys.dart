/// Shared constants for the ALRT home-screen widget (iOS WidgetKit +
/// Android App Widget), bridged through the `home_widget` plugin.
///
/// These MUST stay in sync with the native side:
///  - iOS: `ios/AlrtWidget/AlrtAlertsWidget.swift` (App Group + payload key)
///  - Android: `AlrtAlertsWidgetProvider.kt` (payload key)
class HomeWidgetKeys {
  const HomeWidgetKeys._();

  /// App Group used to share data between the Flutter app and the iOS widget
  /// extension. Must match the App Group added in Xcode to BOTH the Runner
  /// target and the AlrtWidget extension target.
  static const appGroupId = 'group.com.safetyalrt.alrt';

  /// The single JSON payload the Nearby Alerts widget renders from. One key
  /// keeps the Dart/Kotlin/Swift contract trivial to reason about.
  static const payloadKey = 'alrt_widget_payload';

  /// The JSON payload for the Family status widget.
  static const familyPayloadKey = 'alrt_family_widget_payload';

  /// Prefix for the per-group icon files the Family widget draws. The
  /// index is appended, so the same slots are reused rather than the
  /// shared container filling up with one file per group ever seen.
  static const familyGroupIconKeyPrefix = 'alrt_family_group_icon_';

  /// Android provider class name (as registered in AndroidManifest.xml).
  static const androidProviderName = 'AlrtAlertsWidgetProvider';

  /// iOS widget `kind` (must match the `kind:` in AlrtAlertsWidget.swift).
  static const iosWidgetName = 'AlrtAlertsWidget';

  /// Android provider class name for the Family widget.
  static const androidFamilyProviderName = 'AlrtFamilyWidgetProvider';

  /// iOS widget `kind` for the Family widget.
  static const iosFamilyWidgetName = 'AlrtFamilyWidget';

  /// Custom scheme used when the user taps the widget. Handled by the router.
  static const deeplinkScheme = 'alrtwidget';
}
