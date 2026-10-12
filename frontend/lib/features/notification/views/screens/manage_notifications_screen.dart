import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/models/alrt_location_bounds_model.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/views/screens/select_location_screen.dart';
import 'package:hazard_app/features/notification/views/widgets/all_location_subscriptions_list_item.dart';
import 'package:hazard_app/features/notification/views/widgets/manage_push_notifications_list.dart';
import 'package:hazard_app/features/notification/views/widgets/notification_status_card.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';
import 'package:hazard_app/features/subscription/utils/saved_location_gate.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_upsell_sheet.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ManageNotificationsScreenArgs {
  const ManageNotificationsScreenArgs({
    this.initialTab = 0,
  });

  /// Kept for the existing deep links: 0 opens at the top, 1 scrolls to
  /// the SAVED PLACES card (the old Locations tab). There are no tabs any
  /// more; the screen is one scroll.
  final int initialTab;
}

/// A square around ([latitude], [longitude]) whose corner is [radiusKm]
/// from the centre, the same shape the own-location follow uses, for a
/// picked place that carries no viewport of its own.
AlrtLocationBounds boundsAround({
  required final double latitude,
  required final double longitude,
  required final double radiusKm,
}) {
  const earthRadiusKm = 6371.0;
  final edgeRadiusKm = radiusKm / sqrt(2);
  final latRad = (latitude * pi) / 180;
  final angularDistance = edgeRadiusKm / earthRadiusKm;
  final latDelta = (angularDistance * 180) / pi;
  final lngDelta = (angularDistance * 180) / pi / cos(latRad);
  return AlrtLocationBounds(
    northeastLat: latitude + latDelta,
    northeastLng: longitude + lngDelta,
    southwestLat: latitude - latDelta,
    southwestLng: longitude - lngDelta,
  );
}

/// Notifications (board 12 Oct 2026): one scroll, no tabs. LEVEL, TYPES
/// and CATEGORIES come from [ManagePushNotificationsList]; SAVED PLACES
/// lists the places followed for alerts with the add-place control and
/// the free-allowance gate; the device status sits at the top and the
/// test push at the bottom.
class ManageNotificationsScreen extends ConsumerStatefulWidget {
  const ManageNotificationsScreen({
    super.key,
    required this.args,
  });

  /// The arguments for the screen.
  final ManageNotificationsScreenArgs args;

  static const route = '/manage-notifications';

  static const filtersKey = 'ManagePushNotifications_filtersKey';

