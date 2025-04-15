// ignore_for_file: invalid_use_of_protected_member, deprecated_member_use

import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/view/widgets/history_screen_widgets/history_header_widget.dart';
import 'package:final_project_customer_website/view/widgets/history_screen_widgets/orders_listview.dart';
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
                    const HistoryHeader(),
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
                        : const OrdersListView(),
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
