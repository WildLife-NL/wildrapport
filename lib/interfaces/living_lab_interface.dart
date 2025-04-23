import 'package:latlong2/latlong.dart';
import 'package:wildrapport/models/living_lab_area.dart';

abstract class LivingLabInterface {
  List<LivingLabArea> getAllLivingLabs();
  LivingLabArea? getLivingLabById(String id);
  LivingLabArea? getLivingLabByLocation(LatLng location);
  bool isLocationInAnyLivingLab(LatLng location);
}