  /// The SAVED PLACES card, for tests and the deep-link scroll.
  static const savedPlacesKey = Key('notifications-saved-places');

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState
    extends ConsumerState<ManageNotificationsScreen> {
  static const _page = Color(0xFFF5F5F7);
  static const _sectionLabel = Color(0xFFB84500);
  static const _muted = Color(0xFF5C5C66);

  final _scrollController = ScrollController();
  final _savedPlacesKey = GlobalKey();

  /// Save attempts already reported with a toast or sheet, by wrapper id.
  final _reportedSaves = <String>{};
  bool _addingPlace = false;

  @override
  void initState() {
    super.initState();
    if (widget.args.initialTab == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSavedPlaces());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSavedPlaces() {
    final target = _savedPlacesKey.currentContext;
    if (!mounted || target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    _listenToSaveOutcomes();

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        toolbarHeight: 66.spMin,
        centerTitle: false,
        titleSpacing: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18.spMin,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 2.spMin),
            Text(
              'Your level sets these. Change any switch to fine-tune.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.spMin,
                height: 1.3,
                color: _muted,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.transparent,
        foregroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, size: 24.spMin),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NotificationStatusCard(),
            SizedBox(height: 12.spMin),
            const ManagePushNotificationsList(),
            SizedBox(height: 16.spMin),
            Padding(
              key: _savedPlacesKey,
              padding: EdgeInsets.symmetric(horizontal: 16.spMin),
              child: _buildSavedPlacesCard(),
            ),
            SizedBox(height: 16.spMin),
            const NotificationStatusCard(
              part: NotificationStatusCardPart.testPush,
            ),
            SizedBox(height: 24.spMin),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // SAVED PLACES
  // ---------------------------------------------------------------

  Widget _buildSavedPlacesCard() {
    final subscriptions = ref.watch(
      providerOfMyLocationSubscriptions.select((s) => s.locationSubscriptions),
    );
    final loadState = ref.watch(
      providerOfMyLocationSubscriptions.select(
        (s) => s.getLocationSubscriptionsState,
      ),
    );
    final hasPlus = ref.watch(providerOfAlrtPlus).value == true;
    final savedCount = subscriptions.where((s) => !s.isOwnLocation).length;

    final Widget list = loadState.maybeWhen(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 18.spMin),
        child: Center(
          child: SizedBox(
            width: 20.spMin,
            height: 20.spMin,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
            ),
          ),
        ),
      ),
      error: (_) => Text(
        'Your saved places could not be loaded. Check your connection and '
        'try again.',
        style: TextStyle(fontSize: 13.spMin, color: _muted, height: 1.4),
      ),
      orElse: () => subscriptions.isEmpty
          ? Text(
              'Nothing saved yet. Add a place to get its alerts as well as '
              'where you are.',
              style: TextStyle(fontSize: 13.spMin, color: _muted, height: 1.4),
            )
          : Column(
              children: [
                for (final subscription in subscriptions)
                  AllLocationSubscriptionsListItem(subscription: subscription),
              ],
            ),
    );

    return Container(
      key: ManageNotificationsScreen.savedPlacesKey,
      padding: EdgeInsets.all(18.spMin),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.spMin),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SAVED PLACES',
                  style: TextStyle(
                    fontSize: 10.5.spMin,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: _sectionLabel,
                  ),
                ),
              ),
              Text(
                hasPlus
                    ? '$savedCount saved'
                    : '$savedCount of $kFreeSavedLocationsLimit free used',
                style: TextStyle(
                  fontSize: 11.spMin,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.spMin),
          Text(
            'Places you follow for alerts. Where you are is always included.',
            style: TextStyle(
              fontSize: 13.spMin,
              height: 1.45,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 16.spMin),
          list,
          SizedBox(height: 10.spMin),
          SizedBox(
            width: double.infinity,
            height: 46.spMin,
            child: OutlinedButton.icon(
              key: const Key('notifications-add-place'),
              onPressed: _addingPlace ? null : _addPlace,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.orange,
                side: const BorderSide(color: AppColors.orange, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
              ),
              icon: Icon(LucideIcons.plus, size: 18.spMin),
              label: Text(
                'Add a place',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The add-place control. The free allowance is checked first (the
  /// same gate every Save-this-location button uses); past it, the ALRT +
  /// explanation sheet and paywall open from here, and a purchase goes on
  /// to the picker. The backend still has the last word
  /// (SAVED_PLACE_LIMIT, answered in [_listenToSaveOutcomes]).
  Future<void> _addPlace() async {
    if (_addingPlace) return;
    _addingPlace = true;
    try {
      final savedCount = ref
          .read(providerOfMyLocationSubscriptions)
          .locationSubscriptions
          .where((s) => !s.isOwnLocation)
          .length;
      final isPlus = ref.read(providerOfAlrtPlus).value == true;
      final gate = savedLocationGate(savedCount: savedCount, isPlus: isPlus);
      if (gate == SavedLocationGate.needsPlus) {
        final purchased = await _offerAlrtPlus();
        if (!purchased || !mounted) return;
      }

      final picked = await context.push<Object?>(
        SelectLocationScreen.route,
        extra: SelectLocationScreenArgs(showYourLocationOption: false),
      );
      if (!mounted || picked is! AlrtLocation) return;

      final radiusKm =
          ref.read(providerOfLoggedInUser)?.ownLocationSubscriptionRadiusKm ??
          5;
      final location = picked.bounds != null
          ? picked
          : picked.copyWith(
              bounds: boundsAround(
                latitude: picked.latitude,
                longitude: picked.longitude,
                radiusKm: radiusKm.toDouble(),
              ),
            );
      await ref
          .read(providerOfMyLocationSubscriptions.notifier)
          .subscribeToLocation(location: location);
    } finally {
      _addingPlace = false;
    }
  }

  /// The one saved-place upsell (personal limits point to ALRT +, never a
  /// group plan). True when the paywall popped true.
  Future<bool> _offerAlrtPlus() async {
    final purchased = await showAlrtPlusUpsellSheet(
      context: context,
      icon: AlrtPlusUpsellIcons.savedLocation,
      title: 'One saved place on ALRT Free',
      message:
          'ALRT Free includes $kFreeSavedLocationsLimit saved place as well '
          'as where you are. ALRT + gives you unlimited saved '
          'places. Family and Group plans don\'t change this.',
      primaryLabel: 'See ALRT +',
      onPrimary: (ctx) => ctx
          .push<bool>(
            AlrtPlusPaywallScreen.route,
            extra: const AlrtPlusPaywallArgs(
              reason: AlrtPlusPaywallReason.savedLocation,
            ),
          )
          .then((value) => value ?? false),
    );
    if (purchased) {
      ref.invalidate(providerOfAccess);
      ref.invalidate(providerOfAlrtPlus);
    }
    return purchased;
  }

  /// Every save started from this screen ends in something visible: a
  /// success toast, the ALRT + sheet for a SAVED_PLACE_LIMIT refusal, or
  /// the server's message. Each attempt is reported once.
  void _listenToSaveOutcomes() {
    ref.listen(
      providerOfMyLocationSubscriptions.select(
        (s) => s.subscribeToLocationStateWrappers,
      ),
      (previous, wrappers) {
        for (final wrapper in wrappers) {
          if (_reportedSaves.contains(wrapper.id)) continue;
          final done = wrapper.subscribeToLocationState.maybeWhen(
            loading: () => false,
            orElse: () => true,
          );
          if (!done) continue;
          _reportedSaves.add(wrapper.id);
          wrapper.subscribeToLocationState.maybeWhen(
            success: () {
              final name = wrapper.locationSubscription.name;
              context.showSuccessToast(
                message: name == null || name.isEmpty
                    ? 'Location saved. Alerts for it will reach you.'
                    : 'Saved $name. Alerts for it will reach you.',
              );
            },
            error: (error) {
              final refusal = AccessRefusal.fromError(error);
              if (refusal?.kind == AccessRefusalKind.savedPlaceLimit) {
                _offerAlrtPlus();
                return;
              }
              context.showErrorToast(
                message: error.message.isEmpty
                    ? 'Could not save this location. Please try again.'
                    : error.message,
              );
            },
            orElse: () {},
          );
        }
      },
    );
  }
}
