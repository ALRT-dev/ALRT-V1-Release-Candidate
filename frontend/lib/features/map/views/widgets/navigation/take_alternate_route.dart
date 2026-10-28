import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hazard_app/features/map/providers/location_provider.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/providers/states/map_provider_state.dart';
import 'package:hazard_app/features/map/views/widgets/navigation/route_hazard_shape.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';
import 'package:hazard_app/features/shared/utils/location_helper.dart';
import 'package:hazard_app/features/shared/views/screens/view_hazard_screen.dart';
import 'package:hazard_app/others/app_colors.dart';

/// The en route alert (prototype board "EnRouteAlert", rules.json enRoute):
/// while travelling, an alert that touches the road ahead pops up as a
/// sheet. "Ahead on your route" and the distance, the alert, then Avoid it
/// (a detour around it), View the alert, or Keep going.
class TakeAlternateRoute extends ConsumerStatefulWidget {
  const TakeAlternateRoute({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TakeAlternateRouteState();
}

class _TakeAlternateRouteState extends ConsumerState<TakeAlternateRoute> {
  static const _ink = Color(0xFF1C1C1E);
  static const _muted = Color(0xFF5C5C66);
  static const _routeBlue = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final hazard = ref.watch(
      providerOfMap.select(
        (s) => s.hazardCorridorsAhead.firstOrNull?.hazards.firstOrNull,
      ),
    );
    if (hazard == null) return const SizedBox.shrink();

    final color = hazard.color == Colors.transparent
        ? const Color(0xFF8A93A0)
        : hazard.color;
    final plain = (hazard.aiSummary ?? '').trim().isNotEmpty
        ? hazard.aiSummary!.trim()
        : (hazard.description ?? '').trim();
    final meta = routeHazardMetaOf(hazard);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.spMin)),
      ),
      padding: EdgeInsets.fromLTRB(20.spMin, 10.spMin, 20.spMin, 16.spMin),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.spMin,
                height: 4.spMin,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2.spMin),
                ),
              ),
            ),
            SizedBox(height: 14.spMin),
            Row(
              children: [
                Container(
                  width: 44.spMin,
                  height: 44.spMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12.spMin),
                  ),
                  child: RouteHazardShape(hazard: hazard, size: 28.spMin),
                ),
                SizedBox(width: 12.spMin),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AHEAD ON YOUR ROUTE${_distanceText(hazard)}',
                        style: TextStyle(
                          fontSize: 12.spMin,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: color,
                        ),
                      ),
                      SizedBox(height: 2.spMin),
                      Text(
                        hazard.title ?? hazard.category?.name ?? 'Alert',
                        style: TextStyle(
                          fontSize: 20.spMin,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (plain.isNotEmpty || meta.isNotEmpty) ...[
              SizedBox(height: 14.spMin),
              Container(
                padding: EdgeInsets.all(16.spMin),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18.spMin),
                  border: Border.all(
                    color: AppColors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (plain.isNotEmpty)
                      Text(
                        plain,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.spMin,
                          color: _ink,
                          height: 1.45,
                        ),
                      ),
                    if (meta.isNotEmpty) ...[
                      SizedBox(height: 8.spMin),
                      Text(
                        meta,
                        style: TextStyle(fontSize: 12.spMin, color: _muted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: 14.spMin),
            _avoidButton(),
            Consumer(
              builder: (context, ref, child) {
                final error = ref.watch(
                  providerOfMap.select(
                    (s) => s.takeAlternateRouteState.maybeWhen(
                      error: (message) => message,
                      orElse: () => null,
                    ),
                  ),
                );
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(top: 8.spMin),
                  child: Text(
                    error,
                    style: TextStyle(
                      fontSize: 13.spMin,
                      color: const Color(0xFFB3141F),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 10.spMin),
            Row(
              children: [
                Expanded(
                  child: _secondaryButton('View the alert', _handleView),
                ),
                SizedBox(width: 10.spMin),
                Expanded(
                  child: _secondaryButton('Keep going', _handleContinue),
                ),
              ],
            ),
            SizedBox(height: 12.spMin),
            Text(
              'Emergency Warnings always pop up. Other levels follow your '
              'notification level.',
              style: TextStyle(fontSize: 12.spMin, color: _muted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  /// " · 5.9 KM" from where the person is now to the alert.
  String _distanceText(final Hazard hazard) {
    final lat = hazard.latitude;
    final lng = hazard.longitude;
    if (lat == null || lng == null) return '';
    final here =
        ref.watch(providerOfMap.select((s) => s.currentNavigationLocation)) ??
        ref.read(providerOfLocation).location;
    final metres = calculateDistanceInMeters(
      here.latitude,
      here.longitude,
      lat,
      lng,
    );
    final text = metres >= 1000
        ? '${(metres / 1000).toStringAsFixed(1)} KM'
        : '${metres.round()} M';
    return ' · $text';
  }

  Widget _avoidButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(
          providerOfMap.select((s) => s.takeAlternateRouteState.isLoading),
        );
        return SizedBox(
          height: 54.spMin,
          child: FilledButton(
            onPressed: isLoading ? null : _handleTakeAlternateRoute,
            style: FilledButton.styleFrom(
              backgroundColor: _routeBlue,
              disabledBackgroundColor: _routeBlue.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.spMin),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 22.spMin,
                    height: 22.spMin,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Avoid it, find another way',
                    style: TextStyle(
                      fontSize: 16.spMin,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _secondaryButton(final String label, final VoidCallback onPressed) {
    return SizedBox(
      height: 48.spMin,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: Color(0xFFD9D6D0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.spMin),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _handleTakeAlternateRoute() {
    ref.read(providerOfMap.notifier).takeAlternateRoute();
  }

  /// Opens the alert ahead. Navigation keeps running underneath; back
  /// returns to it.
  void _handleView() {
    final corridors = ref.read(providerOfMap).hazardCorridorsAhead;
    if (corridors.isEmpty || corridors.first.hazards.isEmpty) return;
    final hazard = corridors.first.hazards.first;
    ref.read(providerOfMap.notifier).updateShowTakeAlternateRouteButton(false);
    context.push(
      ViewHazardScreen.route,
      extra: ViewHazardScreenArgs(hazard: hazard),
    );
  }

  void _handleContinue() {
    ref.read(providerOfMap.notifier).updateShowTakeAlternateRouteButton(false);
  }
}
