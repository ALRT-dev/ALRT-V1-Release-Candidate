# Android API 36 release checks

Checked 18 October 2026 as part of the connected TEST release plan.

## Configuration

Google Play now requires new phone apps and updates to target API 36. The previous
explicit API 35 target would block submission unless a store extension had been
granted. No extension is assumed. The phone target is now explicitly 36 in the
shared Gradle configuration, covering both dev and prod flavours.

Flutter 3.38.10 supplies compileSdk 36. The existing Android Gradle plugin 8.9.1
meets Android's documented minimum of 8.9.0-rc01. Neither the minimum supported
Android version nor signing, backend or billing settings is changed here.

References:

- [Google Play target API requirement](https://developer.android.com/google/play/requirements/target-sdk)
- [Android 16 SDK setup](https://developer.android.com/about/versions/16/setup-sdk)
- [Android 16 behaviour changes](https://developer.android.com/about/versions/16/behavior-changes-16)

## Evidence and remaining checks

| Area | Evidence | Required before public release |
|---|---|---|
| Target SDK | Regression check failed on 35, then passed on 36 | Confirm the final signed APK/AAB manifest reports 36 |
| System bars | No edge-to-edge opt-out found in native resources | Check top/bottom controls, keyboard and sheets on Android 16 |
| Back navigation | Native activity uses FlutterActivity; no custom onBackPressed override. Dart uses PopScope | Check back gesture through map, alert detail, report forms, Family and dialogs |
| Tablet/foldable layout | Bootstrap requests portrait; Android 16 ignores this on displays at least 600dp wide | Check rotation and split screen for clipping, lost form state and inaccessible actions |
| Permissions and background | Existing permissions and push/widget flows are retained | Check notification/location permission refusal, background push, widget refresh and widget taps |
| Billing | Virtual Test Store APK does not exercise Google Play billing | Install the signed internal-track build, then verify sandbox purchase, restore and expiry |

This configuration change and a successful build do not establish Android 16
device compatibility. No Play Store publication is performed by these checks.

## Public build configuration repair

The root Android release and iOS TestFlight workflows wrote `.env` but omitted
`--dart-define-from-file=.env`. The app now reads compile-time values, so those
workflows would produce empty Dart sign-in and RevenueCat keys even when GitHub
secrets were configured. Both build commands now pass the file. Two regression
checks reproduced the omission before the fix. This does not verify that the
production secrets, signing identities, Maps restrictions or store products
are configured, and neither public workflow was dispatched during this repair.
