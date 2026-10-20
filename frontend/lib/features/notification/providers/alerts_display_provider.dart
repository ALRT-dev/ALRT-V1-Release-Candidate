import 'package:flutter_riverpod/legacy.dart';

/// Shared toggle for the Alerts feed (Notifications screen).
///
/// When `true`, [MapAreaAlertsList] narrows its list to only alerts whose
/// centre-point falls inside one of the user's saved-location subscription
/// bounding boxes.  When `false` (default) every map-visible alert is shown.
///
/// Written by [NotificationsAppBar]'s pill toggle; read by [MapAreaAlertsList].
final providerOfShowSavedLocationsOnly = StateProvider<bool>((ref) => false);
