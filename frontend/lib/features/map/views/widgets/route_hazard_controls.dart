// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/map/providers/map_provider.dart';
import 'package:hazard_app/features/map/utils/hazard_avoidance_helper.dart';
import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';
import 'package:hazard_app/others/app_colors.dart';

/// Widget that shows route safety information and hazard avoidance controls
class RouteHazardControls extends ConsumerStatefulWidget {
  const RouteHazardControls({
    super.key,
    required this.origin,
    required this.routePoints,
    this.onRouteRequested,
  });

  final LatLng origin;
  final List<LatLng> routePoints;
  final VoidCallback? onRouteRequested;

  @override
  ConsumerState<RouteHazardControls> createState() =>
      _RouteHazardControlsState();
}

class _RouteHazardControlsState extends ConsumerState<RouteHazardControls> {
  bool _avoidHazards = true;
  RouteHazardSummary? _routeHazardSummary;

  @override
  void initState() {
    super.initState();
    _analyzeRoute();
  }

  @override
  void didUpdateWidget(RouteHazardControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origin != widget.origin ||
        oldWidget.routePoints != widget.routePoints) {
      _analyzeRoute();
    }
  }

  void _analyzeRoute() {
    final hazards = ref.read(providerOfMap).hazards;
    _routeHazardSummary = HazardAvoidanceHelper.analyzeRouteHazards(
      hazards: hazards,
      routePoints: widget.routePoints,
    );
    setState(() {});
  }

  void _requestRoute() {
    // ref.read(providerOfMap.notifier).getRoute(
    //       origin: widget.origin,
    //       destination: widget.routePoints.last,
    //       avoidHazards: _avoidHazards,
    //     );
    widget.onRouteRequested?.call();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _routeHazardSummary;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.route,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Route Planning',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hazard Summary
            if (summary != null) ...[
              _buildHazardSummary(summary),
              const SizedBox(height: 16),
            ],

            // Hazard Avoidance Toggle
            Row(
              children: [
                Switch(
                  value: _avoidHazards,
                  onChanged: (value) {
                    setState(() {
                      _avoidHazards = value;
                    });
                  },
                  activeThumbColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avoid Hazards',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _avoidHazards
                            ? 'Route will avoid known hazards when possible'
                            : 'Standard route (hazards not considered)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Get Route Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _requestRoute,
                icon: const Icon(Icons.directions),
                label: Text(_avoidHazards ? 'Get Safe Route' : 'Get Route'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _avoidHazards
                      ? AppColors.advice
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHazardSummary(RouteHazardSummary summary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(summary.riskLevel),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(summary.riskLevel),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForRiskLevel(summary.riskLevel),
                color: _getIconColor(summary.riskLevel),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Route Safety Analysis',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(summary.riskLevel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary.summaryMessage,
            style: TextStyle(
              fontSize: 13,
              color: _getTextColor(summary.riskLevel),
            ),
          ),
          if (summary.hasAnyHazards) ...[
            const SizedBox(height: 8),
            _buildHazardBreakdown(summary),
          ],
        ],
      ),
    );
  }

  Widget _buildHazardBreakdown(RouteHazardSummary summary) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (summary.emergencyHazards > 0)
          _buildHazardChip(
            '${summary.emergencyHazards} Emergency',
            HazardSeverity.emergency,
          ),
        if (summary.highRiskHazards > 0)
          _buildHazardChip(
            '${summary.highRiskHazards} High Risk',
            HazardSeverity.watchAndAct,
          ),
        if (summary.mediumRiskHazards > 0)
          _buildHazardChip(
            '${summary.mediumRiskHazards} Medium Risk',
            HazardSeverity.advice,
          ),
        if (summary.lowRiskHazards > 0)
          _buildHazardChip(
            '${summary.lowRiskHazards} Info',
            HazardSeverity.info,
          ),
      ],
    );
  }

  Widget _buildHazardChip(String label, HazardSeverity severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: severity.colorAws.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severity.colorAws.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: severity.colorAws,
        ),
      ),
    );
  }

  Color _getBackgroundColor(RouteRiskLevel riskLevel) {
    switch (riskLevel) {
      case RouteRiskLevel.emergency:
        return AppColors.emergency.withValues(alpha: 0.1);
      case RouteRiskLevel.high:
        return AppColors.watchAndAct.withValues(alpha: 0.1);
      case RouteRiskLevel.medium:
        return AppColors.advice.withValues(alpha: 0.1);
      case RouteRiskLevel.low:
        return AppColors.info.withValues(alpha: 0.1);
      case RouteRiskLevel.safe:
        return Colors.green.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor(RouteRiskLevel riskLevel) {
    switch (riskLevel) {
      case RouteRiskLevel.emergency:
        return AppColors.emergency.withValues(alpha: 0.3);
      case RouteRiskLevel.high:
        return AppColors.watchAndAct.withValues(alpha: 0.3);
      case RouteRiskLevel.medium:
        return AppColors.advice.withValues(alpha: 0.3);
      case RouteRiskLevel.low:
        return AppColors.info.withValues(alpha: 0.3);
      case RouteRiskLevel.safe:
        return Colors.green.withValues(alpha: 0.3);
    }
  }

  Color _getTextColor(RouteRiskLevel riskLevel) {
    switch (riskLevel) {
      case RouteRiskLevel.emergency:
        return AppColors.emergency;
      case RouteRiskLevel.high:
        return AppColors.watchAndAct;
      case RouteRiskLevel.medium:
        return AppColors.advice;
      case RouteRiskLevel.low:
        return AppColors.info;
      case RouteRiskLevel.safe:
        return Colors.green.shade700;
    }
  }

  Color _getIconColor(RouteRiskLevel riskLevel) {
    return _getTextColor(riskLevel);
  }

  IconData _getIconForRiskLevel(RouteRiskLevel riskLevel) {
    switch (riskLevel) {
      case RouteRiskLevel.emergency:
        return Icons.error;
      case RouteRiskLevel.high:
        return Icons.warning;
      case RouteRiskLevel.medium:
        return Icons.info;
      case RouteRiskLevel.low:
        return Icons.info_outline;
      case RouteRiskLevel.safe:
        return Icons.check_circle;
    }
  }
}
