import SwiftUI
import UserNotifications
import WatchKit

/// ALRT for Apple Watch: a companion to the ALRT iPhone app.
///
/// Deliberately small. It shows each family circle's state, checks in to a
/// named circle with one tap, and sends an SOS after a 3-second hold that
/// first shows who it goes to. The iPhone holds the session and does every
/// network call; the watch never signs in and never sends a location.
@main
struct AlrtWatchApp: App {
  @WKApplicationDelegateAdaptor(WatchAppDelegate.self) private var appDelegate
  @StateObject private var store = WatchStore.shared

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(store)
    }
  }
}

/// Notifications on the wrist. With the watch app installed, check-in
/// requests and SOS alerts that carry an ALRT category open straight to
/// the circle they are about, where the person sees the circle's name
/// before anything is sent. A notification never sends anything by itself.
final class WatchAppDelegate: NSObject, WKApplicationDelegate, UNUserNotificationCenterDelegate {
  static let openAction = "alrt_open_circle"

  func applicationDidFinishLaunching() {
    let center = UNUserNotificationCenter.current()
    center.delegate = self
    let open = UNNotificationAction(
      identifier: Self.openAction,
      title: "Open circle",
      options: [.foreground]
    )
    center.setNotificationCategories([
      UNNotificationCategory(identifier: "ALRT_CHECKIN_REQUEST", actions: [open], intentIdentifiers: [], options: []),
      UNNotificationCategory(identifier: "ALRT_SOS_RECEIVED", actions: [open], intentIdentifiers: [], options: []),
    ])
    WatchStore.shared.start()
  }

  func applicationDidBecomeActive() {
    WatchStore.shared.requestFreshState()
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound])
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let circleId = Self.circleId(from: response.notification.request.content.userInfo)
    DispatchQueue.main.async {
      if let circleId { WatchStore.shared.open(circleId: circleId) }
      completionHandler()
    }
  }

  /// The server puts the event as JSON in the "payload" data key.
  static func circleId(from userInfo: [AnyHashable: Any]) -> String? {
    if let id = userInfo["circleId"] as? String { return id }
    guard let raw = userInfo["payload"] as? String,
          let data = raw.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }
    return json["circleId"] as? String
  }
}
