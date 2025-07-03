import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerHelper {
  static Future<List<BitmapDescriptor>> loadCustomMarkers() async {
    try {
      final iconResult = await Future.wait([
        BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(48, 48)),
          'assets/sourcemarker.png',
        ),
        BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(48, 48)),
          'assets/destinationmarker.png',
        ),

        BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(48, 48)),
          'assets/movingmarker.png',
        ),
      ]);
      return iconResult;
    } catch (e) {
      debugPrint("Error loading markers: $e");
      return [BitmapDescriptor.defaultMarker, BitmapDescriptor.defaultMarker];
    }
  }
}
