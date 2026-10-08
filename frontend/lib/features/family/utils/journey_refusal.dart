import 'package:hazard_app/features/shared/models/error_model.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';

/// What a traveller is told when ALRT refuses a live journey because the
/// group's host chose periodic updates only.
const kPeriodicOnlyRefusalMessage =
    "This group uses periodic updates only, so Live location isn't "
    'available here. Start the journey with periodic updates instead.';

/// Whether [error], answering a LIVE journey start, is the backend's
/// "this group is periodic updates only" refusal (409). An access refusal
/// (it carries a known code) is not: that one has its own sheet.
bool isPeriodicOnlyRefusal(final AppError error) =>
    error.code == '409' && AccessRefusal.fromError(error) == null;
