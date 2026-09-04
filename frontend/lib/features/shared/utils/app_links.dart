import 'package:flutter/services.dart';

class AppLinks {
  static const String termsOfUse = 'https://www.safetyalrt.com/termsofuse';
  static const String privacyPolicy = 'https://www.safetyalrt.com/privacy';
  static const String disclaimer = 'https://www.safetyalrt.com/disclaimer';

  /// The public ALRT website. This is where a production "Share ALRT"
  /// points; the site is responsible for routing on to whichever store
  /// fits the phone that opens it.
  ///
  /// The old `/get` path was removed: scanning it opened a 404 on a real
  /// phone (confirmed 2026-09-03), and no code in the app may link to it
  /// again. Changing the website itself is out of scope for the app.
  static const String website = 'https://www.safetyalrt.com';

  /// The same link without the scheme, for showing in the UI.
  static const String websiteDisplay = 'safetyalrt.com';

  /// Where "Share ALRT" sends people for a given build [flavor], or null
  /// when there must be no link at all.
  ///
  /// The `dev` flavour is the sideloaded TEST APK: it talks only to the
  /// isolated TEST backend, so a recipient must never be sent to the
  /// production website or a store listing they could install the real
  /// app from. Pure and unit-tested (share_app_link_test.dart) so the
  /// rule cannot drift back to a single hard-coded URL.
  static String? shareAppLinkForFlavor(final String? flavor) {
    if (flavor == 'dev') return null;
    return website;
  }

  /// The live value for this build. Null on a TEST build.
  static String? get shareApp => shareAppLinkForFlavor(appFlavor);
}
