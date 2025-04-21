import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:final_project_customer_website/constants/apikeys.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShipController extends GetxController {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final Rx<LatLng> sourcePosition = const LatLng(0, 0).obs;
  final Rx<LatLng> currentPosition = const LatLng(0, 0).obs;
  final Rx<LatLng> destinationPosition = const LatLng(0, 0).obs;
  final OrderController orderController = Get.put(OrderController());
  final RxList<LatLng> routePoints2 = <LatLng>[].obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  late DatabaseReference _firebaseRef;

  Timer? _movementTimer;

  @override
  void onInit() async {
    super.onInit();
    await initializePositions(
      orderController.shipmentsList
          .firstWhere((element) =>
              element.shipmentStatus.name == ShipmentStatus.inTransit.name ||
              element.shipmentStatus.name == ShipmentStatus.delivered.name ||
              element.shipmentStatus.name == ShipmentStatus.unLoading.name ||
              element.shipmentStatus.name == ShipmentStatus.waitingPickup.name)
          .senderAddress,
    );
  }

  Future<LatLng> _getCoordinates(String place) async {
    final url = Uri.parse(
        'https://geocode.maps.co/search?q=$place&api_key=${KapiKeys.geocodingApiKey}');
    final response = await http.get(url);
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      final location = data[0];
      return LatLng(
          double.parse(location['lat']), double.parse(location['lon']));
    } else {
      throw Exception('Failed to get coordinates for $place');
    }
  }

  Future<void> initializePositions(String sourceCountry) async {
    final shipmentId = _getCurrentShipmentId();
    if (shipmentId == null) return;

    sourcePosition.value = await _getCoordinates(sourceCountry);
    destinationPosition.value = await _getCoordinates('Egypt');

    _startFirebaseListener(); // always listen

    final positionSnapshot =
        await _database.ref('shipPosition/$shipmentId').get();

    if (positionSnapshot.exists) {
      final data = positionSnapshot.value as Map;
      currentPosition.value = LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      );

      if (_arePositionsEqual(
          currentPosition.value, destinationPosition.value)) {
        // Already at destination
        return;
      }

      // Continue from current position
      routePoints.clear();
      _generateCurvedRoute2(sourcePosition.value, destinationPosition.value);
      _generateCurvedRoute(currentPosition.value, destinationPosition.value);
      _startMovement(); // resume from current
    } else {
      currentPosition.value = sourcePosition.value;
      routePoints.clear();
      _generateCurvedRoute(sourcePosition.value, destinationPosition.value);
      await _uploadRouteToFirebase();
      _startMovement();
    }
  }

  void _generateCurvedRoute(LatLng start, LatLng end) {
    const int numSteps = 50;
    final double deltaLat = end.latitude - start.latitude;
    final double deltaLng = end.longitude - start.longitude;

    for (int i = 0; i <= numSteps; i++) {
      double t = i / numSteps;
      double lat = _lerp(start.latitude, end.latitude, t);
      double lng = _lerp(start.longitude, end.longitude, t);

      double curveStrength = 0.05;
      double offsetLat = -deltaLng * curveStrength * sin(pi * t);
      double offsetLng = deltaLat * curveStrength * sin(pi * t);

      LatLng curvedPoint = LatLng(lat + offsetLat, lng + offsetLng);
      routePoints.add(curvedPoint);
    }
  }

  void _generateCurvedRoute2(LatLng start, LatLng end) {
    const int numSteps = 50;
    final double deltaLat = end.latitude - start.latitude;
    final double deltaLng = end.longitude - start.longitude;

    for (int i = 0; i <= numSteps; i++) {
      double t = i / numSteps;
      double lat = _lerp(start.latitude, end.latitude, t);
      double lng = _lerp(start.longitude, end.longitude, t);

      double curveStrength = 0.05;
      double offsetLat = -deltaLng * curveStrength * sin(pi * t);
      double offsetLng = deltaLat * curveStrength * sin(pi * t);

      LatLng curvedPoint = LatLng(lat + offsetLat, lng + offsetLng);
      routePoints2.add(curvedPoint);
    }
  }

  Future<void> _uploadRouteToFirebase() async {
    final shipmentId = _getCurrentShipmentId();
    if (shipmentId == null) return;

    final routeMap = {
      'shipmentId': shipmentId,
      'route': routePoints
          .map((point) => {
                'lat': point.latitude,
                'lng': point.longitude,
              })
          .toList(),
    };

    await _database.ref('shipRoutes/$shipmentId').set(routeMap);
  }

  void _startMovement() {
    final shipmentId = _getCurrentShipmentId();
    if (shipmentId == null) return;

    int index = 0;
    _movementTimer?.cancel();

    _movementTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (index >= routePoints.length) {
        timer.cancel();
        return;
      }

      final newPos = routePoints[index];
      currentPosition.value = newPos;

      _database.ref('shipPosition/$shipmentId').set({
        'latitude': newPos.latitude,
        'longitude': newPos.longitude,
      });

      if (_arePositionsEqual(newPos, destinationPosition.value)) {
        timer.cancel();
        orderController.updateShipmentStatus(
            shipmentId, ShipmentStatus.delivered);

        return;
      }

      index++;
    });
  }

  void _startFirebaseListener() {
    final shipmentId = _getCurrentShipmentId();
    if (shipmentId == null) return;

    _firebaseRef = _database.ref('shipPosition/$shipmentId');
    _firebaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        currentPosition.value = LatLng(
          (data['latitude'] as num).toDouble(),
          (data['longitude'] as num).toDouble(),
        );
      }
    });
  }

  String? _getCurrentShipmentId() {
    try {
      return orderController.shipmentsList
          .firstWhere(
            (shipment) =>
                shipment.shipmentStatus.name == ShipmentStatus.inTransit.name ||
                shipment.shipmentStatus.name == ShipmentStatus.delivered.name ||
                shipment.shipmentStatus.name == ShipmentStatus.unLoading.name ||
                shipment.shipmentStatus.name ==
                    ShipmentStatus.waitingPickup.name,
          )
          .shipmentId;
    } catch (_) {
      return null;
    }
  }

  bool _arePositionsEqual(LatLng pos1, LatLng pos2,
      {double threshold = 0.001}) {
    return (pos1.latitude - pos2.latitude).abs() < threshold &&
        (pos1.longitude - pos2.longitude).abs() < threshold;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void onClose() {
    _movementTimer?.cancel();
    _firebaseRef.onDisconnect();
    super.onClose();
  }
}
