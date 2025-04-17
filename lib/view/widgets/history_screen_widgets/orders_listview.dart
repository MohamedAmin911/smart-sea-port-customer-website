// ignore_for_file: invalid_use_of_protected_member

import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/widgets/history_screen_widgets/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersListView extends StatelessWidget {
  const OrdersListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final CustomerController customerController = Get.put(CustomerController());
    final OrderController ordersController = Get.put(OrderController());
    return ListView.builder(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemCount: customerController.currentCustomer.value.orders.length,
        itemBuilder: (context, index) {
          return Obx(
            () => OrderCardWidget(
              cost: ordersController
                          .shipmentsList.value[index].shipmentStatus.name ==
                      ShipmentStatus.cancelled.name
                  ? "Cancelled"
                  : ordersController.shipmentsList.value[index].shippingCost
                                  .toString() ==
                              "0" ||
                          ordersController.shipmentsList.value[index]
                                  .shipmentStatus.name ==
                              ShipmentStatus.waitngPayment.name
                      ? "Being estimated"
                      : ordersController.shipmentsList.value[index].shippingCost
                          .toString(),
              date: ordersController.shipmentsList.value[index].submitedDate,
              from: ordersController.shipmentsList.value[index].senderAddress,
              id: ordersController.shipmentsList.value[index].shipmentId,
              status: ordersController
                          .shipmentsList.value[index].shipmentStatus.name ==
                      ShipmentStatus.waitingApproval.name
                  ? "Waiting Approval"
                  : ordersController
                              .shipmentsList.value[index].shipmentStatus.name ==
                          ShipmentStatus.onHold.name
                      ? "On Hold"
                      : ordersController.shipmentsList.value[index]
                                  .shipmentStatus.name ==
                              ShipmentStatus.cancelled.name
                          ? "Cancelled"
                          : ordersController.shipmentsList.value[index]
                                      .shipmentStatus.name ==
                                  ShipmentStatus.delivered.name
                              ? "Delivered"
                              : ordersController.shipmentsList.value[index]
                                          .shipmentStatus.name ==
                                      ShipmentStatus.unLoading.name
                                  ? "Unloading"
                                  : ordersController.shipmentsList.value[index]
                                              .shipmentStatus.name ==
                                          ShipmentStatus.waitingPickup.name
                                      ? "Waiting Pickup"
                                      : ordersController
                                                  .shipmentsList
                                                  .value[index]
                                                  .shipmentStatus
                                                  .name ==
                                              ShipmentStatus.waitngPayment.name
                                          ? "Waiting Payment"
                                          : "In Transit",
              to: ordersController.shipmentsList[index].receiverAddress,
            ),
          );
        });
  }
}
