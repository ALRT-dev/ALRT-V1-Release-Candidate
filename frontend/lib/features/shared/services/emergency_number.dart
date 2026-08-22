import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hazard_app/features/shared/services/sim_country.dart';

/// The local emergency number, resolved per user (product rules §16).
///
/// ALRT is a global app: copy never hard-codes 000. The number is resolved
/// in this order, the first hit winning:
///   SIM country (telephony) > device region > locale-derived country > 112.
///
/// 112 is the GSM global fallback: it reaches emergency services across the
/// EU and, on most GSM networks worldwide, is redirected to the local
/// service even where it is not the official number. That makes it the
/// safest thing to dial when we genuinely cannot tell where someone is.
///
/// This mirrors `emergencyLogic.ts` in the Ask ALRT backend so the number a
/// user sees in the app and the number the assistant quotes are the same.
/// The table is a shipped default and is meant to move to Remote Config so
/// numbers can be corrected without a release.
class EmergencyNumber {
  const EmergencyNumber._();

  static const gsmGlobalFallback = '112';

  /// Seeded ISO country -> emergency number. Deliberately conservative:
  /// a country is listed only where the number is unambiguous, because a
  /// wrong number here is worse than the 112 fallback. Countries without a
  /// single unified number (for example Japan, where 110 is police and 119
  /// is fire and ambulance) carry the number for reaching police, which is
  /// the right first call when a person is in danger.
  static const numbers = <String, String>{
    // Oceania
    'AU': '000',
    'NZ': '111',
    // British Isles
    'GB': '999',
    'IE': '112',
    // North America
    'US': '911',
    'CA': '911',
    'MX': '911',
    // EU and wider Europe: 112 is the official single number
    'AT': '112', 'BE': '112', 'BG': '112', 'HR': '112', 'CY': '112',
    'CZ': '112', 'DK': '112', 'EE': '112', 'FI': '112', 'FR': '112',
    'DE': '112', 'GR': '112', 'HU': '112', 'IS': '112', 'IT': '112',
    'LV': '112', 'LI': '112', 'LT': '112', 'LU': '112', 'MT': '112',
    'NL': '112', 'NO': '112', 'PL': '112', 'PT': '112', 'RO': '112',
    'RS': '112', 'SK': '112', 'SI': '112', 'ES': '112', 'SE': '112',
    'CH': '112', 'TR': '112', 'UA': '112',
    // Asia
    'CN': '110',
    'HK': '999',
    'IN': '112',
    'ID': '112',
    'JP': '110',
    'KR': '112',
    'MY': '999',
    'PH': '911',
    'SG': '999',
    'TW': '110',
    'TH': '191',
    // Middle East and Africa
    'AE': '999',
    'QA': '999',
    'SA': '911',
    'ZA': '112',
    'KE': '999',
  };

  /// Parses the region subtag of a BCP-47 locale ("en-AU" -> "AU").
  static String? countryFromLocale(final String? locale) {
    if (locale == null || locale.isEmpty) return null;
    final parts = locale.replaceAll('_', '-').split('-');
    for (final part in parts) {
      if (part.length == 2 &&
          part == part.toUpperCase() &&
          RegExp(r'^[A-Za-z]{2}$').hasMatch(part)) {
        return part;
      }
    }
    return null;
  }

  /// Always returns something dialable; never null, never empty.
  static String resolve({
    final String? simCountry,
    final String? deviceRegion,
    final String? locale,
    final Map<String, String> table = numbers,
  }) {
    final candidates = <String?>[
      simCountry,
      deviceRegion,
      countryFromLocale(locale),
    ];
    for (final iso in candidates) {
      if (iso == null || iso.isEmpty) continue;
      final match = table[iso.toUpperCase()];
      if (match != null) return match;
    }
    return gsmGlobalFallback;
  }
}

/// The emergency number for this device.
///
/// The full §16 chain: SIM country, then device region, then locale, then
/// the GSM global 112. SIM country is read once at startup by [SimCountry]
/// and is null on iOS, where the platform no longer exposes it, so those
/// devices resolve from region exactly as before.
final providerOfEmergencyNumber = Provider<String>((ref) {
  final dispatcher = PlatformDispatcher.instance;
  final primary = dispatcher.locale;
  return EmergencyNumber.resolve(
    simCountry: SimCountry.value,
    deviceRegion: primary.countryCode,
    locale: primary.toLanguageTag(),
  );
});
