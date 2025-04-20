// ignore_for_file: invalid_use_of_protected_member, unused_field, deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';

import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/controller/paymob_controller.dart';
import 'package:final_project_customer_website/controller/ship_tracking_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/screens/make_order_screen.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/calendar_widget.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/checkpoint_widget.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/costs_widget.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/map_widget.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/shipment_details_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:html' as html;

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final customerController = Get.put(CustomerController());
  final OrderController ordersController = Get.put(OrderController());
  final PayMobController paymentController = Get.put(PayMobController());
  final ShipController shipController = Get.find<ShipController>();
  late final StreamSubscription<html.Event> _backButtonListener;
  @override
  void initState() {
    super.initState();
    _setupBackButtonListener();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    await _checkAndUpdateStatus();
  }

  Future<void> _checkAndUpdateStatus() async {
    // Make sure we only fetch if shipments exist
    if (ordersController.shipmentsList.isNotEmpty) {
      final firstOrderId = ordersController.shipmentsList
          .firstWhere((shipment) => shipment.orderId.isNotEmpty)
          .orderId;

      await paymentController.getPaymentStatus(firstOrderId);
    }

    // Optional: Force GetX UI update
    ordersController.shipmentsList.refresh();
  }

  void _setupBackButtonListener() {
    _backButtonListener = html.window.onPopState.listen((event) async {
      await _checkAndUpdateStatus();

      if (mounted) {
        setState(() {});
      }

      // If still no rebuild, you can try:
      // Get.forceAppUpdate();
    });
  }

  @override
  void dispose() {
    _backButtonListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ShipmentModel currentShipment =
    //     ordersController.shipmentsList.value.firstWhere(
    //   (element) =>
    //       element.shipmentStatus.name == ShipmentStatus.inTransit.name ||
    //       element.shipmentStatus.name == ShipmentStatus.delivered.name ||
    //       element.shipmentStatus.name == ShipmentStatus.waitingPickup.name ||
    //       element.shipmentStatus.name == ShipmentStatus.unLoading.name,
    // );
    return Obx(
      () => Scaffold(
        body: paymentController.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(
                color: Kcolor.primary,
              ))
            :
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
                              size: 40.sp,
                              color: Kcolor.primary,
                              fontWeight: FontWeight.w400),
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
                                  size: 40.sp,
                                  color: Kcolor.primary,
                                  fontWeight: FontWeight.w400),
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
                                  "Please Pay the costs, to continue your order.",
                                  style: appStyle(
                                      size: 40.sp,
                                      color: Kcolor.primary,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              SizedBox(height: 50.h),
                              Center(
                                child: ElevBtn1(
                                  width: 300.w,
                                  icon: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          KIconAssets.visaSvg,
                                          color: Kcolor.background,
                                          width: 20.w,
                                          height: 20.h,
                                        ),
                                        SizedBox(width: 15.w),
                                        SvgPicture.asset(
                                          KIconAssets.mastercardSvg,
                                          color: Kcolor.background,
                                          width: 25.w,
                                          height: 25.h,
                                        ),
                                        SizedBox(width: 15.w),
                                        Container(
                                          width: 4.w,
                                          height: 20.h,
                                          decoration: BoxDecoration(
                                            color: Kcolor.background,
                                            borderRadius:
                                                BorderRadius.circular(22.r),
                                          ),
                                        ),
                                        SizedBox(width: 15.w),
                                        Text(
                                          "Pay Now",
                                          style: appStyle(
                                              size: 20.sp,
                                              color: Kcolor.background,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                  ),
                                  textColor: Kcolor.background,
                                  bgColor: Kcolor.primary,
                                  func: () async {
                                    paymentController.payWithPaymob(10000);
                                  },
                                ),
                              ),
                            ],
                          )
                        :
                        //in transit
                        ordersController.shipmentsList.value.any((shipment) =>
                                    shipment.shipmentStatus.name ==
                                    ShipmentStatus.inTransit.name) ||
                                ordersController.shipmentsList.value.any(
                                    (shipment) =>
                                        shipment.shipmentStatus.name ==
                                        ShipmentStatus.delivered.name) ||
                                ordersController.shipmentsList.value.any(
                                    (shipment) =>
                                        shipment.shipmentStatus.name ==
                                        ShipmentStatus.waitingPickup.name) ||
                                ordersController.shipmentsList.value.any(
                                    (shipment) =>
                                        shipment.shipmentStatus.name ==
                                        ShipmentStatus.unLoading.name)
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w, vertical: 20.h),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //shipment details summary
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: [
                                              //shipment details summary
                                              ShipmentDetailsSummaryWidget(
                                                  currentShipment:
                                                      ordersController
                                                          .shipmentsList.value
                                                          .firstWhere(
                                                (element) =>
                                                    element.shipmentStatus.name == ShipmentStatus.inTransit.name ||
                                                    element.shipmentStatus
                                                            .name ==
                                                        ShipmentStatus
                                                            .delivered.name ||
                                                    element.shipmentStatus
                                                            .name ==
                                                        ShipmentStatus
                                                            .waitingPickup
                                                            .name ||
                                                    element.shipmentStatus
                                                            .name ==
                                                        ShipmentStatus
                                                            .unLoading.name,
                                              )),
                                              SizedBox(height: 20.h),

                                              //map
                                              const MapWidget(),
                                            ],
                                          ),
                                          SizedBox(width: 30.w),
                                          //calendar
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 28.h,
                                                      ),
                                                      CustomCalendar(
                                                        selectedDate: DateTime(
                                                            2025,
                                                            4,
                                                            24), // for example
                                                        onDateSelected:
                                                            (selectedDate) {
                                                          // Update your state here
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 30.w),
                                                  //costs
                                                  CostsWidget(
                                                    currentShipment:
                                                        ordersController
                                                            .shipmentsList.value
                                                            .firstWhere(
                                                      (element) =>
                                                          element.shipmentStatus.name == ShipmentStatus.inTransit.name ||
                                                          element.shipmentStatus
                                                                  .name ==
                                                              ShipmentStatus
                                                                  .delivered
                                                                  .name ||
                                                          element.shipmentStatus
                                                                  .name ==
                                                              ShipmentStatus
                                                                  .waitingPickup
                                                                  .name ||
                                                          element.shipmentStatus
                                                                  .name ==
                                                              ShipmentStatus
                                                                  .unLoading
                                                                  .name,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20.h),
                                              ShipmentCheckpoint(
                                                  currentStatus:
                                                      ordersController
                                                          .shipmentsList.value
                                                          .firstWhere(
                                                            (element) =>
                                                                element.shipmentStatus.name == ShipmentStatus.inTransit.name ||
                                                                element.shipmentStatus
                                                                        .name ==
                                                                    ShipmentStatus
                                                                        .delivered
                                                                        .name ||
                                                                element.shipmentStatus
                                                                        .name ==
                                                                    ShipmentStatus
                                                                        .waitingPickup
                                                                        .name ||
                                                                element.shipmentStatus
                                                                        .name ==
                                                                    ShipmentStatus
                                                                        .unLoading
                                                                        .name,
                                                          )
                                                          .shipmentStatus),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            :

                            //no orders in progress
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "No Orders In Progress",
                                    style: appStyle(
                                        size: 40.sp,
                                        color: Kcolor.primary,
                                        fontWeight: FontWeight.w400),
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
