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
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    } else {
      NSLog("[ALRT] Google Maps API key missing — set GOOGLE_MAPS_API_KEY in ios/Flutter/Maps.xcconfig")
    }
    GeneratedPluginRegistrant.register(with: self)
    // Apple Watch companion. Registered at launch so a watch message that
    // wakes the app in the background is answered without any screen.
    if let messenger = self.registrar(forPlugin: "WatchSessionBridge")?.messenger() {
      WatchSessionBridge.shared.attach(messenger: messenger)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
  }
}

/// iPhone half of the ALRT Apple Watch companion (Dart half:
/// lib/features/wearable/watch_bridge.dart).
///
/// The phone holds the session. The watch is sent circle status as the
/// WatchConnectivity application context (latest state wins, delivered in
/// the background) and asks the phone to act with sendMessage; each ask is
/// handed to Dart, which posts it with the phone's own login and replies
/// with the server's answer. Nothing here talks to the backend.
final class WatchSessionBridge: NSObject, WCSessionDelegate {
  static let shared = WatchSessionBridge()

  private var channel: FlutterMethodChannel?
  /// Dart registers its handler a moment after launch; asks that arrive
  /// first wait here (and fail honestly if Dart never comes up).
  private var dartReady = false
  private var waiting: [(message: [String: Any], reply: ([String: Any]) -> Void)] = []
  private var stateRequested = false
  /// The newest status, kept until the session can carry it.
  private var latestContext: [String: Any]?

  func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "com.safetyalrt.alrt/watch", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "updateContext":
        if let context = call.arguments as? [String: Any] { self.send(context: context) }
        result(nil)
      case "ready":
        self.markDartReady()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
    guard WCSession.isSupported() else { return }
    WCSession.default.delegate = self
    WCSession.default.activate()
  }

  // MARK: phone -> watch

  private func send(context: [String: Any]) {
    latestContext = context
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    guard session.activationState == .activated, session.isPaired, session.isWatchAppInstalled else { return }
    do {
      try session.updateApplicationContext(context)
    } catch {
      NSLog("[ALRT] Watch context not sent: \(error.localizedDescription)")
    }
  }

  // MARK: watch -> phone

  private func markDartReady() {
    dartReady = true
    let queued = waiting
    waiting.removeAll()
    for item in queued { forward(item.message, reply: item.reply) }
    if stateRequested {
      stateRequested = false
      channel?.invokeMethod("requestState", arguments: nil)
    }
  }

  private func handle(_ message: [String: Any], reply: @escaping ([String: Any]) -> Void) {
    if message["action"] as? String == "requestState" {
      if let context = latestContext { send(context: context) }
      if dartReady {
        channel?.invokeMethod("requestState", arguments: nil)
      } else {
        stateRequested = true
      }
      reply(["ok": true])
      return
    }
    if dartReady {
      forward(message, reply: reply)
      return
    }
    waiting.append((message, reply))
    // Never leave the watch spinning: if Dart is not up in 20 s, say so.
    DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
      guard let self = self, !self.dartReady, !self.waiting.isEmpty else { return }
      let stale = self.waiting
      self.waiting.removeAll()
      for item in stale {
        item.reply(["ok": false, "title": "Not sent", "detail": "Open ALRT on your iPhone, then try again."])
      }
    }
  }

  private func forward(_ message: [String: Any], reply: @escaping ([String: Any]) -> Void) {
    guard let channel = channel else {
      reply(["ok": false, "title": "Not sent", "detail": "Open ALRT on your iPhone, then try again."])
      return
    }
    channel.invokeMethod("action", arguments: message) { result in
      if let answer = result as? [String: Any] {
        reply(answer)
      } else {
        reply(["ok": false, "title": "Not sent", "detail": "Something went wrong. Try again or use your iPhone."])
      }
    }
  }

  // MARK: WCSessionDelegate

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    DispatchQueue.main.async {
      if activationState == .activated, let context = self.latestContext { self.send(context: context) }
    }
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
    DispatchQueue.main.async { self.handle(message, reply: replyHandler) }
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    DispatchQueue.main.async { self.handle(message, reply: { _ in }) }
  }

  func sessionWatchStateDidChange(_ session: WCSession) {
    DispatchQueue.main.async {
      if let context = self.latestContext { self.send(context: context) }
    }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    // The person switched watches: reconnect to the new one.
    WCSession.default.activate()
  }
}
