import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hazard_app/features/shared/models/hazard_model.dart';

class HazardClusterItem with ClusterItem {
  final Hazard hazard;

  HazardClusterItem(this.hazard);

  @override
  LatLng get location => LatLng(
    hazard.latitude ?? 0.0,
    hazard.longitude ?? 0.0,
  );

  @override
  String get geohash => location.toString(); // Let the library calculate geohash automatically
}
