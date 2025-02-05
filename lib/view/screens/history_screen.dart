// ignore_for_file: invalid_use_of_protected_member

import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/view/widgets/history_screen_widgets/order_card_widget.dart';
import 'package:final_project_customer_website/view/widgets/history_screen_widgets/search_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController searchController = TextEditingController();
  final CustomerController customerController = Get.put(CustomerController());
  final OrderController ordersController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            child: Container(
              decoration: BoxDecoration(
                color: Kcolor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 8.h),
              child: Obx(
                () => Column(
                  children: [
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        Text(
                          "Orders History",
                          style: appStyle(
                              size: 25.sp,
                              color: Kcolor.primary,
                              fontWeight: FontWeight.w900),
                        ),
                        const Spacer(),
                        SearchTextField(searchController: searchController),
                      ],
                    ),
                    SizedBox(height: 40.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 200.w,
                          child: Text(
                            "Order ID",
                            style: appStyle(
                                size: 15.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: Text(
                            "Date",
                            style: appStyle(
                                size: 15.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: Text(
                            "From",
                            style: appStyle(
                                size: 15.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: Text(
                            "To",
                            style: appStyle(
                                size: 15.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: Text(
                            "Status",
                            style: appStyle(
                                size: 15.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: Text(
                            "Cost",
                            style: appStyle(
                                size: 15.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    customerController.currentCustomer.value.orders.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 60.h, bottom: 30.h),
                              child: Text(
                                "No Orders Yet",
                                style: appStyle(
                                    size: 18.sp,
                                    color: Kcolor.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: customerController
                                .currentCustomer.value.orders.length,
                            itemBuilder: (context, index) {
                              return Obx(
                                () => OrderCardWidget(
                                  cost: ordersController
                                      .shipmentsList.value[index].shippingCost
                                      .toString(),
                                  date: ordersController
                                      .shipmentsList.value[index].submitedDate,
                                  from: ordersController
                                      .shipmentsList.value[index].senderAddress,
                                  id: ordersController
                                      .shipmentsList.value[index].shipmentId,
                                  status: ordersController
                                              .shipmentsList
                                              .value[index]
                                              .shipmentStatus
                                              .name ==
                                          "waitingApproval"
                                      ? "Waiting Approval"
                                      : ordersController
                                                  .shipmentsList
                                                  .value[index]
                                                  .shipmentStatus
                                                  .name ==
                                              "returned"
                                          ? "Returned"
                                          : ordersController
                                                      .shipmentsList
                                                      .value[index]
                                                      .shipmentStatus
                                                      .name ==
                                                  "pending"
                                              ? "Pending"
                                              : ordersController
                                                          .shipmentsList
                                                          .value[index]
                                                          .shipmentStatus
                                                          .name ==
                                                      "delivered"
                                                  ? "Delivered"
                                                  : ordersController
                                                              .shipmentsList
                                                              .value[index]
                                                              .shipmentStatus
                                                              .name ==
                                                          "inTransit"
                                                      ? "In Transit"
                                                      : ordersController
                                                                  .shipmentsList
                                                                  .value[index]
                                                                  .shipmentStatus
                                                                  .name ==
                                                              "waitingPickup"
                                                          ? "Waiting Pickup"
                                                          : "Cancelled",
                                  to: ordersController
                                      .shipmentsList[index].receiverAddress,
                                ),
                              );
                            }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
