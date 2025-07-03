// lib/services/polyline_service.dart
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/helper/app_constants.dart';

class PolylineService {
  static Future<List<LatLng>> getPolylinePoints({
    required LatLng origin,
    required LatLng destination,
  }) async {
    List<LatLng> coordinates = [];

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: AppConstants.googleMapsApiKey,
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
        optimizeWaypoints: true,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        coordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    return coordinates;
  }
}