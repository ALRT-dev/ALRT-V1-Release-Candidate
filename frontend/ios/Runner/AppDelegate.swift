import Flutter
import UIKit
import GoogleMaps
import MSAL
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Injected at build time from the GOOGLE_MAPS_API_KEY build setting (ios/Flutter/Maps.xcconfig),
    // surfaced via the GMSApiKey entry in Info.plist. Never hardcoded / committed.
    var mapsConfigured = false
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !mapsApiKey.isEmpty, !mapsApiKey.hasPrefix("$(") {
      GMSServices.provideAPIKey(mapsApiKey)
      mapsConfigured = true
    } else {
      NSLog("[ALRT] Google Maps API key missing; maps are replaced by a notice. Set GOOGLE_MAPS_API_KEY in ios/Flutter/Maps.xcconfig")
    }
    GeneratedPluginRegistrant.register(with: self)
    // Creating a map view without a key throws and closes the app, so the
    // Dart side asks first (MapsAvailability) and shows a notice instead.
    if let registrar = self.registrar(forPlugin: "AlrtMapsAvailability") {
      let channel = FlutterMethodChannel(
        name: "com.safetyalrt.alrt/maps",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        if call.method == "isConfigured" {
          result(mapsConfigured)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    // Hands the nearby-alert glance to a paired Apple Watch (read-only).
    if let registrar = self.registrar(forPlugin: "AlrtWatchBridge") {
      let watchChannel = FlutterMethodChannel(
        name: "com.safetyalrt.alrt/watch",
        binaryMessenger: registrar.messenger()
      )
      WatchBridge.shared.start()
      watchChannel.setMethodCallHandler { call, result in
        if call.method == "push",
           let args = call.arguments as? [String: Any],
           let payload = args["payload"] as? String {
          result(WatchBridge.shared.push(payload))
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
  }
}


/// Sends the same JSON the home-screen widget draws from to a paired Apple
/// Watch through WatchConnectivity. A phone with no watch paired, or without
/// the watch app installed, just answers false.
final class WatchBridge: NSObject, WCSessionDelegate {
  static let shared = WatchBridge()

  func start() {
    guard WCSession.isSupported() else { return }
    WCSession.default.delegate = self
    WCSession.default.activate()
  }

  func push(_ payload: String) -> Bool {
    guard WCSession.isSupported() else { return false }
    let session = WCSession.default
    guard session.activationState == .activated,
          session.isPaired,
          session.isWatchAppInstalled else { return false }
    do {
      try session.updateApplicationContext([
        "payload": payload,
        "sentAt": Date().timeIntervalSince1970,
      ])
      return true
    } catch {
      return false
    }
  }

  func session(_ session: WCSession,
               activationDidCompleteWith activationState: WCSessionActivationState,
               error: Error?) {}
  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) { session.activate() }
}
