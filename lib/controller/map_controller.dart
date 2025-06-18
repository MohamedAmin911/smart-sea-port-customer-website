// ignore_for_file: deprecated_member_use

import 'dart:async';
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

  // Current shipment ID
  String? currentShipmentId;

  // Firebase Realtime Database reference (will be set per shipment)
  DatabaseReference? database;

  // API key for geocoding
  final String apiKey = KapiKeys.geocodingApiKey;

  // Timer for ship movement
  Timer? movementTimer;

  // Current progress of ship (0.0 to 1.0)
  final progress = 0.0.obs;

  // Custom marker icons
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? shipIcon;

  // Flag to ensure icons are loaded
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

  // Load custom marker icons
  Future<void> _loadCustomIcons() async {
    try {
      sourceIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/png/port.png',
      );
      destinationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/png/port.png',
      );
      shipIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(30, 30)),
        'assets/png/ship.png',
      );
      iconsLoaded.value = true;
      update();
    } catch (e) {}
  }

  // Fetch initial ship position from Firebase for a specific shipment
  Future<void> fetchInitialPosition(String shipmentId) async {
    try {
      final snapshot = await database!.once();
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        shipLatLng.value = LatLng(data['latitude'], data['longitude']);
        progress.value = data['progress'] ?? 0.0;
      } else {
        // No existing data, initialize with source position
        progress.value = 0.0;
        shipLatLng.value = sourceLatLng.value;
        await updateFirebasePosition(shipLatLng.value!, progress.value);
      }
    } catch (e) {}
  }

  // Geocode address to LatLng
  Future<LatLng?> geocodeAddress(String address) async {
    final url = 'https://geocode.maps.co/search?q=$address&api_key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data[0];
        return LatLng(
          double.parse(location['lat']),
          double.parse(location['lon']),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Initialize map with source and destination for a specific shipment
  Future<void> initializeMap(
    String sourceAddress,
    String destinationAddress,
    String shipmentId,
  ) async {
    // Set shipment-specific database reference
    currentShipmentId = shipmentId;
    database = FirebaseDatabase.instance.ref('ship_positions/$shipmentId');

    // Reset progress and ship position for new shipment
    progress.value = 0.0;
    shipLatLng.value = null;

    // Geocode source and destination
    sourceLatLng.value = await geocodeAddress(sourceAddress);
    destinationLatLng.value = await geocodeAddress(destinationAddress);

    if (sourceLatLng.value == null || destinationLatLng.value == null) {
      return;
    }

    // Fetch initial position or set to source
    await fetchInitialPosition(shipmentId);

    // Clear existing markers and polylines
    markers.clear();
    polylines.clear();

    // Add source marker
    markers.add(Marker(
      markerId: const MarkerId('source'),
      position: sourceLatLng.value!,
      infoWindow: const InfoWindow(title: 'Source'),
      icon: sourceIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    // Add destination marker
    markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: destinationLatLng.value!,
      infoWindow: const InfoWindow(title: 'Destination'),
      icon: destinationIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    // Add ship marker
    markers.add(Marker(
      markerId: const MarkerId('ship'),
      position: shipLatLng.value!,
      infoWindow: const InfoWindow(title: 'Ship'),
      icon: shipIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));

    // Add polyline
    polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: [sourceLatLng.value!, destinationLatLng.value!],
      color: Kcolor.primary,
      width: 4,
    ));

    // Fit map to bounds
    if (mapController != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          sourceLatLng.value!.latitude < destinationLatLng.value!.latitude
              ? sourceLatLng.value!.latitude
              : destinationLatLng.value!.latitude,
          sourceLatLng.value!.longitude < destinationLatLng.value!.longitude
              ? sourceLatLng.value!.longitude
              : destinationLatLng.value!.longitude,
        ),
        northeast: LatLng(
          sourceLatLng.value!.latitude > destinationLatLng.value!.latitude
              ? sourceLatLng.value!.latitude
              : destinationLatLng.value!.latitude,
          sourceLatLng.value!.longitude > destinationLatLng.value!.longitude
              ? sourceLatLng.value!.longitude
              : destinationLatLng.value!.longitude,
        ),
      );
      await mapController!
          .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  // Update ship position in Firebase
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

  // Simulate ship movement
  void startShipMovement() async {
    if (!iconsLoaded.value) {
      return;
    }

    movementTimer?.cancel();
    movementTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (sourceLatLng.value == null || destinationLatLng.value == null) return;

      // Increment progress (0.0 to 1.0)
      progress.value += 0.02; // Adjust speed as needed
      if (progress.value >= 1.0) {
        progress.value = 1.0;
        if (currentShipmentId != null) {
          if (orderController.shipmentsList
                  .firstWhere(
                    (shipment) => shipment.shipmentId == currentShipmentId,
                  )
                  .shipmentStatus
                  .name ==
              ShipmentStatus.inTransit.name) {
            orderController.updateShipmentStatus(
              currentShipmentId!,
              ShipmentStatus.delivered,
            );
          }
        }
        timer.cancel();
      }

      // Calculate new ship position
      final newLat = sourceLatLng.value!.latitude +
          (destinationLatLng.value!.latitude - sourceLatLng.value!.latitude) *
              progress.value;
      final newLng = sourceLatLng.value!.longitude +
          (destinationLatLng.value!.longitude - sourceLatLng.value!.longitude) *
              progress.value;

      shipLatLng.value = LatLng(newLat, newLng);

      // Update ship marker
      markers.removeWhere((m) => m.markerId.value == 'ship');
      markers.add(Marker(
        markerId: const MarkerId('ship'),
        position: shipLatLng.value!,
        infoWindow: const InfoWindow(title: 'Ship'),
        icon: shipIcon!,
      ));

      // Update Firebase
      updateFirebasePosition(shipLatLng.value!, progress.value);

      // Animate camera to follow ship
      mapController?.animateCamera(
        CameraUpdate.newLatLng(shipLatLng.value!),
      );
    });
  }

  // Set map controller
  void setMapController(GoogleMapController controller) {
    mapController = controller;
    update();
  }
}
