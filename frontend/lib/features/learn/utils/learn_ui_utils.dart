import 'package:flutter/material.dart';
import 'package:hazard_app/others/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Maps a backend icon key (e.g. `flame`, `droplets`) to a Lucide icon.
///
/// Falls back to a book icon for unknown/missing keys so topics never
/// render without an icon.
IconData learnIconForKey(final String? key) {
  switch (key?.trim().toLowerCase()) {
    case 'flame':
    case 'fire':
    case 'bushfire':
      return LucideIcons.flame;
    case 'droplets':
    case 'droplet':
    case 'flood':
      return LucideIcons.droplets;
    case 'wind':
    case 'storm':
      return LucideIcons.wind;
    case 'tornado':
    case 'cyclone':
      return LucideIcons.tornado;
    case 'zap':
    case 'lightning':
      return LucideIcons.zap;
    case 'cloud-lightning':
    case 'cloudlightning':
    case 'thunderstorm':
      return LucideIcons.cloudLightning;
    case 'cloud-rain':
    case 'cloudrain':
    case 'rain':
      return LucideIcons.cloudRain;
    case 'waves':
    case 'tsunami':
    case 'surf':
      return LucideIcons.waves;
    case 'thermometer':
    case 'heat':
    case 'heatwave':
      return LucideIcons.thermometer;
    case 'sun':
      return LucideIcons.sun;
    case 'snowflake':
    case 'snow':
      return LucideIcons.snowflake;
    case 'cloud-snow':
    case 'cloudsnow':
      return LucideIcons.cloudSnow;
    case 'mountain':
    case 'landslide':
      return LucideIcons.mountain;
    case 'earthquake':
    case 'land-plot':
    case 'landplot':
      return LucideIcons.landPlot;
    case 'haze':
    case 'smoke':
      return LucideIcons.haze;
    case 'triangle-alert':
    case 'trianglealert':
    case 'alert-triangle':
    case 'alert':
      return LucideIcons.triangleAlert;
    case 'siren':
    case 'emergency':
      return LucideIcons.siren;
    case 'shield':
      return LucideIcons.shield;
    case 'shield-check':
    case 'shieldcheck':
      return LucideIcons.shieldCheck;
    case 'heart-pulse':
    case 'heartpulse':
    case 'first-aid':
    case 'medical':
      return LucideIcons.heartPulse;
    case 'briefcase-medical':
    case 'briefcasemedical':
      return LucideIcons.briefcaseMedical;
    case 'house':
    case 'home':
      return LucideIcons.house;
    case 'car':
    case 'road':
      return LucideIcons.car;
    case 'phone-call':
    case 'phonecall':
    case 'phone':
      return LucideIcons.phoneCall;
    case 'radio':
      return LucideIcons.radio;
    case 'battery-charging':
    case 'batterycharging':
    case 'power':
      return LucideIcons.batteryCharging;
    case 'plug-zap':
    case 'plugzap':
    case 'outage':
      return LucideIcons.plugZap;
    case 'package-open':
    case 'packageopen':
    case 'kit':
      return LucideIcons.packageOpen;
    case 'fire-extinguisher':
    case 'fireextinguisher':
      return LucideIcons.fireExtinguisher;
    case 'life-buoy':
    case 'lifebuoy':
      return LucideIcons.lifeBuoy;
    case 'map':
      return LucideIcons.map;
    case 'compass':
      return LucideIcons.compass;
    case 'book-open':
    case 'bookopen':
    case 'book':
      return LucideIcons.bookOpen;
    default:
      return LucideIcons.bookOpen;
  }
}

/// Parses a backend hex color string (`#F26522`, `F26522`, `#FFF26522`)
/// into a [Color], falling back to [fallback] when missing or malformed.
Color learnColorFromHex(
  final String? hex, {
  final Color fallback = AppColors.orange,
}) {
  final raw = hex?.trim().replaceFirst('#', '');
  if (raw == null || raw.isEmpty) return fallback;

  final normalized = raw.length == 6 ? 'FF$raw' : raw;
  if (normalized.length != 8) return fallback;

  final value = int.tryParse(normalized, radix: 16);
  if (value == null) return fallback;

  return Color(value);
}
