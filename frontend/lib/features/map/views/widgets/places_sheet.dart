import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/models/google_place_model.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/places_provider.dart';
import 'package:hazard_app/features/notification/providers/notifications_feed_provider.dart';
import 'package:hazard_app/features/notification/views/screens/manage_notifications_screen.dart';
import 'package:hazard_app/features/profile/providers/my_location_subscriptions_provider.dart';
import 'package:hazard_app/features/profile/providers/states/my_location_subscriptions_provider_state.dart';
import 'package:hazard_app/features/shared/extensions/context_extension.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/models/location_subscription_model.dart';
import 'package:hazard_app/features/shared/providers/logged_in_user_provider.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';
import 'package:hazard_app/features/subscription/providers/alrt_plus_provider.dart';
import 'package:hazard_app/features/subscription/utils/access_refusal.dart';
import 'package:hazard_app/features/subscription/utils/saved_location_gate.dart';
import 'package:hazard_app/features/subscription/views/screens/alrt_plus_paywall_screen.dart';
import 'package:hazard_app/features/subscription/views/widgets/alrt_plus_upsell_sheet.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The Places and Edit place sheets (prototype boards Places, PlacesSearch,
/// PlacesSaved and PlaceEdit, 16 Oct 2026): where you get alerts, opened
/// over the map.
///
/// Places: a search field that adds a place through the backend's place
/// search, My location (follows you), each saved place with its address
/// and how many alerts are inside it now, an Edit button on every row, and
/// the ALRT Free allowance card. Edit place: name, ALERT RADIUS chips,
/// how many alerts are inside that radius now, Save, Remove, Cancel.

const _ink = Color(0xFF1C1C1E);
const _muted = Color(0xFF5C5C66);
const _body = Color(0xFF3A3A42);
const _line = Color(0xFFE3E6EA);
const _hairline = Color(0xFFECEEF1);
const _field = Color(0xFFF5F5F7);
const _handle = Color(0xFFD9D6D0);
const _upsellWash = Color(0xFFFFF4EE);
const _meWash = Color(0xFFEAF1FE);
const _meInk = Color(0xFF2563EB);
const _chipOnWash = Color(0xFFFAF9F7);
const _secondaryBorder = Color(0xFFD9D6D0);

/// The radius choices on Edit place, in km.
const kPlaceRadiusChoicesKm = <int>[2, 5, 10, 25];

/// The key for this sheet's own place-search results.
const kPlacesSheetSearchKey = 'PlacesSheet';

Future<void> showPlacesSheet({required final BuildContext context}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.35),
    builder: (context) => const PlacesSheet(),
  );
}

Future<void> showPlaceEditSheet({
  required final BuildContext context,
  required final LocationSubscription subscription,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.black.withValues(alpha: 0.35),
    builder: (context) => PlaceEditSheet(subscription: subscription),
  );
}

/// Alerts inside a subscription's box, counted from the alerts the app
/// already holds (the alerts feed covers every saved place; the map adds
/// what is on screen). Expired alerts are left out.
int alertsInsideSubscription(
  final LocationSubscription sub,
  final Iterable<Hazard> hazards,
) {
  final seen = <String>{};
  var count = 0;
  for (final h in hazards) {
    final lat = h.latitude, lng = h.longitude;
    if (lat == null || lng == null || h.isExpired) continue;
    final key = h.id ?? '$lat,$lng,${h.title}';
    if (!seen.add(key)) continue;
    if (lat <= sub.northeastLat &&
        lat >= sub.southwestLat &&
        lng <= sub.northeastLng &&
        lng >= sub.southwestLng) {
      count++;
    }
  }
  return count;
}

String _alertsNow(final int count) =>
    '$count alert${count == 1 ? '' : 's'} now';

