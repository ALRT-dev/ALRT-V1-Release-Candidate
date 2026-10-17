import 'dart:math' as math;

import 'package:flutter/material.dart' hide Route;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/family/views/screens/family_journey_screen.dart';
import 'package:hazard_app/features/home/enums/home_tab_types.dart';
import 'package:hazard_app/features/home/providers/home_tab_provider.dart';
import 'package:hazard_app/features/map/models/alrt_location_model.dart';
import 'package:hazard_app/features/map/models/route_plan_model.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/states/map_provider_state.dart';
import 'package:hazard_app/features/map/utils/directions_helper.dart';
import 'package:hazard_app/features/map/views/screens/select_location_screen.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/route_hazard_shape.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/route_option_format.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CheckRouteScreenArgs {
  const CheckRouteScreenArgs({this.destination, this.checkOnOpen = false});

  /// Where the person is going, when already known (a place picked on the
  /// map, or "take me to" said to ALRT).
  final AlrtLocation? destination;

  /// Ask for the routes as soon as the screen opens.
  final bool checkOnOpen;
}

/// Check a route (prototype boards "Route", "RouteOptions", "RouteChosen";
/// rules.json route: "show hazards on each route option and let the person
/// choose, like Google Maps").
///
/// Pick From and To, a mode, then Check the route. The options come from
/// the Routes API through map_repository.getRoute (map_provider.getRoutePlan),
/// each with the alerts that touch it. Go this way starts navigation on the
/// map (Travelling).
class CheckRouteScreen extends ConsumerStatefulWidget {
  const CheckRouteScreen({super.key, this.args});

  final CheckRouteScreenArgs? args;

  static const String route = '/check-route';

  /// Opens Check a route, optionally for [destination].
  static Future<void> open(
    final BuildContext context, {
    final AlrtLocation? destination,
    final bool checkOnOpen = false,
  }) {
    return context.push<void>(
      route,
      extra: CheckRouteScreenArgs(
        destination: destination,
        checkOnOpen: checkOnOpen,
      ),
    );
  }

  @override
  ConsumerState<CheckRouteScreen> createState() => _CheckRouteScreenState();
}

class _CheckRouteScreenState extends ConsumerState<CheckRouteScreen> {
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _page = Color(0xFFF5F5F7);
  static const _field = Color(0xFFE3E6EA);
  static const _orange = Color(0xFFE8622A);
  static const _routeBlue = Color(0xFF2563EB);
  static const _noteTint = Color(0xFFF0EEEA);

  /// Null means "Your location", read fresh when the route is checked.
  AlrtLocation? _origin;
  AlrtLocation? _destination;
  TravelMode _mode = TravelMode.driving;
  bool _checking = false;
  String? _failure;

