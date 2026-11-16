/// The coarse place Ask ALRT is told about (owner decision D1, 16 Nov 2026).
///
/// Only a country code and, inside Australia, a state code ever leave the
/// phone: never coordinates. The state is worked out on the phone from the
/// user's location with approximate borders. Near a border it can be wrong,
/// which is acceptable because a place named in the question always wins
/// and Ask ALRT says which place it answered for.
abstract final class CoarsePlace {
  /// Australian state or territory code for a point, or null outside Australia.
  static String? auState(final double lat, final double lng) {
    if (lat > -9 || lat < -44.5 || lng < 112 || lng > 154.5) return null;
    if (lat < -39.2) return 'TAS';
    if (lat > -35.95 && lat < -35.1 && lng > 148.75 && lng < 149.4) return 'ACT';
    if (lng < 129) return 'WA';
    if (lng < 138) return lat > -26 ? 'NT' : 'SA';
    if (lng < 141) return lat > -26 ? 'QLD' : 'SA';
    if (lat > -29) return 'QLD';
    // The Murray River, roughly: (-34.0, 141.0) to (-36.0, 148.2), then the
    // line to Cape Howe (-37.5, 150.0).
    final murray = lng <= 148.2
        ? -34.0 - (lng - 141.0) * (2.0 / 7.2)
        : -36.0 - (lng - 148.2) * (1.5 / 1.8);
    return lat < murray ? 'VIC' : 'NSW';
  }

  /// Request fields for Ask ALRT: {'country': 'AU', 'state': 'WA'}.
  /// [deviceCountry] is the SIM or device region; a real device location
  /// inside Australia overrides it.
  static Map<String, String> fields({
    final String? deviceCountry,
    final double? lat,
    final double? lng,
    final bool usingDeviceLocation = false,
  }) {
    final state = usingDeviceLocation && lat != null && lng != null
        ? auState(lat, lng)
        : null;
    final country = state != null ? 'AU' : deviceCountry?.toUpperCase();
    return {
      if (country != null && RegExp(r'^[A-Z]{2}$').hasMatch(country))
        'country': country,
      if (state != null) 'state': state,
    };
  }
}
