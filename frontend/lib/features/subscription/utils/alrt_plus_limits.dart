/// The ALRT+ allowances the app enforces and explains. They mirror the
/// backend's `MAX_OWNED_CIRCLES` and `MAX_SEATS_TOTAL` (family.service.ts)
/// and `FREE_SAVED_LOCATIONS_LIMIT` (location_subscription.service.ts):
/// one place in the app, so every screen quotes the same numbers.
library;

export 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart'
    show kFreeSavedLocationsLimit;

/// Circles one ALRT+ host can own.
const kAlrtPlusMaxOwnedCircles = 4;

/// Seats one ALRT+ plan covers across the host's circles (guests and the
/// host use none).
const kAlrtPlusSeats = 8;
