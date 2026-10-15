# ALRT iPhone widgets

Runner.xcodeproj now contains the AlrtWidget extension target. Runner embeds it, and the target compiles both existing widgets. Do not create a second extension in Xcode.

## Local configuration

From frontend/ios, run `bundle exec ruby scripts/configure_widgets.rb` if the project target needs to be repaired. This uses Xcodeproj, is repeatable, and does not contact Apple. The source configuration tests are in scripts/test_configure_widgets.rb (Ruby with xcodeproj and minitest).

| Configuration | Extension bundle ID | App Group |
| --- | --- | --- |
| dev | com.safetyalrt.alrt.dev.AlrtWidget | group.com.safetyalrt.alrt.dev |
| prod | com.safetyalrt.alrt.AlrtWidget | group.com.safetyalrt.alrt |

The deployment target is iOS 15.6, matching Runner. Widget version and build number come from Flutter's generated settings, matching the containing app. The extension does not link Flutter or its CocoaPods dependencies.

## Signing and device checks

Each extension needs its own Apple App ID and provisioning profile. The App Group must be enabled for both its extension and its containing app. Dev and production stay separate. Configuring the local target does not register App IDs or prove signing is ready.

The TEST simulator workflow checks that the dev extension is embedded and the host app stays running. A signed archive and an installed TestFlight build are still required to verify the profiles, shared data, widget gallery and taps on a device.

On the device, add Nearby Alerts and Family status from the home screen widget gallery. Check refresh, alert severity, family status, opening the correct screen, logout and stale data. No cloud build alone proves these interactions.

## Data contract

- Alert JSON key: alrt_widget_payload.
- Family JSON key: alrt_family_widget_payload.
- Widget kinds: AlrtAlertsWidget and AlrtFamilyWidget.
- App Group comes from the dev/prod flavour on both Dart and Swift sides.
- Taps use alrtwidget://open?screen=alerts or screen=family.
