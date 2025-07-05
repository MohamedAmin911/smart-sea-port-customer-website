// ignore_for_file: invalid_use_of_protected_member

import 'package:final_project_customer_website/constants/map_style.dart';
import 'package:final_project_customer_website/controller/map_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ShipController controller = Get.put(ShipController());
  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();

    // Automatically initialize map and start simulation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Find the first shipment with a valid status
        final shipment = orderController.shipmentsList.firstWhere(
          (element) =>
              element.shipmentStatus.name == ShipmentStatus.inTransit.name ||
              element.shipmentStatus.name == ShipmentStatus.delivered.name ||
              element.shipmentStatus.name == ShipmentStatus.unLoaded.name ||
              element.shipmentStatus.name == ShipmentStatus.enteredPort.name ||
              element.shipmentStatus.name == ShipmentStatus.waitingPickup.name,
          orElse: () => throw Exception('No valid shipment found'),
        );

        // Initialize map with source and destination addresses
        await controller.initializeMap(
            shipment.senderAddress, // Source address
            "Port Said",
            shipment.containerId,
            shipment.shipmentId // Destination address
            );

        // Start the ship movement simulation
        controller.startShipMovement();
      } catch (e) {
        // Handle errors (e.g., no valid shipment)
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error starting simulation: $e')),
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => GoogleMap(
            style: KMapStyle.mapStyle,
            onMapCreated: controller.setMapController,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
            markers: controller.markers.value,
            polylines: controller.polylines.value,
          )),
    );
  }
}
