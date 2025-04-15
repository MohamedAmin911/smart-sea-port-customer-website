// ignore_for_file: invalid_use_of_protected_member

import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/screens/make_order_screen.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final customerController = Get.put(CustomerController());
  final OrderController ordersController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body:
            //waitng approval
            ordersController.shipmentsList.value.any((shipment) =>
                    shipment.shipmentStatus.name == "waitingApproval")
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "Your Order Is Waiting Approval",
                          style: appStyle(
                              size: 18.sp,
                              color: Kcolor.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                //on hold
                : ordersController.shipmentsList.value.any((shipment) =>
                        shipment.shipmentStatus.name ==
                        ShipmentStatus.onHold.name)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              "Your Order Is On Hold, we will contact you soon",
                              style: appStyle(
                                  size: 18.sp,
                                  color: Kcolor.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    :
                    //waitng payment
                    ordersController.shipmentsList.value.any((shipment) =>
                            shipment.shipmentStatus.name ==
                            ShipmentStatus.waitngPayment.name)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Please Pay the costs, to continue your order",
                                  style: appStyle(
                                      size: 18.sp,
                                      color: Kcolor.primary,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 50.h),
                              Center(
                                child: ElevBtn1(
                                  width: 300.w,
                                  icon: Text(
                                    "Pay Now",
                                    style: appStyle(
                                        size: 18.sp,
                                        color: Kcolor.background,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  textColor: Kcolor.background,
                                  bgColor: Kcolor.primary,
                                  func: () {},
                                ),
                              ),
                            ],
                          )
                        :
                        //no orders in progress
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No Orders In Progress",
                                style: appStyle(
                                    size: 18.sp,
                                    color: Kcolor.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 50.h),
                              Center(
                                child: ElevBtn1(
                                  width: 300.w,
                                  icon: Text(
                                    "Make An Order",
                                    style: appStyle(
                                        size: 18.sp,
                                        color: Kcolor.background,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  textColor: Kcolor.background,
                                  bgColor: Kcolor.primary,
                                  func: () {
                                    Get.to(const MakeOrderScreen());
                                  },
                                ),
                              ),
                            ],
                          ),
      ),
    );
  }
}
