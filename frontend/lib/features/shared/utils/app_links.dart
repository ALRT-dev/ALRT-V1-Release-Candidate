import 'package:flutter/services.dart';

class AppLinks {
  static const String termsOfUse = 'https://www.safetyalrt.com/termsofuse';
  static const String privacyPolicy = 'https://www.safetyalrt.com/privacy';
  static const String disclaimer = 'https://www.safetyalrt.com/disclaimer';

  /// Where a PRODUCTION "Share ALRT" points. The site is responsible for
  /// routing on to whichever store fits the phone that opens it.
  ///
  /// KNOWN DEFECT (product owner, 2026-09-03): scanning this on a real
  /// phone opened a 404. It is deliberately left unchanged here rather than
  /// silently swapped for the site root or a store link: the replacement
  /// destination has to be independently confirmed to work first, and
  /// changing the website is out of scope for the app. Until then this is
  /// the one place to change when the confirmed destination is known.
  static const String shareAppProduction = 'https://www.safetyalrt.com/get';

  /// The same link without the scheme, for showing in the UI.
  static const String shareAppProductionDisplay = 'safetyalrt.com/get';

  /// Where "Share ALRT" sends people for a given build [flavor], or null
  /// when there must be no link at all.
  ///
  /// The `dev` flavour is the sideloaded TEST APK: it talks only to the
  /// isolated TEST backend, so a recipient must never be sent to the
  /// production website or a store listing they could install the real
  /// app from. A TEST APK is handed to a tester directly. Pure and
  /// unit-tested (share_app_link_test.dart) so the rule cannot drift back
  /// to a single hard-coded URL for every flavour.
  static String? shareAppLinkForFlavor(final String? flavor) {
    if (flavor == 'dev') return null;
    return shareAppProduction;
  }

  /// The live value for this build. Null on a TEST build.
  static String? get shareApp => shareAppLinkForFlavor(appFlavor);
}
