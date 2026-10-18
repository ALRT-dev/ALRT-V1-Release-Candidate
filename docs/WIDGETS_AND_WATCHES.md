# Widgets and watches: state and what is still needed

## Release integration update, 18 October 2026

The snapshot below predates integration into TEST. PR 33 brought the watch
sources and phone bridges to `test` at b5043c3. The release integration retains
the signed widget configuration from 5b44b0f and adds the unattached AlrtWatch
target using the supplied watch setup script. Runner has one widget dependency
and one embedded AlrtWidget.appex. Watch remains unembedded as described below.

The Apple Developer portal now has `com.safetyalrt.alrt.dev.AlrtWidget`, with
`group.com.safetyalrt.alrt.dev` assigned. Dev Runner already uses that group.
The Dev-only signing lane and export options cover both app and widget.
[Build 39085277408](https://github.com/ALRT-dev/ALRT-V1-Release-Candidate/actions/runs/39085277408)
at 5b44b0f passed signing and archive compilation. Its upload and processing
status must be checked separately. That build does not contain the newer watch
bridge integration. Installed widget, watch and purchase behaviour still need
device evidence.

Independent review found no blocker for integrating the phone build, but the
watch apps must remain undistributed until these issues are fixed and tested:

- Both watch screens ignore payload `updatedAtMillis`, allowing persisted
  "All clear" or alert data to appear current after disconnection. Add an
  explicit stale state and advancing age/time labels.
- The iPhone WatchConnectivity bridge drops a payload received before session
  activation. Retain the latest payload and replay it after activation succeeds.

The integration checks passed: three Ruby project tests with 70 assertions,
18 Flutter widget tests, and analysis of the changed Dart bridge/service. These
checks do not prove paired-device delivery or store availability.

## Earlier branch snapshot

Branch: `claude/widgets-and-watches` (not merged into the TestFlight branch).
Everything here is TEST only. Nothing was deployed or submitted.

## What is proven (CI evidence)

| Piece | Proof |
|---|---|
| Android home widgets (Nearby Alerts, Family) | Compiled and packaged in every Android Test Build |
| iPhone widget Swift sources | `iOS Widget Compile Check` (swiftc, simulator) passed |
| iPhone widget attached to Runner and embedded | Unsigned `AlrtWidget` target build passed; full app simulator smoke passed with it embedded |
| Wear OS app (`wear/`) | `Wear OS Compile Check` (`assembleDevDebug`) passed |
| Phone to Wear OS bridge (`MainActivity.kt`, `watch_sync.dart`) | Android Test Build on `claude/watch-apps` passed |
| Apple Watch app (`frontend/ios/AlrtWatch`) | Unsigned `AlrtWatch` build for the watch simulator passed |

Nothing above has run on a real phone or watch.

## What the watches do

Read only. They show the most serious nearby alert as a severity word plus a
colour (or "All clear"), the place, distance and age, the updated time, and the
standing emergency line. They send nothing: no SOS, no message, no location.
The phone sends the same JSON the home widget already draws from.

## What is NOT done and why

1. **iPhone widget in the signed TestFlight build.** The signed archive needs
   an App ID `com.safetyalrt.alrt.dev.AlrtWidget`, the App Group
   `group.com.safetyalrt.alrt.dev` on both App IDs, and a provisioning profile
   named `match AppStore com.safetyalrt.alrt.dev.AlrtWidget`, then
   `ExportOptionsCI-dev.plist` and the `ci_certs_dev` lane need that profile.
   Until then, merging the widget target would break the signed iOS build.
2. **Apple Watch inside the iPhone app.** `flutter build ios|ipa` passes
   `-sdk iphoneos`, which forces the watch target onto the iOS SDK and fails
   to compile. The release workflow must archive with
   `xcodebuild archive -destination generic/platform=iOS` for the watch app to
   embed. It also needs an App ID `...watchkitapp`, a profile, and an app icon.
3. **Wear OS in Google Play.** The watch app uses the phone's application id
   (required for the Data Layer). It must be uploaded to the same Play app on
   a Wear OS form-factor track, signed with the same key. Needs a launcher
   icon set and screenshots for the Wear listing.
4. **Real device test.** Pair a phone and a watch and confirm the glance
   updates after a hazard fetch.
