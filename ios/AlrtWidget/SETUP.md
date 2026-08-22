# iOS — adding the AlrtWidget extension in Xcode

The Swift sources, `Info.plist`, and `AlrtWidget.entitlements` are already in
`ios/AlrtWidget/`. They only need to be attached to a WidgetKit target — that
step must be done in Xcode (it edits `project.pbxproj`, which should not be
hand-written).

## Steps

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **File ▸ New ▸ Target… ▸ Widget Extension.**
   - Product name: **AlrtWidget**
   - Uncheck "Include Configuration App Intent" and "Include Live Activity".
   - Embed in: **Runner**. When asked to activate the scheme, click Activate.
3. Xcode generates a starter `AlrtWidget.swift` + `Info.plist` in a new group.
   **Delete** the generated `.swift` and `Info.plist` (move to trash), then in
   the Project Navigator **Add Files to "Runner"…** and add the four files that
   already exist in `ios/AlrtWidget/`:
   - `AlrtAlertsWidget.swift`
   - `AlrtFamilyWidget.swift`
   - `AlrtWidgetBundle.swift`  (declares both widgets — holds the `@main`)
   - `Info.plist`  (set it as the target's Info.plist under Build Settings ▸
     Packaging ▸ Info.plist File if not already)
   - `AlrtWidget.entitlements`
   Make sure each is a member of the **AlrtWidget** target only (check the File
   Inspector ▸ Target Membership).
4. **App Group** — both targets must share it:
   - Select the **Runner** target ▸ Signing & Capabilities ▸ + Capability ▸
     **App Groups** ▸ add `group.com.safetyalrt.alrt`.
   - Select the **AlrtWidget** target ▸ same steps ▸ add the same group.
   (`Runner.entitlements` already lists the group; `AlrtWidget.entitlements`
   too. Set AlrtWidget ▸ Build Settings ▸ Code Signing Entitlements to
   `AlrtWidget/AlrtWidget.entitlements`.)
5. Set the AlrtWidget target's **Deployment Target** to match Runner and pick
   the same Team for signing.
6. `cd ios && pod install` (the `home_widget` pod is pulled in once
   `flutter pub get` has run at the project root).
7. Build & run on a device/simulator, then long-press the home screen ▸ + ▸
   search "Nearby Alerts" to add the widget.

## Notes
- The widget reads from `UserDefaults(suiteName: "group.com.safetyalrt.alrt")`,
  key `alrt_widget_payload`. The Flutter side writes it via `HomeWidgetService`.
- If you ship a separate **dev** flavor (`com.safetyalrt.alrt.dev`) and want the
  widget there too, create a second App Group (e.g.
  `group.com.safetyalrt.alrt.dev`) and switch `AlrtWidgetConfig.appGroup` +
  `HomeWidgetKeys.appGroupId` per build configuration.
