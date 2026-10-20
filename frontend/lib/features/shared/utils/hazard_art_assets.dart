import 'package:hazard_app/features/shared/enums/hazard_severity_band_types.dart';
import 'package:hazard_app/features/shared/models/hazard_category_model.dart';

/// Every hazard artwork bundled in assets/images/hazards (family/name).
/// Used when the category has no image from the server, which is the usual
/// state on the TEST backend: pins there fell back to the generic `other`
/// artwork, so a planned burn showed a plain triangle instead of the dotted
/// diamond with the flame (phone review, 15 Oct 2026).
const bundledHazardArt = <String>{
    'aws/bushfire_action',
    'aws/bushfire_critical',
    'aws/bushfire_info',
    'aws/bushfire_monitor',
    'aws/cyclone_action',
    'aws/cyclone_critical',
    'aws/cyclone_info',
    'aws/cyclone_monitor',
    'aws/damagingWinds_action',
    'aws/damagingWinds_critical',
    'aws/damagingWinds_info',
    'aws/damagingWinds_monitor',
    'aws/earthquake_action',
    'aws/earthquake_critical',
    'aws/earthquake_info',
    'aws/earthquake_monitor',
    'aws/extremeHeat_action',
    'aws/extremeHeat_critical',
    'aws/extremeHeat_info',
    'aws/extremeHeat_monitor',
    'aws/flood_action',
    'aws/flood_critical',
    'aws/flood_info',
    'aws/flood_monitor',
    'aws/other_action',
    'aws/other_critical',
    'aws/other_info',
    'aws/other_monitor',
    'aws/storm_action',
    'aws/storm_critical',
    'aws/storm_info',
    'aws/storm_monitor',
    'non_aws/bushfire_info',
    'non_aws/bushfire_monitor',
    'non_aws/chemicalSpill_action',
    'non_aws/chemicalSpill_critical',
    'non_aws/chemicalSpill_info',
    'non_aws/chemicalSpill_monitor',
    'non_aws/communityInfo_action',
    'non_aws/communityInfo_critical',
    'non_aws/communityInfo_info',
    'non_aws/communityInfo_monitor',
    'non_aws/communityInfo_user',
    'non_aws/crash_action',
    'non_aws/crash_critical',
    'non_aws/crash_info',
    'non_aws/crash_monitor',
    'non_aws/fireStatus_active',
    'non_aws/fireStatus_beingControlled',
    'non_aws/fireStatus_closed',
    'non_aws/fireStatus_underControl',
    'non_aws/hazmatSpill_action',
    'non_aws/hazmatSpill_critical',
    'non_aws/hazmatSpill_info',
    'non_aws/hazmatSpill_monitor',
    'non_aws/healthAndAir_action',
    'non_aws/healthAndAir_critical',
    'non_aws/healthAndAir_info',
    'non_aws/healthAndAir_monitor',
    'non_aws/healthAndAir_user',
    'non_aws/otherFire_action',
    'non_aws/otherFire_critical',
    'non_aws/otherFire_info',
    'non_aws/otherFire_monitor',
    'non_aws/other_action',
    'non_aws/other_critical',
    'non_aws/other_info',
    'non_aws/other_monitor',
    'non_aws/other_unknown',
    'non_aws/other_user',
    'non_aws/plannedBurn_action',
    'non_aws/plannedBurn_critical',
    'non_aws/plannedBurn_info',
    'non_aws/plannedBurn_monitor',
    'non_aws/pollen_action',
    'non_aws/pollen_critical',
    'non_aws/pollen_info',
    'non_aws/pollen_monitor',
    'non_aws/powerOutage_action',
    'non_aws/powerOutage_critical',
    'non_aws/powerOutage_info',
    'non_aws/powerOutage_monitor',
    'non_aws/powerOutage_unknown',
    'non_aws/rescueMarine_action',
    'non_aws/rescueMarine_critical',
    'non_aws/rescueMarine_info',
    'non_aws/rescueMarine_monitor',
    'non_aws/rescueRoad_action',
    'non_aws/rescueRoad_critical',
    'non_aws/rescueRoad_info',
    'non_aws/rescueRoad_monitor',
    'non_aws/securityAndCrime_action',
    'non_aws/securityAndCrime_critical',
    'non_aws/securityAndCrime_info',
    'non_aws/securityAndCrime_monitor',
    'non_aws/securityAndCrime_user',
    'non_aws/smoke_action',
    'non_aws/smoke_critical',
    'non_aws/smoke_info',
    'non_aws/smoke_monitor',
    'non_aws/structuralFire_action',
    'non_aws/structuralFire_critical',
    'non_aws/structuralFire_info',
    'non_aws/structuralFire_monitor',
    'non_aws/trafficAndTransport_action',
    'non_aws/trafficAndTransport_critical',
    'non_aws/trafficAndTransport_info',
    'non_aws/trafficAndTransport_monitor',
    'non_aws/trafficAndTransport_user',
    'non_aws/treeDown_action',
    'non_aws/treeDown_critical',
    'non_aws/treeDown_info',
    'non_aws/treeDown_monitor',
    'non_aws/utilitiesAndInfrastructure_action',
    'non_aws/utilitiesAndInfrastructure_critical',
    'non_aws/utilitiesAndInfrastructure_info',
    'non_aws/utilitiesAndInfrastructure_monitor',
    'non_aws/utilitiesAndInfrastructure_unknown',
    'non_aws/utilitiesAndInfrastructure_user',
    'non_aws/weatherAndEnvironment_action',
    'non_aws/weatherAndEnvironment_critical',
    'non_aws/weatherAndEnvironment_info',
    'non_aws/weatherAndEnvironment_monitor',
    'non_aws/weatherAndEnvironment_unknown',
    'non_aws/weatherAndEnvironment_user',
};

/// The most specific bundled artwork id for [category] (itself, then its
/// parents) at [band], or `other` when none is bundled.
String bundledHazardArtId(
  final HazardCategory? category,
  final HazardSeverityBand band, {
  required final bool isAwsCompliant,
}) {
  final family = isAwsCompliant ? 'aws' : 'non_aws';
  for (HazardCategory? node = category; node != null; node = node.parent) {
    if (bundledHazardArt.contains('$family/${node.id}_${band.name}')) {
      return node.id;
    }
  }
  return 'other';
}

/// Asset path of the bundled artwork for [category] at [band].
String bundledHazardArtPath(
  final HazardCategory? category,
  final HazardSeverityBand band, {
  required final bool isAwsCompliant,
}) {
  final id = bundledHazardArtId(category, band, isAwsCompliant: isAwsCompliant);
  final family = isAwsCompliant ? 'aws' : 'non_aws';
  return 'assets/images/hazards/$family/${id}_${band.name}.png';
}
