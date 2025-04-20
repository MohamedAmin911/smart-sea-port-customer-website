// ignore_for_file: deprecated_member_use, invalid_use_of_protected_member

import 'dart:async';

import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/controller/ship_tracking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShipMapWidget extends StatefulWidget {
  @override
  State<ShipMapWidget> createState() => _ShipMapWidgetState();
}

class _ShipMapWidgetState extends State<ShipMapWidget> {
  final ShipController controller = Get.put(ShipController());

  final Completer<GoogleMapController> _controller = Completer();

  late String _mapStyleString;

  @override
  void initState() {
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleString = string;
    });
    _loadCustomMarker();

    super.initState();
  }

  BitmapDescriptor? shipIcon;
  BitmapDescriptor? portIcon;

  void _loadCustomMarker() async {
    shipIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 30)),
      'assets/png/ship.png',
    );
    portIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(50, 50)),
      'assets/png/port.png',
    );
    setState(() {}); // Refresh the UI once loaded
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GoogleMap(
        compassEnabled: false,
        mapToolbarEnabled: false,
        scrollGesturesEnabled: true,
        zoomControlsEnabled: false,
        rotateGesturesEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: controller.currentPosition.value,
          zoom: 2,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('source'),
            position: controller.sourcePosition.value,
            infoWindow: const InfoWindow(title: 'Source Country'),
            icon: portIcon ?? BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('destination'),
            position: controller.destinationPosition.value,
            infoWindow: const InfoWindow(title: 'Egypt'),
            icon: portIcon ?? BitmapDescriptor.defaultMarker,
          ),
          Marker(
            markerId: const MarkerId('ship'),
            position: controller.currentPosition.value,
            infoWindow: const InfoWindow(title: 'Ship'),
            icon: shipIcon ?? BitmapDescriptor.defaultMarker,
          ),
        },
        polylines: {
          if (controller.routePoints.isNotEmpty)
            Polyline(
              polylineId: const PolylineId('route'),
              color: Kcolor.accent,
              width: 2,
              points: controller.routePoints2.value,
            ),
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _controller.future.then((value) {
            value.setMapStyle(_mapStyleString);
          });
        },
      );
    });
  }
}