/// The saved-place upsell (personal limits point to ALRT +, never a group
/// plan). True when the paywall popped true.
Future<bool> offerAlrtPlusForPlaces({
  required final BuildContext context,
  required final WidgetRef ref,
}) async {
  final purchased = await showAlrtPlusUpsellSheet(
    context: context,
    icon: AlrtPlusUpsellIcons.savedLocation,
    title: 'One saved place on ALRT Free',
    message:
        'ALRT Free includes $kFreeSavedLocationsLimit saved place as well '
        'as where you are. ALRT + gives you unlimited places.',
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

/// Saves [place] for alerts, with the place's own default radius, and
/// ends in something visible: a toast, the ALRT + sheet, or the server's
/// message. The free allowance is checked first; the backend still has
/// the last word with SAVED_PLACE_LIMIT. True when the place was saved.
Future<bool> savePlaceForAlerts({
  required final BuildContext context,
  required final WidgetRef ref,
  required final GooglePlace place,
}) async {
  final notifier = ref.read(providerOfMyLocationSubscriptions.notifier);
  final subs = ref.read(providerOfMyLocationSubscriptions).locationSubscriptions;
  final savedCount = subs.where((s) => !s.isOwnLocation).length;
  final isPlus = ref.read(providerOfAlrtPlus).value == true;
  if (savedLocationGate(savedCount: savedCount, isPlus: isPlus) ==
      SavedLocationGate.needsPlus) {
    final purchased = await offerAlrtPlusForPlaces(context: context, ref: ref);
    if (!purchased || !context.mounted) return false;
  }

  final radiusKm =
      ref.read(providerOfLoggedInUser)?.ownLocationSubscriptionRadiusKm ?? 5;
  final location = place.toAlrtLocation.copyWith(
    bounds: boundsAround(
      latitude: place.latitude,
      longitude: place.longitude,
      radiusKm: radiusKm.toDouble(),
    ),
  );
  final before = ref
      .read(providerOfMyLocationSubscriptions)
      .subscribeToLocationStateWrappers
      .map((w) => w.id)
      .toSet();
  await notifier.subscribeToLocation(location: location);
  if (!context.mounted) return false;
  final mine = ref
      .read(providerOfMyLocationSubscriptions)
      .subscribeToLocationStateWrappers
      .where((w) => !before.contains(w.id))
      .toList();
  if (mine.isEmpty) return false;
  var limitHit = false;
  var failedMessage = '';
  var saved = false;
  mine.last.subscribeToLocationState.maybeWhen<void>(
    success: () {
      saved = true;
    },
    error: (error) {
      final refusal = AccessRefusal.fromError(error);
      if (refusal?.kind == AccessRefusalKind.savedPlaceLimit) {
        limitHit = true;
      } else {
        failedMessage = error.message;
      }
    },
    orElse: () {},
  );
  if (saved) {
    context.showSuccessToast(
      message: "ALRT will keep an eye on ${place.name} even when you're away.",
    );
    return true;
  }
  if (limitHit) {
    await offerAlrtPlusForPlaces(context: context, ref: ref);
    return false;
  }
  context.showErrorToast(
    message: failedMessage.isEmpty
        ? 'Could not save this place. Please try again.'
        : failedMessage,
  );
  return false;
}

/// The sheet's white body, drag handle on top.
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
        ),
        padding: EdgeInsets.fromLTRB(
          16.spMin,
          10.spMin,
          16.spMin,
          16.spMin + keyboard,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.spMin,
                  height: 5.spMin,
                  decoration: BoxDecoration(
                    color: _handle,
                    borderRadius: BorderRadius.circular(3.spMin),
                  ),
                ),
              ),
              SizedBox(height: 16.spMin),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A small white outlined button (36 high, radius 10), as on the boards.
Widget _smallButton({
  required final String label,
  required final VoidCallback? onTap,
  final Color color = _ink,
}) {
  return Material(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(10.spMin),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.spMin),
      child: Container(
        height: 36.spMin,
        padding: EdgeInsets.symmetric(horizontal: 14.spMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.spMin),
          border: Border.all(color: _line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.spMin,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    ),
  );
}

class PlacesSheet extends ConsumerStatefulWidget {
  const PlacesSheet({super.key});

  @override
  ConsumerState<PlacesSheet> createState() => _PlacesSheetState();
}

