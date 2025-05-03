// ignore_for_file: invalid_use_of_protected_member, unused_field, deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/controller/paymob_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/screens/make_order_screen.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/calendar_widget.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/checkpoint_widget.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/costs_widget.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/map_widget.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/payment_cost_widget.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/shipment_details_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final customerController = Get.put(CustomerController());
  final OrderController ordersController = Get.put(OrderController());
  final PayMobController paymentController = Get.put(PayMobController());
  late final StreamSubscription<html.Event> _backButtonListener;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    // Timer.periodic(const Duration(seconds: 1), (timer) async {
    //   setState(() {
    //     isLoading = false;
    //   });
    // });
    _setupBackButtonListener();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _checkAndUpdateStatus();
  }

  Future<void> _checkAndUpdateStatus() async {
    if (ordersController.shipmentsList.isNotEmpty) {
      final firstOrderId = ordersController.shipmentsList
          .firstWhere((shipment) => shipment.orderId.isNotEmpty)
          .orderId;
      await paymentController.getPaymentStatus(firstOrderId);
    }
    ordersController.shipmentsList.refresh();
  }

  void _setupBackButtonListener() {
    _backButtonListener = html.window.onPopState.listen((event) async {
      await _checkAndUpdateStatus();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _backButtonListener.cancel();
    super.dispose();
  }

  ShipmentStatus? _getPrimaryStatus() {
    final priorities = [
      ShipmentStatus.inTransit.name,
      ShipmentStatus.delivered.name,
      ShipmentStatus.waitingPickup.name,
      ShipmentStatus.unLoaded.name,
      ShipmentStatus.waitngPayment.name,
      ShipmentStatus.onHold.name,
      ShipmentStatus.enteredPort.name,
      ShipmentStatus.waitingApproval.name,
    ];

    for (final status in priorities) {
      final match = ordersController.shipmentsList.value.firstWhereOrNull(
        (shipment) => shipment.shipmentStatus.name == status,
      );
      if (match != null) return match.shipmentStatus;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final shipmentList = ordersController.shipmentsList.value;
      final currentStatus = _getPrimaryStatus();
      final currentShipment = shipmentList.firstWhereOrNull(
        (s) => s.shipmentStatus.name == currentStatus?.name,
      );

      // if (isLoading) {
      //   return const Center(
      //       child: CircularProgressIndicator(color: Kcolor.primary));
      // }

      switch (currentStatus?.name) {
        case "waitingApproval":
          return _buildCenteredMessage("Your Order Is Waiting Approval");

        case "onHold":
          return _buildCenteredMessage(
              "Your Order Is On Hold, we will contact you soon");

        case "waitngPayment":
          return _buildPaymentPrompt(currentShipment!);

        case "inTransit":
        case "delivered":
        case "waitingPickup":
        case "unLoaded":
        case "enteredPort":
          return _buildTrackingDetails(currentShipment!);

        default:
          return _buildCenteredMessageWithButton("No Orders In Progress");
      }
    });
  }

  Widget _buildCenteredMessage(String message) {
    return Center(
      child: Text(
        message,
        style: appStyle(
            size: 40.sp, color: Kcolor.primary, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildCenteredMessageWithButton(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCenteredMessage(message),
        SizedBox(height: 50.h),
        ElevBtn1(
          width: 300.w,
          icon: Text("Make An Order",
              style: appStyle(
                  size: 18.sp,
                  color: Kcolor.background,
                  fontWeight: FontWeight.w600)),
          textColor: Kcolor.background,
          bgColor: Kcolor.primary,
          func: () => Get.to(const MakeOrderScreen()),
        ),
      ],
    );
  }

  Widget _buildPaymentPrompt(ShipmentModel shipment) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CostsWidget2(currentShipment: shipment),
          SizedBox(height: 30.h),
          _buildCenteredMessage(
              "Please Pay the costs, to continue your order."),
          SizedBox(height: 50.h),
          Center(
            child: ElevBtn1(
              width: 600.w,
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(KIconAssets.visaSvg,
                      width: 20.w, height: 20.h),
                  SizedBox(width: 15.w),
                  SvgPicture.asset(KIconAssets.mastercardSvg,
                      width: 25.w, height: 25.h),
                  SizedBox(width: 15.w),
                  Container(
                    width: 4.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                        color: Kcolor.background,
                        borderRadius: BorderRadius.circular(22.r)),
                  ),
                  SizedBox(width: 15.w),
                  Text("Pay Now",
                      style: appStyle(
                          size: 20.sp,
                          color: Kcolor.background,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              textColor: Kcolor.background,
              bgColor: Kcolor.primary,
              func: () async => paymentController
                  .payWithPaymob(shipment.shippingCost.toInt()),
            ),
          ),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }

  Widget _buildTrackingDetails(ShipmentModel shipment) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    ShipmentDetailsSummaryWidget(currentShipment: shipment),
                    SizedBox(height: 20.h),
                    const MapWidget(),
                  ],
                ),
                SizedBox(width: 30.w),
                Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 28.h),
                            CustomCalendar(currentShipment: shipment),
                          ],
                        ),
                        SizedBox(width: 30.w),
                        CostsWidget(currentShipment: shipment),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    ShipmentCheckpoint(
                        currentStatus: shipment.PortEntryTrigger == "1" &&
                                shipment.ContainerStoredTrigger == "0"
                            ? ShipmentStatus.enteredPort
                            : shipment.PortEntryTrigger == "1" &&
                                    shipment.ContainerStoredTrigger == "1"
                                ? ShipmentStatus.unLoaded
                                : shipment.shipmentStatus),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
