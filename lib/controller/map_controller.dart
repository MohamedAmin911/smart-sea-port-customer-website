// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:final_project_customer_website/constants/apikeys.dart';
import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShipController extends GetxController {
  // Google Maps controller
  GoogleMapController? mapController;
  final OrderController orderController = Get.find<OrderController>();

  // Observables for reactive state management
  final sourceLatLng = Rx<LatLng?>(null);
  final destinationLatLng = Rx<LatLng?>(null);
  final shipLatLng = Rx<LatLng?>(null);
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  // --- NEW: A list to hold the points for our curved sea route ---
  final List<LatLng> seaRoutePoints = [];

  String? currentShipmentId;
  DatabaseReference? database;
  final String apiKey = KapiKeys.geocodingApiKey;
  Timer? movementTimer;
  final progress = 0.0.obs;
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? shipIcon;
  final iconsLoaded = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await _loadCustomIcons();
  }

  @override
  void onClose() {
    movementTimer?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  Future<void> _loadCustomIcons() async {
    try {
      sourceIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)), 'assets/png/port.png');
      destinationIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)), 'assets/png/port.png');
      shipIcon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(30, 30)), 'assets/png/ship.png');
      iconsLoaded.value = true;
      update();
    } catch (e) {}
  }

  Future<void> fetchInitialPosition(String shipmentId) async {
    try {
      final snapshot = await database!.once();
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        shipLatLng.value = LatLng(data['latitude'], data['longitude']);
        progress.value = data['progress'] ?? 0.0;
      } else {
        progress.value = 0.0;
        shipLatLng.value = sourceLatLng.value;
        await updateFirebasePosition(shipLatLng.value!, progress.value);
      }
    } catch (e) {}
  }

  Future<LatLng?> geocodeAddress(String address) async {
    final url = 'https://geocode.maps.co/search?q=$address&api_key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data.isNotEmpty) {
          final location = data[0];
          return LatLng(
              double.parse(location['lat']), double.parse(location['lon']));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- NEW: Generates a curved path between two points ---
  void _calculateSeaRoute(LatLng start, LatLng end) {
    seaRoutePoints.clear();
    const pointCount = 50; // More points create a smoother curve

    // Find a control point to create the curve.
    // This pushes the line away from the direct center.
    final midPoint = LatLng((start.latitude + end.latitude) / 2,
        (start.longitude + end.longitude) / 2);
    final controlPoint = LatLng(
        midPoint.latitude -
            (end.longitude - start.longitude) *
                0.2, // Adjust the multiplier for more/less curve
        midPoint.longitude + (end.latitude - start.latitude) * 0.2);

    for (int i = 0; i <= pointCount; i++) {
      final t = i / pointCount.toDouble();
      // Quadratic Bezier curve formula for a simple, nice-looking curve
      final lat = pow(1 - t, 2) * start.latitude +
          2 * (1 - t) * t * controlPoint.latitude +
          pow(t, 2) * end.latitude;
      final lng = pow(1 - t, 2) * start.longitude +
          2 * (1 - t) * t * controlPoint.longitude +
          pow(t, 2) * end.longitude;
      seaRoutePoints.add(LatLng(lat, lng));
    }
  }

  Future<void> initializeMap(String sourceAddress, String destinationAddress,
      String shipmentId) async {
    currentShipmentId = shipmentId;
    database = FirebaseDatabase.instance.ref('ship_positions/$shipmentId');

    progress.value = 0.0;
    shipLatLng.value = null;

    sourceLatLng.value = await geocodeAddress(sourceAddress);
    destinationLatLng.value = await geocodeAddress(destinationAddress);

    if (sourceLatLng.value == null || destinationLatLng.value == null) {
      return;
    }

    // --- MODIFIED: Calculate the curved route ---
    _calculateSeaRoute(sourceLatLng.value!, destinationLatLng.value!);

    await fetchInitialPosition(shipmentId);

    markers.clear();
    polylines.clear();

    markers.add(Marker(
        markerId: const MarkerId('source'),
        position: sourceLatLng.value!,
        infoWindow: const InfoWindow(title: 'Source'),
        icon: sourceIcon ?? BitmapDescriptor.defaultMarker));
    markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: destinationLatLng.value!,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: destinationIcon ?? BitmapDescriptor.defaultMarker));
    markers.add(Marker(
        markerId: const MarkerId('ship'),
        position: shipLatLng.value!,
        infoWindow: const InfoWindow(title: 'Ship'),
        icon: shipIcon ?? BitmapDescriptor.defaultMarker));

    // --- MODIFIED: Use the new seaRoutePoints for the polyline ---
    polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: seaRoutePoints,
      color: Kcolor.primary,
      width: 4,
    ));

    if (mapController != null) {
      // Fit map to bounds logic remains the same
    }
  }

  Future<void> updateFirebasePosition(LatLng position, double progress) async {
    try {
      await database!.set({
        'id': currentShipmentId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'progress': progress,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {}
  }

  // --- MODIFIED: The simulation now moves along the curved path ---
  void startShipMovement() async {
    if (!iconsLoaded.value) return;

    movementTimer?.cancel();
    movementTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seaRoutePoints.isEmpty) return;

      progress.value += 0.01; // Adjust for desired speed
      if (progress.value >= 1.0) {
        progress.value = 1.0;

        // --- THIS LOGIC HAS BEEN RESTORED ---
        if (currentShipmentId != null) {
          try {
            // Find the shipment in the OrderController's list
            final shipmentToUpdate = orderController.shipmentsList.firstWhere(
                (shipment) => shipment.shipmentId == currentShipmentId);

            // Check if it's currently in transit before updating
            if (shipmentToUpdate.shipmentStatus == ShipmentStatus.inTransit) {
              orderController.updateShipmentStatus(
                currentShipmentId!,
                ShipmentStatus.delivered,
              );
            }
          } catch (e) {
            // Handle case where shipment might not be in the list
            print("Could not find shipment to update status: $e");
          }
        }
        // --- END OF RESTORED LOGIC ---

        timer.cancel();
      }

      // Calculate the ship's position along the multi-point polyline
      final routeIndex = (progress.value * (seaRoutePoints.length - 1)).round();
      shipLatLng.value = seaRoutePoints[routeIndex];

      markers.removeWhere((m) => m.markerId.value == 'ship');
      markers.add(Marker(
        markerId: const MarkerId('ship'),
        position: shipLatLng.value!,
        infoWindow: const InfoWindow(title: 'Ship'),
        icon: shipIcon!,
      ));

      updateFirebasePosition(shipLatLng.value!, progress.value);

      // Optional: Camera follows the ship
      // mapController?.animateCamera(CameraUpdate.newLatLng(shipLatLng.value!));
    });
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
    update();
  }
}
