import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/viewed_journey_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_app_bar.dart';
import 'package:hazard_app/features/family/views/widgets/family_board_widgets.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:hazard_app/features/map/utils/maps_availability.dart';

class SharedJourneyScreenArgs {
  const SharedJourneyScreenArgs({required this.journeyId});

  final String journeyId;
}

/// The recipient's view of a journey shared with them — what a
/// "X is sharing a journey" notification deep-links into.
///
/// This is read-only: only the traveller can extend or stop a journey, and
/// only from their own device. The backend is the sole authority on who may
/// see a given journey ([ViewedJourneyNotifier] simply surfaces whatever it
/// returns, including its 403/404 for anyone not picked).
///
/// FamilyJourney only ever stores the traveller's current position, not an
/// origin, destination or route, so this screen shows what the data model
/// actually has — who's sharing, whether it's still running, roughly how
/// long for, and their last known point while live location is on — rather
/// than inventing a route or an ETA nothing here can honestly compute.
class SharedJourneyScreen extends ConsumerStatefulWidget {
  const SharedJourneyScreen({super.key, required this.args});

  static const route = '/shared-journey';

  final SharedJourneyScreenArgs args;

  @override
  ConsumerState<SharedJourneyScreen> createState() =>
      _SharedJourneyScreenState();
}

class _SharedJourneyScreenState extends ConsumerState<SharedJourneyScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(providerOfViewedJourney.notifier)
          .load(widget.args.journeyId),
    );
  }

  @override
  void dispose() {
    ref.read(providerOfViewedJourney.notifier).stopWatching();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerOfViewedJourney);

    // The SharedJourney board: white header, the indigo card naming who
    // is sharing and how, the map, and one line on what you can see.
    return Scaffold(
      backgroundColor: kFamilyBoardPage,
      appBar: const FamilyWhiteAppBar(title: 'Family journey'),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.journey != null
          ? _journeyBuilder(state.journey!)
          : _errorBuilder(state.error),
    );
  }

  Widget _journeyBuilder(final FamilyJourney journey) {
    final isActive = journey.isActive;
    final position = journey.latitude != null && journey.longitude != null
        ? LatLng(journey.latitude!, journey.longitude!)
        : null;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.spMin, 14.spMin, 16.spMin, 120.spMin),
      children: [
        _heroBuilder(journey, isActive),
        14.hSizedBox,
        if (isActive) ...[
          _mapBuilder(position, isLive: journey.isLive),
          14.hSizedBox,
        ],
        FamilyBoardMuted(
          isActive
              ? 'You see when they leave and arrive. Nobody is tracked '
                    'after the journey ends.'
              : 'This journey has ended. Its position was deleted when it '
                    'stopped; only the time it ran remains.',
        ),
      ],
    );
  }

  /// "JOURNEY SHARED WITH YOU / Alex / Sharing now · an update about every
  /// 10 minutes · 30 min left".
  Widget _heroBuilder(final FamilyJourney journey, final bool isActive) {
    final minutesLeft = journey.remaining.inMinutes;
    final line = isActive
        ? [
            journey.isLive
                ? 'Sharing now · live'
                : 'Sharing now · an update about every 10 minutes',
            minutesLeft < 1 ? 'stopping now' : '$minutesLeft min left',
          ].join(' · ')
        : journey.endedAt != null
        ? 'Journey ended ${timeago.format(journey.endedAt!)}'
        : 'Journey ended';
    return Container(
      padding: EdgeInsets.all(18.spMin),
      decoration: BoxDecoration(
        gradient: FamilyColors.headerGradient,
        borderRadius: BorderRadius.circular(18.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JOURNEY SHARED WITH YOU',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            journey.memberName,
            style: TextStyle(
              fontSize: 26.spMin,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          4.hSizedBox,
          Text(
            line,
            style: TextStyle(
              fontSize: 13.spMin,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapBuilder(final LatLng? position, {required final bool isLive}) {
    final refresh = isLive ? 'refreshes every 45 s' : 'refreshes every 10 min';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.spMin),
      child: SizedBox(
        height: 200.spMin,
        child: Stack(
          children: [
            Positioned.fill(
              child: position == null
                  ? const ColoredBox(color: Color(0xFFE8EAED))
                  : MapsAvailability.available
                  ? GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: position,
                        zoom: 14.5,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      markers: {
                        Marker(
                          markerId: const MarkerId('journey'),
                          position: position,
                        ),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      // Lite mode is a static image: fine for periodic
                      // updates, not for following someone live.
                      liteModeEnabled: !isLive,
                    )
                  : const MapUnavailable(),
            ),
            Positioned(
              left: 10.spMin,
              bottom: 8.spMin,
              child: Text(
                position == null
                    ? 'No update yet · $refresh'
                    : 'Last update · $refresh',
                style: TextStyle(
                  fontSize: 12.spMin,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The backend is the authority on who may see a journey: a non-recipient,
  /// an unrelated circle member, or a bad/expired id all land here with
  /// whatever message it sent (e.g. "You weren't shared this journey"),
  /// never a raw exception.
  Widget _errorBuilder(final dynamic error) {
    final message =
        error?.message as String? ?? 'This journey isn\'t available.';
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.spMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.circleAlert,
              size: 32.spMin,
              color: AppColors.mediumGrey,
            ),
            12.hSizedBox,
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.spMin, color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    );
  }
}
