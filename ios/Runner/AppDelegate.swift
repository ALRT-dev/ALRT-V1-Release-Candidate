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
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !mapsApiKey.isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    } else {
      NSLog("[ALRT] Google Maps API key missing — set GOOGLE_MAPS_API_KEY in ios/Flutter/Maps.xcconfig")
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
  }
}
