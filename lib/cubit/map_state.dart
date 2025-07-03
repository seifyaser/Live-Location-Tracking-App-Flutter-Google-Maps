// tracking_state.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';



class TrackingState {
  final LatLng? source;
  final LatLng? destination;
  final LatLng? movingPosition;
  final List<LatLng> polylineCoordinates;
  final double? distanceInKm;
  final bool selectingSource;

  const TrackingState({
    this.source,
    this.destination,
    this.movingPosition,
    this.polylineCoordinates = const [],
    this.distanceInKm,
    this.selectingSource = true,
  });

  factory TrackingState.initial() => const TrackingState();

  TrackingState copyWith({
    LatLng? source,
    LatLng? destination,
    LatLng? movingPosition,
    List<LatLng>? polylineCoordinates,
    double? distanceInKm,
    bool? selectingSource,
  }) {
    return TrackingState(
      source: source ?? this.source,
      destination: destination ?? this.destination,
      movingPosition: movingPosition ?? this.movingPosition,
      polylineCoordinates: polylineCoordinates ?? this.polylineCoordinates,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      selectingSource: selectingSource ?? this.selectingSource,
    );
  }
}
