import Flutter
import UIKit
import GoogleMaps
import MSAL

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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
  }
}