class _PlacesSheetState extends ConsumerState<PlacesSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _adding = false;

  @override
  void dispose() {
    EasyDebounce.cancel('places-sheet-search');
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(final String value) {
    final query = value.trim();
    ref.read(providerOfPlaces(kPlacesSheetSearchKey).notifier)
      ..updateSearchString(query)
      ..updateGetPlacesToLoading();
    setState(() {});
    EasyDebounce.debounce(
      'places-sheet-search',
      const Duration(milliseconds: 280),
      () {
        if (!mounted) return;
        ref.read(providerOfPlaces(kPlacesSheetSearchKey).notifier).getPlaces();
      },
    );
  }

  void _clearSearch() {
    _controller.clear();
    ref
        .read(providerOfPlaces(kPlacesSheetSearchKey).notifier)
        .updateSearchString('');
    setState(() {});
  }

  /// The Add button in the field adds the first match, or puts the cursor
  /// in the field when nothing has been typed.
  void _onAddPressed() {
    final places = ref.read(providerOfPlaces(kPlacesSheetSearchKey)).places;
    if (_controller.text.trim().isEmpty || places.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    _addPlace(places.first);
  }

  Future<void> _openPaywall() async {
    final purchased = await context.push<bool>(
      AlrtPlusPaywallScreen.route,
      extra: const AlrtPlusPaywallArgs(
        reason: AlrtPlusPaywallReason.savedLocation,
      ),
    );
    if (!mounted) return;
    if (purchased == true) {
      ref.invalidate(providerOfAccess);
      ref.invalidate(providerOfAlrtPlus);
    }
  }

  Future<void> _addPlace(final GooglePlace place) async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      final saved = await savePlaceForAlerts(
        context: context,
        ref: ref,
        place: place,
      );
      if (saved && mounted) _clearSearch();
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subs = ref.watch(
      providerOfMyLocationSubscriptions.select((s) => s.locationSubscriptions),
    );
    final loading = ref.watch(
      providerOfMyLocationSubscriptions.select(
        (s) => s.getLocationSubscriptionsState.maybeWhen(
          loading: () => true,
          orElse: () => false,
        ),
      ),
    );
    final feedHazards = ref.watch(
      providerOfNotificationsFeed.select((s) => s.hazards),
    );
    final mapHazards = ref.watch(providerOfMap.select((s) => s.hazards));
    final hazards = [...feedHazards, ...mapHazards];
    final hasPlus = ref.watch(providerOfAlrtPlus).value == true;
    final ownRadiusKm =
        ref.watch(
          providerOfLoggedInUser.select(
            (u) => u?.ownLocationSubscriptionRadiusKm,
          ),
        ) ??
        5;
    final query = ref.watch(
      providerOfPlaces(kPlacesSheetSearchKey).select((s) => s.searchString),
    );
    final results = ref.watch(
      providerOfPlaces(kPlacesSheetSearchKey).select((s) => s.places),
    );

    LocationSubscription? own;
    for (final s in subs) {
      if (s.isOwnLocation) {
        own = s;
        break;
      }
    }
    final saved = subs.where((s) => !s.isOwnLocation).toList();

    final ownAlerts = own == null ? null : alertsInsideSubscription(own, hazards);
    final ownSub = [
      '$ownRadiusKm km radius',
      'follows you',
      if (ownAlerts != null) _alertsNow(ownAlerts),
    ].join(' · ');

    final rows = <Widget>[
      _placeRow(
        isMe: true,
        title: 'My location',
        subtitle: ownSub,
        onEdit: own == null
            ? null
            : () => showPlaceEditSheet(context: context, subscription: own!),
      ),
      for (final s in saved)
        _placeRow(
          isMe: false,
          title: (s.name?.trim().isNotEmpty ?? false) ? s.name! : 'Saved place',
          subtitle: [
            if (s.address?.trim().isNotEmpty ?? false)
              s.address!
            else
              '${s.radiusInKm.round()} km radius',
            _alertsNow(alertsInsideSubscription(s, hazards)),
          ].join(' · '),
          onEdit: () => showPlaceEditSheet(context: context, subscription: s),
        ),
    ];

    return _SheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  'Places',
                  style: TextStyle(
                    fontSize: 24.spMin,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: _ink,
                  ),
                ),
              ),
              Text(
                'Where you get alerts',
                style: TextStyle(fontSize: 13.spMin, color: _muted),
              ),
            ],
          ),
          SizedBox(height: 16.spMin),
          _searchFieldBuilder(),
          if (query.isNotEmpty && results.isNotEmpty) ...[
            SizedBox(height: 8.spMin),
            _resultsBuilder(results),
          ],
          SizedBox(height: 16.spMin),
          if (loading && subs.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18.spMin),
              child: Center(
                child: SizedBox(
                  width: 20.spMin,
                  height: 20.spMin,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.spMin),
                border: Border.all(color: _hairline),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    if (i > 0)
                      Container(
                        height: 1,
                        margin: EdgeInsets.symmetric(horizontal: 16.spMin),
                        color: _hairline,
                      ),
                    rows[i],
                  ],
                ],
              ),
            ),
          SizedBox(height: 10.spMin),
          Text(
            saved.isEmpty
                ? 'Search above to add your first place.'
                : 'Tap Edit to change the radius or remove a place.',
            style: TextStyle(fontSize: 12.spMin, color: _muted),
          ),
          if (!hasPlus) ...[
            SizedBox(height: 16.spMin),
            _upsellBuilder(),
          ],
        ],
      ),
    );
  }

  Widget _searchFieldBuilder() {
    return Container(
      height: 48.spMin,
      padding: EdgeInsets.only(left: 14.spMin, right: 6.spMin),
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 18.spMin, color: _muted),
          SizedBox(width: 10.spMin),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onAddPressed(),
              style: TextStyle(fontSize: 15.spMin, color: _ink),
              decoration: InputDecoration(
                hintText: 'Search to add a place',
                hintStyle: TextStyle(fontSize: 15.spMin, color: _muted),
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 8.spMin),
          _adding
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.spMin),
                  child: SizedBox(
                    width: 16.spMin,
                    height: 16.spMin,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _smallButton(label: 'Add', onTap: _onAddPressed),
        ],
      ),
    );
  }

  Widget _resultsBuilder(final List<GooglePlace> results) {
    final shown = results.take(5).toList();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.spMin),
        border: Border.all(color: _hairline),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < shown.length; i++)
            Material(
              color: AppColors.white,
              child: InkWell(
                onTap: _adding ? null : () => _addPlace(shown[i]),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.spMin,
                    vertical: 12.spMin,
                  ),
                  decoration: BoxDecoration(
                    border: i == shown.length - 1
                        ? null
                        : const Border(
                            bottom: BorderSide(color: Color(0xFFF0F0F2)),
                          ),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 18.spMin, color: _muted),
                      SizedBox(width: 12.spMin),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shown[i].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.spMin,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                            Text(
                              shown[i].address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.spMin,
                                color: _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.spMin),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 13.spMin,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeRow({
    required final bool isMe,
    required final String title,
    required final String subtitle,
    required final VoidCallback? onEdit,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.spMin, vertical: 14.spMin),
      child: Row(
        children: [
          Container(
            width: 40.spMin,
            height: 40.spMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isMe ? _meWash : AppColors.white,
              borderRadius: BorderRadius.circular(12.spMin),
              border: isMe ? null : Border.all(color: _line),
            ),
            child: Icon(
              isMe ? LucideIcons.navigation : LucideIcons.mapPin,
              size: 18.spMin,
              color: isMe ? _meInk : AppColors.orange,
            ),
          ),
          SizedBox(width: 12.spMin),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 2.spMin),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.spMin, color: _muted),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.spMin),
          if (onEdit != null) _smallButton(label: 'Edit', onTap: onEdit),
        ],
      ),
    );
  }

  Widget _upsellBuilder() {
    return Container(
      padding: EdgeInsets.all(16.spMin),
      decoration: BoxDecoration(
        color: _upsellWash,
        borderRadius: BorderRadius.circular(16.spMin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'One saved place on ALRT Free',
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          SizedBox(height: 10.spMin),
          Text(
            'ALRT Free includes $kFreeSavedLocationsLimit saved place as well '
            'as where you are. ALRT + gives you unlimited places.',
            style: TextStyle(fontSize: 14.spMin, color: _body, height: 1.45),
          ),
          SizedBox(height: 10.spMin),
          Material(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(12.spMin),
            child: InkWell(
              onTap: _openPaywall,
              borderRadius: BorderRadius.circular(12.spMin),
              child: Container(
                height: 40.spMin,
                padding: EdgeInsets.symmetric(horizontal: 18.spMin),
                alignment: Alignment.center,
                child: Text(
                  'See ALRT +',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceEditSheet extends ConsumerStatefulWidget {
  const PlaceEditSheet({super.key, required this.subscription});

  final LocationSubscription subscription;

  @override
  ConsumerState<PlaceEditSheet> createState() => _PlaceEditSheetState();
}

class _PlaceEditSheetState extends ConsumerState<PlaceEditSheet> {
  late final TextEditingController _name;
  late final int _initialRadiusKm;
  late int _radiusKm;
  bool _busy = false;

  bool get _isMe => widget.subscription.isOwnLocation;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.subscription.name ?? '');
    final own = ref.read(providerOfLoggedInUser)?.ownLocationSubscriptionRadiusKm;
    _initialRadiusKm = _isMe && own != null
        ? own
        : widget.subscription.radiusInKm.round();
    _radiusKm = _initialRadiusKm;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Alerts within the chosen radius of the place's centre right now.
  int _alertsInside(final Iterable<Hazard> hazards) {
    final centre = widget.subscription.center;
    final seen = <String>{};
    var count = 0;
    for (final h in hazards) {
      final lat = h.latitude, lng = h.longitude;
      if (lat == null || lng == null || h.isExpired) continue;
      final key = h.id ?? '$lat,$lng,${h.title}';
      if (!seen.add(key)) continue;
      final metres = calculateDistanceInMeters(
        centre.latitude,
        centre.longitude,
        lat,
        lng,
      );
      if (metres <= _radiusKm * 1000) count++;
    }
    return count;
  }

  Future<void> _save() async {
    if (_busy) return;
    final name = _name.text.trim();
    final nameChanged =
        !_isMe && name.isNotEmpty && name != (widget.subscription.name ?? '');
    if (_radiusKm == _initialRadiusKm && !nameChanged) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _busy = true);
    final notifier = ref.read(providerOfMyLocationSubscriptions.notifier);
    try {
      if (_isMe) {
        await notifier.updateLocationSubscriptionRadius(
          newRadiusInKm: _radiusKm.toDouble(),
        );
        if (!mounted) return;
        final failed = ref
            .read(providerOfMyLocationSubscriptions)
            .updateUserLocationSubscriptionRadiusState
            .maybeWhen(error: (_) => true, orElse: () => false);
        if (failed) {
          context.showErrorToast(
            message: 'Could not change the radius. Please try again.',
          );
          return;
        }
        Navigator.of(context).maybePop();
        return;
      }

      // There is no endpoint to change a saved place in place, so the
      // place is saved again with the new name and radius and the old
      // one removed (removed first, so ALRT Free's one place is not
      // counted twice).
      final sub = widget.subscription;
      final id = sub.id;
      if (id == null) return;
      await notifier.unsubscribeFromLocation(subscriptionId: id);
      if (!mounted) return;
      final stillThere = ref
          .read(providerOfMyLocationSubscriptions)
          .locationSubscriptions
          .any((s) => s.id == id);
      if (stillThere) {
        context.showErrorToast(
          message: 'Could not change this place. Please try again.',
        );
        return;
      }
      final centre = sub.center;
      final before = ref
          .read(providerOfMyLocationSubscriptions)
          .subscribeToLocationStateWrappers
          .map((w) => w.id)
          .toSet();
      await notifier.subscribeToLocation(
        location: AlrtLocation(
          latitude: centre.latitude,
          longitude: centre.longitude,
          name: name.isEmpty ? sub.name : name,
          address: sub.address,
          bounds: boundsAround(
            latitude: centre.latitude,
            longitude: centre.longitude,
            radiusKm: _radiusKm.toDouble(),
          ),
        ),
      );
      if (!mounted) return;
      final mine = ref
          .read(providerOfMyLocationSubscriptions)
          .subscribeToLocationStateWrappers
          .where((w) => !before.contains(w.id))
          .toList();
      final saved = mine.isNotEmpty &&
          mine.last.subscribeToLocationState.maybeWhen<bool>(
            success: () => true,
            orElse: () => false,
          );
      if (!saved) {
        context.showErrorToast(
          message: 'The place was removed but could not be saved again. '
              'Search above to add it back.',
        );
        return;
      }
      Navigator.of(context).maybePop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    final id = widget.subscription.id;
    if (_busy || id == null) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(providerOfMyLocationSubscriptions.notifier)
          .unsubscribeFromLocation(subscriptionId: id);
      if (!mounted) return;
      final stillThere = ref
          .read(providerOfMyLocationSubscriptions)
          .locationSubscriptions
          .any((s) => s.id == id);
      if (stillThere) {
        context.showErrorToast(
          message: 'Could not remove this place. Please try again.',
        );
        return;
      }
      Navigator.of(context).maybePop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedHazards = ref.watch(
      providerOfNotificationsFeed.select((s) => s.hazards),
    );
    final mapHazards = ref.watch(providerOfMap.select((s) => s.hazards));
    final count = _alertsInside([...feedHazards, ...mapHazards]);
    final address = widget.subscription.address?.trim() ?? '';

    return _SheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isMe ? 'My location' : 'Edit place',
            style: TextStyle(
              fontSize: 22.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: _ink,
            ),
          ),
          if (_isMe || address.isNotEmpty) ...[
            SizedBox(height: 4.spMin),
            Text(
              _isMe ? 'Alerts follow you wherever you are.' : address,
              style: TextStyle(fontSize: 14.spMin, color: _muted, height: 1.45),
            ),
          ],
          if (!_isMe) ...[
            SizedBox(height: 14.spMin),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(fontSize: 15.spMin, color: _ink),
              decoration: InputDecoration(
                hintText: 'Name this place',
                hintStyle: TextStyle(fontSize: 15.spMin, color: _muted),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.spMin,
                  vertical: 14.spMin,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                  borderSide: const BorderSide(color: _line, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                  borderSide: const BorderSide(color: _ink, width: 1.5),
                ),
              ),
            ),
          ],
          SizedBox(height: 14.spMin),
          Text(
            'ALERT RADIUS',
            style: TextStyle(
              fontSize: 12.spMin,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.sectionLabel,
            ),
          ),
          SizedBox(height: 10.spMin),
          Wrap(
            spacing: 8.spMin,
            runSpacing: 8.spMin,
            children: [
              for (final km in kPlaceRadiusChoicesKm) _radiusChip(km),
            ],
          ),
          SizedBox(height: 14.spMin),
          Container(
            padding: EdgeInsets.all(16.spMin),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.spMin),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.06),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count alert${count == 1 ? '' : 's'} inside $_radiusKm km '
                  'right now',
                  style: TextStyle(
                    fontSize: 15.spMin,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 10.spMin),
                Text(
                  'Official warnings and community reports inside this '
                  'radius reach this phone.',
                  style: TextStyle(
                    fontSize: 13.spMin,
                    color: _muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.spMin),
          SizedBox(
            height: 54.spMin,
            child: ElevatedButton(
              onPressed: _busy ? null : _save,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.orange,
                disabledBackgroundColor:
                    AppColors.orange.withValues(alpha: 0.5),
                foregroundColor: AppColors.white,
                disabledForegroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.spMin),
                ),
              ),
              child: _busy
                  ? SizedBox(
                      width: 20.spMin,
                      height: 20.spMin,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          if (!_isMe) ...[
            SizedBox(height: 14.spMin),
            SizedBox(
              height: 48.spMin,
              child: OutlinedButton(
                onPressed: _busy ? null : _remove,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _ink,
                  side: const BorderSide(color: _secondaryBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.spMin),
                  ),
                ),
                child: Text(
                  'Remove this place',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 6.spMin),
          SizedBox(
            height: 44.spMin,
            child: TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
              style: TextButton.styleFrom(foregroundColor: _muted),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _radiusChip(final int km) {
    final on = _radiusKm == km;
    return Semantics(
      button: true,
      selected: on,
      label: '$km km',
      child: GestureDetector(
        onTap: _busy ? null : () => setState(() => _radiusKm = km),
        child: Container(
          height: 40.spMin,
          padding: EdgeInsets.symmetric(horizontal: 16.spMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? _chipOnWash : AppColors.white,
            borderRadius: BorderRadius.circular(20.spMin),
            border: Border.all(
              color: on ? _ink : _line,
              width: on ? 2 : 1.5,
            ),
          ),
          child: Text(
            '$km km',
            style: TextStyle(
              fontSize: 14.spMin,
              fontWeight: on ? FontWeight.w700 : FontWeight.w600,
              color: _ink,
            ),
          ),
        ),
      ),
    );
  }
}
