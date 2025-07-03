// tracking_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project/cubit/map_state.dart';
import '../services/polyline_service.dart';


class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit() : super(TrackingState.initial());

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  Future<void> initLiveTracking({bool withInitialLocation = false}) async {
    final serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled && !await _location.requestService()) return;

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    if (withInitialLocation) {
      final current = await _location.getLocation();
      final latLng = LatLng(current.latitude!, current.longitude!);
      emit(state.copyWith(source: latLng, movingPosition: latLng, selectingSource: false));
    }

    _locationSubscription?.cancel();
    _locationSubscription = _location.onLocationChanged.listen((locationData) async {
      final moving = LatLng(locationData.latitude!, locationData.longitude!);
      emit(state.copyWith(movingPosition: moving));
      if (state.destination != null) {
        await _drawPolyline();
        _calculateDistance();
      }
    });
  }

  void setSource(LatLng pos) {
    emit(state.copyWith(source: pos, movingPosition: pos, selectingSource: false));
  }

  void setDestination(LatLng pos) async {
    emit(state.copyWith(destination: pos));
    await _drawPolyline();
    _calculateDistance();
  }

  Future<void> _drawPolyline() async {
  if (state.movingPosition == null || state.destination == null) return;

  final polyline = await PolylineService.getPolylinePoints(
    origin: state.movingPosition!, 
    destination: state.destination!,
  );

  emit(state.copyWith(polylineCoordinates: polyline));
}


  void _calculateDistance() {
    if (state.movingPosition == null || state.destination == null) return;

    final dist = Geolocator.distanceBetween(
      state.movingPosition!.latitude,
      state.movingPosition!.longitude,
      state.destination!.latitude,
      state.destination!.longitude,
    );

    emit(state.copyWith(distanceInKm: dist / 1000));
  }

  void reset() {
    emit(TrackingState.initial());
    _locationSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }
}
