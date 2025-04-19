import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShipController extends GetxController {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final Rx<LatLng> currentPosition = LatLng(0, 0).obs;
  final Rx<LatLng> destinationPosition = LatLng(0, 0).obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;

  Timer? _movementTimer;

  /// Replace with your actual Google Maps API key
  final String _googleApiKey = 'AlzaSyBYf_mjjnqslJw3Grke69Kq0D22hcrlnjS';

  /// Convert a country name to its LatLng using Google Geocoding API
  Future<LatLng> _getCoordinates(String countryName) async {
    final url = Uri.parse(
        'https://maps.gomaps.pro/maps/api/geocode/json?address=$countryName&key=$_googleApiKey');

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final location = data['results'][0]['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    } else {
      throw Exception('Failed to get coordinates for $countryName');
    }
  }

  /// Initialize route from selected source country to Egypt
  Future<void> initializePositions(String sourceCountry) async {
    currentPosition.value = await _getCoordinates(sourceCountry);
    destinationPosition.value = await _getCoordinates('Egypt');

    routePoints.clear();
    _generateCurvedRoute(currentPosition.value, destinationPosition.value);
    _startMovement();
  }

  /// Simulates a curved (overseas-like) path
  void _generateCurvedRoute(LatLng start, LatLng end) {
    const int numSteps = 50;

    final double deltaLat = end.latitude - start.latitude;
    final double deltaLng = end.longitude - start.longitude;

    for (int i = 0; i <= numSteps; i++) {
      double t = i / numSteps;

      // Basic straight-line interpolation
      double lat = _lerp(start.latitude, end.latitude, t);
      double lng = _lerp(start.longitude, end.longitude, t);

      // Add curved offset — push point perpendicular to the path using sine
      double curveStrength = 0.05; // tweak for higher/lower arc
      double offsetLat = -deltaLng * curveStrength * sin(pi * t);
      double offsetLng = deltaLat * curveStrength * sin(pi * t);

      LatLng curvedPoint = LatLng(lat + offsetLat, lng + offsetLng);
      routePoints.add(curvedPoint);
    }
  }

  /// Start moving along the route (1 point every 5 seconds)
  void _startMovement() {
    int index = 0;
    _movementTimer?.cancel();

    _movementTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (index >= routePoints.length) {
        timer.cancel();
        return;
      }

      final newPos = routePoints[index];
      currentPosition.value = newPos;
      _updateFirebasePosition(newPos);
      index++;
    });
  }

  /// Update the current position in Firebase
  void _updateFirebasePosition(LatLng position) {
    _database.ref('shipPosition').set({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  /// Linear interpolation helper
  double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Optional: clean up timer
  @override
  void onClose() {
    _movementTimer?.cancel();
    super.onClose();
  }
}
