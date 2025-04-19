import 'dart:async';

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
  final ShipController controller = Get.find<ShipController>();

  final Completer<GoogleMapController> _controller = Completer();

  late String _mapStyleString;

  @override
  void initState() {
    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleString = string;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: controller.currentPosition.value,
          zoom: 4,
        ),
        markers: {
          Marker(
            markerId: MarkerId('ship'),
            position: controller.currentPosition.value,
            infoWindow: InfoWindow(title: 'Ship'),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: controller.destinationPosition.value,
            infoWindow: InfoWindow(title: 'Egypt'),
          ),
        },
        polylines: {
          if (controller.routePoints.isNotEmpty)
            Polyline(
              polylineId: PolylineId('route'),
              color: Colors.blueAccent,
              width: 4,
              points: controller.routePoints,
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
