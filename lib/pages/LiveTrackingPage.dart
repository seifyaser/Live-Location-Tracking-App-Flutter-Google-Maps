import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/cubit/map_cubit.dart';
import 'package:project/cubit/map_state.dart';
import 'package:project/services/map_style_service.dart';
import 'package:project/widgets/customSnackbar.dart';
import '../helper/marker_helper.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor movingIcon;

  final Completer<GoogleMapController> _mapController = Completer();
  bool useCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  Future<void> _initMarkers() async {
    final icons = await MarkerHelper.loadCustomMarkers();
    setState(() {
      sourceIcon = icons[0];
      destinationIcon = icons[1];
      movingIcon = icons[0]; // you can use a separate icon if you want
    });
  }

  Future<void> _setMapStyle() async {
    final style = await MapStyleService.loadMapStyle(context);
    final controller = await _mapController.future;
    controller.setMapStyle(style);
  }

  Future<void> _moveCameraTo(LatLng position) async {
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        actions: [
          Row(
            children: [
              const Text("Use My Location"),
              Switch(
                value: useCurrentLocation,
                onChanged: (value) async {
                  setState(() => useCurrentLocation = value);
                  final cubit = context.read<TrackingCubit>();
                  cubit.reset();
                  if (value) {
                    await cubit.initLiveTracking(withInitialLocation: true);
                  } else {
                    CustomSnackbar.show(
                      context,
                      message: 'Tap the map to set the start point',
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          if (state.movingPosition != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _moveCameraTo(state.movingPosition!);
            });
          }

          return Stack(
            children: [
              GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(30.0444, 31.2357), // Default: Cairo
                  zoom: 12,
                ),
                onMapCreated: (controller) async {
                  _mapController.complete(controller);
                  await _setMapStyle();
                },
                onTap: (LatLng tappedPoint) {
                  final cubit = context.read<TrackingCubit>();
                  if (useCurrentLocation) {
                    if (!state.selectingSource) {
                      cubit.setDestination(tappedPoint);
                    }
                  } else {
                    if (state.selectingSource) {
                      cubit.setSource(tappedPoint);
                    } else {
                      cubit.setDestination(tappedPoint);
                    }
                  }
                },
                markers: {
                  if (state.source != null)
                    Marker(
                      markerId: const MarkerId("source"),
                      position: state.source!,
                      icon: sourceIcon,
                    ),
                  if (state.destination != null)
                    Marker(
                      markerId: const MarkerId("destination"),
                      position: state.destination!,
                      icon: destinationIcon,
                    ),
                  if (state.movingPosition != null)
                    Marker(
                      markerId: const MarkerId("moving"),
                      position: state.movingPosition!,
                      icon: movingIcon,
                    ),
                },
                polylines: {
                  if (state.polylineCoordinates.isNotEmpty)
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: state.polylineCoordinates,
                      color: Colors.redAccent,
                      width: 6,
                    ),
                },
              ),
              if (state.distanceInKm != null)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Distance: ${state.distanceInKm!.toStringAsFixed(2)} km',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cubit = context.read<TrackingCubit>();
          cubit.reset();
          if (useCurrentLocation) {
            await cubit.initLiveTracking(withInitialLocation: true);
          } else {
            CustomSnackbar.show(
              context,
              message: 'Start again: Tap the map to set the start point',
            );
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
