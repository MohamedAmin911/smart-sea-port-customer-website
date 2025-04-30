// ignore_for_file: invalid_use_of_protected_member

import 'package:final_project_customer_website/constants/map_style.dart';
import 'package:final_project_customer_website/controller/map_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final ShipController controller = Get.put(ShipController());
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Wait for icons to load
        if (!controller.iconsLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return GoogleMap(
          style: KMapStyle.mapStyle,
          onMapCreated: (GoogleMapController googleMapController) {
            controller.setMapController(googleMapController);

            // Initialize map after controller is ready
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                final shipment = orderController.shipmentsList.firstWhere(
                  (element) =>
                      element.shipmentStatus.name ==
                          ShipmentStatus.inTransit.name ||
                      element.shipmentStatus.name ==
                          ShipmentStatus.delivered.name ||
                      element.shipmentStatus.name ==
                          ShipmentStatus.unLoaded.name ||
                      element.shipmentStatus.name ==
                          ShipmentStatus.enteredPort.name ||
                      element.shipmentStatus.name ==
                          ShipmentStatus.waitingPickup.name,
                  orElse: () => throw Exception('No valid shipment found'),
                );

                await controller.initializeMap(
                  shipment.senderAddress,
                  "Egypt",
                  shipment.shipmentId,
                );

                controller.startShipMovement();
              } catch (e) {
                Get.snackbar('Error', 'Failed to initialize map: $e');
              }
            });
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 2,
          ),
          markers: controller.markers.value,
          polylines: controller.polylines.value,
        );
      }),
    );
  }
}