  @override
  void initState() {
    super.initState();
    final plan = ref.read(providerOfMap).currentRoutePlan;
    final argDestination = widget.args?.destination;
    if (argDestination != null) {
      _destination = argDestination;
    } else if (plan != null) {
      // Opened again from Travelling: show the trip being travelled.
      _destination = plan.destination;
      _mode = plan.selectedTravelMode;
      final here = ref.read(providerOfLocation).location;
      if (plan.origin != here) _origin = plan.origin;
    }
    if ((widget.args?.checkOnOpen ?? false) && _destination != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _checkRoute();
      });
    }
  }

  bool get _isNavigating =>
      ref.read(providerOfMap).currentRoutePlan?.isNavigating ?? false;

  /// Leaving without starting drops the planned routes from the map.
  void _clearPlanIfIdle() {
    if (_isNavigating) return;
    if (ref.read(providerOfMap).currentRoutePlan == null) return;
    ref.read(providerOfMap.notifier).updateCurrentRoutePlan(null);
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(providerOfMap.select((s) => s.currentRoutePlan));
    final loading = _checking ||
        ref.watch(
          providerOfMap.select(
            (s) => s.getRouteState.maybeWhen(
              loading: () => true,
              orElse: () => false,
            ),
          ),
        );
    final showResults = plan != null &&
        _destination != null &&
        plan.destination == _destination;

    return PopScope<Object?>(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _clearPlanIfIdle();
      },
      child: Scaffold(
        backgroundColor: _page,
        body: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16.spMin,
                  14.spMin,
                  16.spMin,
                  24.spMin + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  _fieldBox(
                    text: _origin?.displayName ?? 'Your location',
                    isPlaceholder: false,
                    onTap: _pickOrigin,
                  ),
                  SizedBox(height: 14.spMin),
                  _fieldBox(
                    text: _destination?.displayName ?? 'To',
                    isPlaceholder: _destination == null,
                    onTap: _pickDestination,
                  ),
                  SizedBox(height: 14.spMin),
                  _modeChips(plan),
                  SizedBox(height: 14.spMin),
                  _primaryButton(
                    label: 'Check the route',
                    color: _orange,
                    loading: loading,
                    onPressed: loading ? null : _checkRoute,
                  ),
                  if (_failure != null) ...[
                    SizedBox(height: 14.spMin),
                    _note(_failure!, background: const Color(0xFFFDE8EA)),
                  ],
                  if (showResults) ..._results(plan),
                  SizedBox(height: 14.spMin),
                  _note(
                    'ALRT adds the alerts that touch each route and never '
                    'stores where you are going.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ parts

  Widget _header(final BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(
        8.spMin,
        MediaQuery.paddingOf(context).top + 8.spMin,
        16.spMin,
        12.spMin,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                tooltip: 'Back',
                icon: Icon(LucideIcons.chevronLeft, size: 26.spMin, color: _ink),
              ),
              Expanded(
                child: Text(
                  'Check a route',
                  style: TextStyle(
                    fontSize: 24.spMin,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.spMin),
            child: Text(
              'Alerts on the way, before you leave',
              style: TextStyle(fontSize: 14.spMin, color: _muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldBox({
    required final String text,
    required final bool isPlaceholder,
    required final VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.spMin),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.spMin),
        child: Container(
          height: 48.spMin,
          padding: EdgeInsets.symmetric(horizontal: 14.spMin),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.spMin),
            border: Border.all(color: _field, width: 1.5),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.spMin,
              fontWeight: FontWeight.w500,
              color: isPlaceholder ? _muted.withValues(alpha: 0.7) : _ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeChips(final RoutePlan? plan) {
    return Wrap(
      spacing: 8.spMin,
      runSpacing: 8.spMin,
      children: [
        for (final (mode, label) in RouteOptionFormat.modes)
          _chip(
            label: label,
            selected: _mode == mode,
            onTap: () => _handleModeTap(mode, plan),
          ),
      ],
    );
  }

  Widget _chip({
    required final String label,
    required final bool selected,
    required final VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.spMin),
      child: Container(
        height: 40.spMin,
        padding: EdgeInsets.symmetric(horizontal: 16.spMin),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFAF9F7) : AppColors.white,
          borderRadius: BorderRadius.circular(20.spMin),
          border: Border.all(
            color: selected ? _ink : _field,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.spMin,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: _ink,
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required final String label,
    required final Color color,
    required final VoidCallback? onPressed,
    final bool loading = false,
  }) {
    return SizedBox(
      height: 54.spMin,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.spMin),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 16.0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            disabledBackgroundColor: color.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.spMin),
            ),
          ),
          child: loading
              ? SizedBox(
                  width: 22.spMin,
                  height: 22.spMin,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required final String label,
    required final VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 54.spMin,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: _ink,
          side: const BorderSide(color: Color(0xFFD9D6D0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _note(final String text, {final Color background = _noteTint}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.spMin, vertical: 12.spMin),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14.spMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.spMin,
          height: 1.45,
          color: const Color(0xFF3A3A42),
        ),
      ),
    );
  }

  Widget _sectionLabel(final String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.spMin),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.sectionLabel,
        ),
      ),
    );
  }

  List<Widget> _results(final RoutePlan plan) {
    final options = plan.travelModeRoutes[_mode];
    if (options == null) {
      final reason = plan.unavailableModes[_mode];
      return [
        SizedBox(height: 14.spMin),
        _note(
          '${RouteOptionFormat.modeLabel(_mode)} is not available for this '
          'trip.${reason == null ? '' : ' $reason'}',
        ),
      ];
    }

    final routes = options.allRoutes;
    final selected = options.currentRoute;
    final selectedIndex = math.max(0, routes.indexOf(selected));
    final hazardsByRoute = [
      for (final r in routes)
        RouteOptionFormat.hazardsOnRoute(
          hazards: plan.hazardsToAvoid,
          route: r,
        ),
    ];

    return [
      SizedBox(height: 14.spMin),
      _RoutePreview(
        routes: [
          for (final r in routes)
            r.polylinePoints
                    ?.map((p) => LatLng(p.latitude, p.longitude))
                    .toList() ??
                const <LatLng>[],
        ],
        selectedIndex: selectedIndex,
        hazards: hazardsByRoute.isEmpty
            ? const <Hazard>[]
            : hazardsByRoute[selectedIndex],
        origin: plan.origin.latLng,
        destination: plan.destination.latLng,
      ),
      SizedBox(height: 14.spMin),
      _sectionLabel('Choose a route'),
      for (var i = 0; i < routes.length; i++) ...[
        SizedBox(height: 10.spMin),
        _routeCard(
          route: routes[i],
          isSelected: i == selectedIndex,
          isFastest: routes[i] == options.fastestRoute,
          hazards: hazardsByRoute[i],
          distanceAndVia: RouteOptionFormat.distanceAndVia(
            routes[i],
            options.stepsForRoute(routes[i]),
          ),
        ),
      ],
      SizedBox(height: 14.spMin),
      Row(
        children: [
          Expanded(
            child: _primaryButton(
              label: plan.isNavigating ? 'Back to travelling' : 'Go this way',
              color: _routeBlue,
              onPressed: _goThisWay,
            ),
          ),
          SizedBox(width: 10.spMin),
          Expanded(
            child: _secondaryButton(
              label: 'Share journey',
              onPressed: () => context.push(FamilyJourneyScreen.route),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.spMin),
      Text(
        'Navigation is free. Sharing this journey with your circle is part '
        'of ALRT +. You will be told if a new alert appears on the way.',
        style: TextStyle(fontSize: 12.spMin, color: _muted, height: 1.45),
      ),
    ];
  }

  Widget _routeCard({
    required final Route route,
    required final bool isSelected,
    required final bool isFastest,
    required final List<Hazard> hazards,
    required final String distanceAndVia,
  }) {
    const maxRows = 4;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18.spMin),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.spMin),
        onTap: () => ref.read(providerOfMap.notifier).handleRouteTap(route),
        child: Container(
          padding: EdgeInsets.all(16.spMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.spMin),
            border: Border.all(
              color: isSelected ? _routeBlue : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.spMin,
                runSpacing: 4.spMin,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    RouteOptionFormat.minutes(route.durationMinutes),
                    style: TextStyle(
                      fontSize: 18.spMin,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  if (distanceAndVia.isNotEmpty)
                    Text(
                      distanceAndVia,
                      style: TextStyle(fontSize: 13.spMin, color: _muted),
                    ),
                  if (isFastest)
                    _pill('Fastest', const Color(0xFFEAF1FE), _routeBlue)
                  else if (hazards.isEmpty)
                    _pill(
                      'No alerts',
                      const Color(0xFFE6F6EC),
                      const Color(0xFF15803D),
                    ),
                ],
              ),
              SizedBox(height: 10.spMin),
              if (hazards.isEmpty)
                Text(
                  'No alerts touch this route right now.',
                  style: TextStyle(fontSize: 13.spMin, color: _muted),
                )
              else ...[
                for (final hazard in hazards.take(maxRows))
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.spMin),
                    child: _hazardRow(hazard),
                  ),
                if (hazards.length > maxRows)
                  Text(
                    'and ${hazards.length - maxRows} more',
                    style: TextStyle(fontSize: 13.spMin, color: _muted),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _hazardRow(final Hazard hazard) {
    final level = routeHazardLevelOf(hazard);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 1.spMin),
          child: RouteHazardShape(hazard: hazard, size: 16.spMin),
        ),
        SizedBox(width: 8.spMin),
        Expanded(
          child: Text(
            hazard.title ?? hazard.category?.name ?? 'Alert',
            style: TextStyle(fontSize: 13.spMin, color: _ink, height: 1.35),
          ),
        ),
        if (level.isNotEmpty) ...[
          SizedBox(width: 8.spMin),
          Text(
            level,
            style: TextStyle(fontSize: 13.spMin, color: _muted),
          ),
        ],
      ],
    );
  }

  Widget _pill(final String text, final Color background, final Color ink) {
    return Container(
      height: 26.spMin,
      padding: EdgeInsets.symmetric(horizontal: 10.spMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13.spMin),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.spMin,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- actions

  Future<void> _pickOrigin() async {
    final picked = await context.push<Object?>(
      SelectLocationScreen.route,
      extra: SelectLocationScreenArgs(initialLocation: _origin),
    );
    if (!mounted || picked is! AlrtLocation) return;
    final here = ref.read(providerOfLocation).location;
    final isHere =
        picked.latitude == here.latitude && picked.longitude == here.longitude;
    _clearPlanIfIdle();
    setState(() {
      _origin = isHere ? null : picked;
      _failure = null;
    });
  }

  Future<void> _pickDestination() async {
    final picked = await context.push<Object?>(
      SelectLocationScreen.route,
      extra: SelectLocationScreenArgs(
        initialLocation: _destination,
        showYourLocationOption: false,
      ),
    );
    if (!mounted || picked is! AlrtLocation) return;
    _clearPlanIfIdle();
    setState(() {
      _destination = picked;
      _failure = null;
    });
  }

  void _handleModeTap(final TravelMode mode, final RoutePlan? plan) {
    setState(() => _mode = mode);
    if (plan != null && plan.travelModeRoutes.containsKey(mode)) {
      ref.read(providerOfMap.notifier).updateSelectedTravelMode(mode);
    }
  }

  Future<void> _checkRoute() async {
    final destination = _destination;
    if (destination == null) {
      await _pickDestination();
      if (!mounted || _destination == null) return;
      return _checkRoute();
    }
    if (_isNavigating) {
      setState(() {
        _failure = 'End the trip you are on before checking another route.';
      });
      return;
    }
    setState(() {
      _checking = true;
      _failure = null;
    });
    final origin = _origin ?? ref.read(providerOfLocation).location;
    final failure = await planRouteBetween(
      ref: ref,
      origin: origin,
      destination: destination,
    );
    if (!mounted) return;
    final plan = ref.read(providerOfMap).currentRoutePlan;
    if (failure == null &&
        plan != null &&
        plan.travelModeRoutes.containsKey(_mode) &&
        plan.selectedTravelMode != _mode) {
      ref.read(providerOfMap.notifier).updateSelectedTravelMode(_mode);
    }
    setState(() {
      _checking = false;
      _failure = failure;
    });
  }

  void _goThisWay() {
    final plan = ref.read(providerOfMap).currentRoutePlan;
    if (plan == null) return;
    if (!plan.isNavigating) {
      ref.read(providerOfMap.notifier).startNavigation();
    }
    ref.read(providerOfHomeTab.notifier).state = HomeTab.map;
    context.pop();
  }
}

/// The routes drawn on a plain grid, as on the boards: the chosen route in
/// blue, the others grey and dashed, start (blue dot), end (black dot) and
/// the alerts on the chosen route. Drawn from the route polylines, so it
/// needs no second map.
class _RoutePreview extends StatelessWidget {
  const _RoutePreview({
    required this.routes,
    required this.selectedIndex,
    required this.hazards,
    required this.origin,
    required this.destination,
  });

  final List<List<LatLng>> routes;
  final int selectedIndex;
  final List<Hazard> hazards;
  final LatLng origin;
  final LatLng destination;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.spMin),
      child: SizedBox(
        height: 190.spMin,
        width: double.infinity,
        child: CustomPaint(
          painter: _RoutePreviewPainter(
            routes: routes,
            selectedIndex: selectedIndex,
            hazards: hazards,
            origin: origin,
            destination: destination,
          ),
        ),
      ),
    );
  }
}

