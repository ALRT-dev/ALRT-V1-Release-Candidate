import 'package:hazard_app/features/shared/enums/hazard_severity_types.dart';

/// Bundled quick-report taxonomy (locked spec: chips are observations, not
/// conclusions). This is the app-side fallback copy the spec calls for —
/// the served `GET /v1/taxonomy` version can replace it later without a
/// store release changing behaviour.
class ReportChip {
  const ReportChip({
    required this.id,
    required this.label,
    this.severityDefault,
    String? headline,
  }) : _headline = headline;

  final String id;
  final String label;

  /// 0 = minor, 1 = significant, 2 = dangerous. Null contributes nothing
  /// to the pre-selection ("Something else" carries null by spec).
  final int? severityDefault;

  final String? _headline;
  String get headline => _headline ?? label;

  bool get isOther => id.endsWith('_other');
}

/// The three community severity wordings ("How would you describe it?").
/// Maps onto the non-AWS severity tiers the backend already stores.
enum ReportSeverityWording {
  minor(HazardSeverity.advice, 'Minor', 'worth knowing'),
  significant(HazardSeverity.watchAndAct, 'Significant', 'consider avoiding'),
  dangerous(HazardSeverity.emergency, 'Dangerous', 'risk to people');

  const ReportSeverityWording(this.severity, this.label, this.sub);

  final HazardSeverity severity;
  final String label;
  final String sub;

  static ReportSeverityWording? fromDefault(final int? severityDefault) {
    return switch (severityDefault) {
      0 => ReportSeverityWording.minor,
      1 => ReportSeverityWording.significant,
      2 => ReportSeverityWording.dangerous,
      _ => null,
    };
  }
}

const _somethingElseLabel = 'Something else';

const _floodChips = [
  ReportChip(id: 'wx_flooded_road', label: 'Flooded road', severityDefault: 1, headline: 'Flooded road'),
  ReportChip(id: 'wx_water_rising', label: 'Water rising', severityDefault: 2, headline: 'Water rising'),
  ReportChip(id: 'wx_water_over_path', label: 'Water over path', severityDefault: 0, headline: 'Water over path'),
  ReportChip(id: 'wx_drain_overflowing', label: 'Drain overflowing', severityDefault: 0, headline: 'Drain overflowing'),
  ReportChip(id: 'wx_car_stuck_water', label: 'Vehicle stuck in water', severityDefault: 2, headline: 'Vehicle stuck in floodwater'),
  ReportChip(id: 'wx_other', label: _somethingElseLabel),
];

const _fireChips = [
  ReportChip(id: 'fi_smoke_visible', label: 'Smoke visible', severityDefault: 1, headline: 'Smoke visible'),
  ReportChip(id: 'fi_flames_visible', label: 'Flames visible', severityDefault: 2, headline: 'Flames visible'),
  ReportChip(id: 'fi_smell_of_smoke', label: 'Smell of smoke', severityDefault: 0, headline: 'Smell of smoke'),
  ReportChip(id: 'fi_embers_falling', label: 'Embers falling', severityDefault: 2, headline: 'Embers falling'),
  ReportChip(id: 'fi_grass_fire', label: 'Grass fire', severityDefault: 1, headline: 'Grass fire'),
  ReportChip(id: 'fi_other', label: _somethingElseLabel),
];

// Weather & Environment per the V3.1 mock.
const _weatherChips = [
  ReportChip(id: 'wx_water_rising', label: 'Water rising', severityDefault: 2, headline: 'Water rising'),
  ReportChip(id: 'wx_flash_flooding', label: 'Flash flooding', severityDefault: 2, headline: 'Flash flooding'),
  ReportChip(id: 'wx_flooded_road', label: 'Flooded road', severityDefault: 1, headline: 'Flooded road'),
  ReportChip(id: 'wx_fallen_tree', label: 'Fallen tree', severityDefault: 1, headline: 'Fallen tree'),
  ReportChip(id: 'wx_storm_damage', label: 'Storm damage', severityDefault: 1, headline: 'Storm damage'),
  ReportChip(id: 'wx_other', label: _somethingElseLabel),
];

const _trafficChips = [
  ReportChip(id: 'tr_crash', label: 'Crash', severityDefault: 1, headline: 'Crash'),
  ReportChip(id: 'tr_road_blocked', label: 'Road blocked', severityDefault: 1, headline: 'Road blocked'),
  ReportChip(id: 'tr_hazard_on_road', label: 'Hazard on road', severityDefault: 1, headline: 'Hazard on road'),
  ReportChip(id: 'tr_heavy_congestion', label: 'Heavy congestion', severityDefault: 0, headline: 'Heavy congestion'),
  ReportChip(id: 'tr_signals_out', label: 'Traffic lights out', severityDefault: 1, headline: 'Traffic lights out'),
  ReportChip(id: 'tr_other', label: _somethingElseLabel),
];

