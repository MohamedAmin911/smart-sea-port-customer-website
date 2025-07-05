// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:final_project_customer_website/constants/apikeys.dart';
import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final sourceLatLng = Rx<LatLng?>(null);
  final destinationLatLng = Rx<LatLng?>(null);
  final shipLatLng = Rx<LatLng?>(null);
  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  final List<LatLng> seaRoutePoints = [];
  String? currentContainerId;
  String? currentShipmentId;
  DatabaseReference? database;
  final String apiKey = KapiKeys.geocodingApiKey;
  Timer? movementTimer;
  final progress = 0.0.obs;
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? shipIcon;
  final iconsLoaded = false.obs;

  final isAtCheckpoint = false.obs;
  bool checkpointReached = false;

  final Rx<ShipmentModel?> trackedShipment = Rx<ShipmentModel?>(null);
  StreamSubscription<DatabaseEvent>? _shipmentSubscription;

  bool isSimulationFinished = false;
  final isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await _loadCustomIcons();
  }

  @override
  void onClose() {
    movementTimer?.cancel();
    mapController?.dispose();
    _shipmentSubscription?.cancel();
    super.onClose();
  }

  Future<void> updateBlockchainStatus(
      String shipmentId, String newStatus) async {
    // Construct the URL exactly as shown in Postman
    final url = Uri.parse('${KapiKeys.blockChainUrl}/$shipmentId/status');

    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Header for ngrok
    };

    // Construct the JSON body with the "newStatus" key
    final body = jsonEncode({'newStatus': newStatus});

    print("Attempting to update blockchain status via PUT...");
    print("URL: $url");
    print("Payload: $body");

    try {
      // Use http.put to match the Postman request method
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print(
            '✅ Blockchain status updated successfully for $shipmentId to $newStatus.');
      } else {
        print(
            '❌ Error updating blockchain status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❗ Exception updating blockchain status: $e');
    }
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

  void _calculateSeaRoute(LatLng start, LatLng end) {
    seaRoutePoints.clear();
    const pointCount = 50;
    final midPoint = LatLng((start.latitude + end.latitude) / 2,
        (start.longitude + end.longitude) / 2);
    final controlPoint = LatLng(
        midPoint.latitude - (end.longitude - start.longitude) * 0.2,
        midPoint.longitude + (end.latitude - start.latitude) * 0.2);

    for (int i = 0; i <= pointCount; i++) {
      final t = i / pointCount.toDouble();
      final lat = pow(1 - t, 2) * start.latitude +
          2 * (1 - t) * t * controlPoint.latitude +
          pow(t, 2) * end.latitude;
      final lng = pow(1 - t, 2) * start.longitude +
          2 * (1 - t) * t * controlPoint.longitude +
          pow(t, 2) * end.longitude;
      seaRoutePoints.add(LatLng(lat, lng));
    }
  }

  // In your ShipController class
  Future<void> initializeMap(String sourceAddress, String destinationAddress,
      String containerId, String shipmentId) async {
    // --- THIS IS THE FIX ---
    // Capture the containerId and shipmentId when the map is initialized
    this.currentShipmentId = shipmentId;
    this.currentContainerId = containerId;

    database = FirebaseDatabase.instance.ref('ship_positions/$shipmentId');

    _shipmentSubscription?.cancel();
    _shipmentSubscription = FirebaseDatabase.instance
        .ref('shipments/$shipmentId')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        trackedShipment.value = ShipmentModel.fromFirebase(
            Map<String, dynamic>.from(event.snapshot.value as Map));
      }
    });

    isSimulationFinished = false;
    checkpointReached = false;
    isAtCheckpoint.value = false;
    progress.value = 0.0;
    shipLatLng.value = null;

    sourceLatLng.value = await geocodeAddress(sourceAddress);
    destinationLatLng.value = await geocodeAddress(destinationAddress);

    if (sourceLatLng.value == null || destinationLatLng.value == null) return;

    _calculateSeaRoute(sourceLatLng.value!, destinationLatLng.value!);
    await fetchInitialPosition(shipmentId);

    markers.clear();
    polylines.clear();

    markers.add(Marker(
        markerId: const MarkerId('source'),
        position: sourceLatLng.value!,
        icon: sourceIcon ?? BitmapDescriptor.defaultMarker));
    markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: destinationLatLng.value!,
        icon: destinationIcon ?? BitmapDescriptor.defaultMarker));
    markers.add(Marker(
        markerId: const MarkerId('ship'),
        position: shipLatLng.value!,
        icon: shipIcon ?? BitmapDescriptor.defaultMarker));

    polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: seaRoutePoints,
        color: Kcolor.primary,
        width: 4));
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

  // In your ShipController class
  void startShipMovement() async {
    if (!iconsLoaded.value) return;
    if (isSimulationFinished) return;

    if (trackedShipment.value != null &&
        trackedShipment.value!.shipmentStatus == ShipmentStatus.delivered) {
      print("Shipment is already delivered. Displaying ship at destination.");
      if (destinationLatLng.value != null) {
        shipLatLng.value = destinationLatLng.value;
        markers.removeWhere((m) => m.markerId.value == 'ship');
        markers.add(Marker(
            markerId: const MarkerId('ship'),
            position: shipLatLng.value!,
            icon: shipIcon!));
      }
      return;
    }

    movementTimer?.cancel();
    movementTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seaRoutePoints.isEmpty) return;

      // --- THIS ENTIRE BLOCK IS NOW FIXED ---
      if (progress.value >= 0.5 && !checkpointReached) {
        checkpointReached = true;
        isAtCheckpoint.value = true;

        orderController.updateShipmentStatus(
            currentShipmentId!, ShipmentStatus.checkPointA);

        // Use the safely stored containerId
        if (currentContainerId != null) {
          updateBlockchainStatus(currentContainerId!, 'CHECKPOINT_A');
        }

        Future.delayed(const Duration(seconds: 5), () {
          isAtCheckpoint.value = false;
          // Restore the logic to resume the trip
          // if (trackedShipment.value?.shipmentStatus ==
          //     ShipmentStatus.checkPointA) {
          //   orderController.updateShipmentStatus(
          //       currentShipmentId!, ShipmentStatus.inTransit);
          // if (currentContainerId != null) {
          //   updateBlockchainStatus(currentContainerId!, 'INTRANSIT');
          // }
          //}
        });
      }

      if (!isAtCheckpoint.value) {
        progress.value += 0.01;
        if (progress.value >= 1.0) {
          progress.value = 1.0;

          if (currentShipmentId != null) {
            // Check for inTransit before marking as delivered
            if (trackedShipment.value != null &&
                trackedShipment.value!.shipmentStatus ==
                    ShipmentStatus.checkPointA) {
              orderController.updateShipmentStatus(
                  currentShipmentId!, ShipmentStatus.delivered);
            }
          }
          isSimulationFinished = true;
          timer.cancel();
        }

        final routeIndex =
            (progress.value * (seaRoutePoints.length - 1)).round();
        shipLatLng.value = seaRoutePoints[routeIndex];

        markers.removeWhere((m) => m.markerId.value == 'ship');
        markers.add(Marker(
          markerId: const MarkerId('ship'),
          position: shipLatLng.value!,
          infoWindow: const InfoWindow(title: 'Ship'),
          icon: shipIcon!,
        ));
        updateFirebasePosition(shipLatLng.value!, progress.value);
      }
    });
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
    update();
  }
}
