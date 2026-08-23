import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/family/models/family_models.dart';
import 'package:hazard_app/features/family/providers/viewed_journey_provider.dart';
import 'package:hazard_app/features/family/views/widgets/family_colors.dart';
import 'package:hazard_app/features/shared/extensions/num_sized_box_extension.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

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

    return Scaffold(
      backgroundColor: FamilyColors.v31Page,
      body: Column(
        children: [
          _headerBuilder(state.journey),
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.journey != null
                ? _journeyBuilder(state.journey!)
                : _errorBuilder(state.error),
          ),
        ],
      ),
    );
  }

  Widget _headerBuilder(final FamilyJourney? journey) {
    final name = journey?.memberName ?? 'Family journey';
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.35, -1),
          end: Alignment(0.35, 1),
          colors: [
            FamilyColors.v31HeaderTop,
            FamilyColors.v31HeaderMid,
            FamilyColors.v31HeaderDeep,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.spMin, 8.spMin, 16.spMin, 22.spMin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 30.spMin,
                  height: 30.spMin,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15.spMin,
                    color: Colors.white,
                  ),
                ),
              ),
              14.hSizedBox,
              Text(
                'JOURNEY SHARED WITH YOU',
                style: TextStyle(
                  fontSize: 11.spMin,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              4.hSizedBox,
              Text(
                name,
                style: TextStyle(
                  fontSize: 22.spMin,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _journeyBuilder(final FamilyJourney journey) {
    final isActive = journey.isActive;
    final position = journey.latitude != null && journey.longitude != null
        ? LatLng(journey.latitude!, journey.longitude!)
        : null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.spMin, 16.spMin, 16.spMin, 28.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (position != null) ...[
            _mapBuilder(position, isLive: isActive && journey.isLive),
            14.hSizedBox,
          ],
          _statusCardBuilder(journey, isActive),
          14.hSizedBox,
          _noteBuilder(
            isActive
                ? 'You can see this because ${journey.memberName} chose to '
                      'share it with you. When it ends, their position is '
                      'deleted — only the time it ran stays visible.'
                : 'This journey has ended. Its position data was deleted '
                      'when it stopped; only the time it ran remains.',
          ),
        ],
      ),
    );
  }

  Widget _mapBuilder(final LatLng position, {required final bool isLive}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.spMin),
      child: SizedBox(
        height: 220.spMin,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: position, zoom: 14.5),
          onMapCreated: (controller) => _mapController = controller,
          markers: {
            Marker(markerId: const MarkerId('journey'), position: position),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          // Lite mode is a static image: fine when position updates are
          // occasional (snap points), not useful while following someone
          // moving live.
          liteModeEnabled: !isLive,
        ),
      ),
    );
  }

  Widget _statusCardBuilder(final FamilyJourney journey, final bool isActive) {
    final minutesLeft = journey.remaining.inMinutes;
    return _cardBuilder(
      label: isActive ? 'Sharing now' : 'Journey ended',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? LucideIcons.navigation : LucideIcons.checkCheck,
                size: 18.spMin,
                color: isActive
                    ? FamilyColors.v31Indigo
                    : AppColors.mediumGrey,
              ),
              8.wSizedBox,
              Expanded(
                child: Text(
                  isActive
                      ? (minutesLeft < 1
                            ? 'Stopping now'
                            : 'Stops in $minutesLeft min')
                      : journey.endedAt != null
                      ? 'Ended ${timeago.format(journey.endedAt!)}'
                      : 'No longer active',
                  style: TextStyle(
                    fontSize: 18.spMin,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
              ),
              if (isActive && journey.isLive) _liveChipBuilder(),
            ],
          ),
          10.hSizedBox,
          Text(
            'Shared for up to ${journey.grantedMinutes} min in total.',
            style: TextStyle(fontSize: 12.5.spMin, color: AppColors.mediumGrey),
          ),
          if (isActive) ...[
            4.hSizedBox,
            Text(
              journey.isLive
                  ? 'Live location — updates as they move.'
                  : 'Snap points only — departure, roughly every 10 '
                        'minutes, and arrival.',
              style: TextStyle(
                fontSize: 12.5.spMin,
                fontWeight: FontWeight.w600,
                color: FamilyColors.v31Indigo,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _liveChipBuilder() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.spMin, vertical: 4.spMin),
      decoration: BoxDecoration(
        color: FamilyColors.sosRedLight,
        borderRadius: BorderRadius.circular(20.spMin),
      ),
      child: Text(
        'LIVE',
        style: TextStyle(
          fontSize: 10.spMin,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: FamilyColors.sosRed,
        ),
      ),
    );
  }

  Widget _cardBuilder({required final String label, required final Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        boxShadow: const [
          BoxShadow(
            color: FamilyColors.v31CardShadow,
            blurRadius: 10.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(15.spMin, 14.spMin, 15.spMin, 14.spMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12.spMin),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10.spMin,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: FamilyColors.v31Label,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _noteBuilder(final String text) {
    return Container(
      decoration: BoxDecoration(
        color: FamilyColors.v31NoteBackground,
        borderRadius: BorderRadius.circular(14.spMin),
        border: Border.all(color: FamilyColors.v31NoteBorder, width: 1.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 11.spMin),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.spMin,
          height: 1.4,
          color: FamilyColors.v31NoteInk,
        ),
      ),
    );
  }

  /// The backend is the authority on who may see a journey: a non-recipient,
  /// an unrelated circle member, or a bad/expired id all land here with
  /// whatever message it sent (e.g. "You weren't shared this journey"),
  /// never a raw exception.
  Widget _errorBuilder(final dynamic error) {
    final message = error?.message as String? ??
        'This journey isn\'t available.';
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