class _RoutePreviewPainter extends CustomPainter {
  _RoutePreviewPainter({
    required this.routes,
    required this.selectedIndex,
    required this.hazards,
    required this.origin,
    required this.destination,
  });

  final List<List<LatLng>> routes;
  final int selectedIndex;
  final List<Hazard> hazards;
  final LatLng origin;
  final LatLng destination;

  @override
  void paint(final Canvas canvas, final Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8EAED));
    final grid = Paint()
      ..color = const Color(0xFFDCDFE3)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final all = <LatLng>[origin, destination, for (final r in routes) ...r];
    var minLat = all.first.latitude, maxLat = all.first.latitude;
    var minLng = all.first.longitude, maxLng = all.first.longitude;
    for (final p in all) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    // Longitude degrees shrink with latitude; scale so shapes stay true.
    final lngScale = math.cos((minLat + maxLat) / 2 * math.pi / 180).abs();
    final spanX = math.max((maxLng - minLng) * lngScale, 1e-6);
    final spanY = math.max(maxLat - minLat, 1e-6);
    const pad = 28.0;
    final scale = math.min(
      (size.width - pad * 2) / spanX,
      (size.height - pad * 2) / spanY,
    );
    final offsetX = (size.width - spanX * scale) / 2;
    final offsetY = (size.height - spanY * scale) / 2;
    Offset project(final LatLng p) => Offset(
          offsetX + (p.longitude - minLng) * lngScale * scale,
          offsetY + (maxLat - p.latitude) * scale,
        );

    Path pathOf(final List<LatLng> points) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final o = project(points[i]);
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      return path;
    }

    final other = Paint()
      ..color = const Color(0xFF9AA3AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < routes.length; i++) {
      if (i == selectedIndex || routes[i].length < 2) continue;
      _drawDashed(canvas, pathOf(routes[i]), other);
    }
    if (selectedIndex < routes.length && routes[selectedIndex].length >= 2) {
      canvas.drawPath(
        pathOf(routes[selectedIndex]),
        Paint()
          ..color = const Color(0xFF2563EB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (final hazard in hazards) {
      final lat = hazard.latitude;
      final lng = hazard.longitude;
      if (lat == null || lng == null) continue;
      final o = project(LatLng(lat, lng));
      final clamped = Offset(
        o.dx.clamp(12.0, size.width - 12.0),
        o.dy.clamp(12.0, size.height - 12.0),
      );
      RouteHazardShapePainter.paintShape(
        canvas,
        clamped,
        22,
        routeHazardShapeKindOf(hazard),
        hazard.color == Colors.transparent
            ? const Color(0xFF8A93A0)
            : hazard.color,
      );
    }

    void dot(final Offset at, final Color color) {
      canvas
        ..drawCircle(at, 10, Paint()..color = Colors.white)
        ..drawCircle(at, 7, Paint()..color = color);
    }

    dot(project(origin), const Color(0xFF2563EB));
    dot(project(destination), const Color(0xFF1C1C1E));
  }

  void _drawDashed(final Canvas canvas, final Path path, final Paint paint) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = math.min(distance + 6, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) =>
      oldDelegate.routes != routes ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.hazards != hazards ||
      oldDelegate.origin != origin ||
      oldDelegate.destination != destination;
}
