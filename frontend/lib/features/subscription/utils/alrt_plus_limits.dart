/// The personal ALRT Free allowance the app explains (V1 access model,
/// master spec 28 Sep 2026). The live numbers come from the backend's
/// GET /api/access; there are no seats and no group-count limit.
library;

export 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart'
    show kFreeSavedLocationsLimit;