const _safetyChips = [
  ReportChip(id: 'sa_suspicious_activity', label: 'Suspicious activity', severityDefault: 0, headline: 'Suspicious activity'),
  ReportChip(id: 'sa_people_in_danger', label: 'People in danger', severityDefault: 2, headline: 'People in danger'),
  ReportChip(id: 'sa_property_damage', label: 'Property damage', severityDefault: 0, headline: 'Property damage'),
  ReportChip(id: 'sa_aggressive_behaviour', label: 'Aggressive behaviour', severityDefault: 1, headline: 'Aggressive behaviour'),
  ReportChip(id: 'sa_other', label: _somethingElseLabel),
];

const _healthChips = [
  ReportChip(id: 'he_person_collapsed', label: 'Person collapsed', severityDefault: 2, headline: 'Person collapsed'),
  ReportChip(id: 'he_injury', label: 'Someone injured', severityDefault: 1, headline: 'Someone injured'),
  ReportChip(id: 'he_air_quality', label: 'Poor air quality', severityDefault: 0, headline: 'Poor air quality'),
  ReportChip(id: 'he_other', label: _somethingElseLabel),
];

const _environmentChips = [
  ReportChip(id: 'en_chemical_smell', label: 'Chemical smell', severityDefault: 1, headline: 'Chemical smell'),
  ReportChip(id: 'en_spill_or_leak', label: 'Spill or leak', severityDefault: 1, headline: 'Spill or leak'),
  ReportChip(id: 'en_dead_wildlife', label: 'Dead wildlife', severityDefault: 0, headline: 'Dead wildlife'),
  ReportChip(id: 'en_erosion_landslip', label: 'Erosion or landslip', severityDefault: 1, headline: 'Erosion or landslip'),
  ReportChip(id: 'en_other', label: _somethingElseLabel),
];

const _utilityChips = [
  ReportChip(id: 'ut_power_out', label: 'Power out', severityDefault: 0, headline: 'Power outage'),
  ReportChip(id: 'ut_water_main', label: 'Burst water main', severityDefault: 1, headline: 'Burst water main'),
  ReportChip(id: 'ut_gas_smell', label: 'Smell of gas', severityDefault: 2, headline: 'Smell of gas'),
  ReportChip(id: 'ut_other', label: _somethingElseLabel),
];

const _defaultChips = [
  ReportChip(id: 'ge_hazard_visible', label: 'Hazard visible', severityDefault: 0, headline: 'Hazard'),
  ReportChip(id: 'ge_area_unsafe', label: 'Area looks unsafe', severityDefault: 1, headline: 'Unsafe area'),
  ReportChip(id: 'ge_blocking_access', label: 'Blocking access', severityDefault: 1, headline: 'Access blocked'),
  ReportChip(id: 'ge_other', label: _somethingElseLabel),
];

/// Keyword-matches the server category name to a bundled chip set. The
/// served taxonomy keys on category ids; bundled fallback can only key on
/// names, which is fine for the fixed AU category list.
List<ReportChip> chipsForCategoryName(final String? categoryName) {
  final name = categoryName?.toLowerCase() ?? '';
  if (name.contains('flood') || name.contains('water')) return _floodChips;
  if (name.contains('fire') || name.contains('smoke') || name.contains('bush')) {
    return _fireChips;
  }
  if (name.contains('storm') ||
      name.contains('weather') ||
      name.contains('wind') ||
      name.contains('cyclone')) {
    return _weatherChips;
  }
  if (name.contains('traffic') ||
      name.contains('road') ||
      name.contains('transport') ||
      name.contains('crash')) {
    return _trafficChips;
  }
  if (name.contains('crime') ||
      name.contains('safety') ||
      name.contains('police') ||
      name.contains('security')) {
    return _safetyChips;
  }
  if (name.contains('health') || name.contains('medical')) return _healthChips;
  if (name.contains('environment') ||
      name.contains('chemical') ||
      name.contains('pollution') ||
      name.contains('hazmat')) {
    return _environmentChips;
  }
  if (name.contains('power') ||
      name.contains('utilit') ||
      name.contains('outage') ||
      name.contains('infrastructure')) {
    return _utilityChips;
  }
  return _defaultChips;
}
