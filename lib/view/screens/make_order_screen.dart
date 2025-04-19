// ignore_for_file: deprecated_member_use

import 'package:country_picker/country_picker.dart';
import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/controller/ship_tracking_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/styled_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class MakeOrderScreen extends StatefulWidget {
  const MakeOrderScreen({super.key});

  @override
  State<MakeOrderScreen> createState() => _MakeOrderScreenState();
}

class _MakeOrderScreenState extends State<MakeOrderScreen> {
  final TextEditingController receiverAddressController =
      TextEditingController();
  final TextEditingController shipmentTypeController = TextEditingController();
  final TextEditingController shipmentWeightController =
      TextEditingController();
  final TextEditingController shipmentLengthController =
      TextEditingController();
  final TextEditingController shipmentWidthController = TextEditingController();

  final TextEditingController shipmentHeightController =
      TextEditingController();

  final orderController = Get.put(OrderController());
  final customerController = Get.put(CustomerController());
  final shipController = Get.put(ShipController());

  String sourceCountry = "";

  @override
  void dispose() {
    super.dispose();
    receiverAddressController.dispose();
    shipmentWeightController.dispose();
    shipmentLengthController.dispose();
    shipmentWidthController.dispose();
    shipmentHeightController.dispose();
    shipmentTypeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.h,
        bottomOpacity: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "SUBMIT ORDER",
          style: appStyle(
              size: 30.sp, color: Kcolor.primary, fontWeight: FontWeight.bold),
        ),
        leadingWidth: 70.w,
        actions: [
          Obx(
            () => Column(
              children: [
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 7.h),
                        Text(
                            customerController
                                .currentCustomer.value.companyName,
                            style: appStyle(
                                size: 20.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 5.h),
                        Text(
                            customerController
                                .currentCustomer.value.companyEmail,
                            style: appStyle(
                                size: 12.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      Icons.corporate_fare_rounded,
                      color: Kcolor.primary,
                      size: 55.sp,
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ],
            ),
          )
        ],
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w, top: 15.h),
          child: SvgPicture.asset(
            KIconAssets.smartPortLogo,
            color: Kcolor.primary,
            width: 100.w,
            height: 100.h,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 500.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50.h),
              // sender Address

              SizedBox(
                width: double.infinity,
                height: 45.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Kcolor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
                  ),
                  onPressed: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: false,
                      onSelect: (Country country) {
                        setState(() {
                          sourceCountry = country.name;
                        });
                      },
                    );
                  },
                  child: Text(
                    'Select Sender Country',
                    style: appStyle(
                        size: 15.sp,
                        color: Kcolor.background,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Container(
                width: double.infinity,
                height: 45.h,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: sourceCountry == ""
                          ? Kcolor.primary.withOpacity(0.2)
                          : Kcolor.primary),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Center(
                  child: Text(
                      sourceCountry == "" ? "Sender Country" : sourceCountry,
                      style: appStyle(
                          size: 15.sp,
                          color: sourceCountry == ""
                              ? Kcolor.primary.withOpacity(0.2)
                              : Kcolor.primary,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              SizedBox(height: 30.h),

              // Shipment Type
              StyledFormField(
                width: double.infinity,
                keyboardType: TextInputType.streetAddress,
                obscureText: false,
                hintText: 'Shipment Type',
                prefixIcon: Icons.trolley,
                controller: shipmentTypeController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter sender address'
                    : null,
              ),
              // Shipment Weight
              StyledFormField(
                suffix: Text(
                  "kg",
                  style: appStyle(
                      size: 12.sp,
                      color: Kcolor.primary,
                      fontWeight: FontWeight.w400),
                ),
                width: double.infinity,
                keyboardType: TextInputType.number,
                obscureText: false,
                hintText: 'Shipment Weight',
                prefixIcon: Icons.scale_rounded,
                controller: shipmentWeightController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shipment weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              // Shipment length
              StyledFormField(
                width: double.infinity,
                keyboardType: TextInputType.number,
                obscureText: false,
                hintText: 'Shipment Length',
                prefixIcon: Icons.trolley,
                suffix: Text(
                  "cm",
                  style: appStyle(
                      size: 12.sp,
                      color: Kcolor.primary,
                      fontWeight: FontWeight.w400),
                ),
                controller: shipmentLengthController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shipment Size';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              //width
              StyledFormField(
                suffix: Text(
                  "cm",
                  style: appStyle(
                      size: 12.sp,
                      color: Kcolor.primary,
                      fontWeight: FontWeight.w400),
                ),
                width: double.infinity,
                keyboardType: TextInputType.number,
                obscureText: false,
                hintText: 'Shipment Width',
                prefixIcon: Icons.trolley,
                controller: shipmentWidthController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shipment Size';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              //height
              StyledFormField(
                suffix: Text(
                  "cm",
                  style: appStyle(
                      size: 12.sp,
                      color: Kcolor.primary,
                      fontWeight: FontWeight.w400),
                ),
                width: double.infinity,
                keyboardType: TextInputType.number,
                obscureText: false,
                hintText: 'Shipment Height',
                prefixIcon: Icons.trolley,
                controller: shipmentHeightController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shipment Size';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 50.h),
              //btn
              Center(
                child: Obx(
                  () => ElevBtn1(
                    width: 300.w,
                    icon: orderController.isLoading.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                                color: Kcolor.background))
                        : Text(
                            "SUBMIT ORDER",
                            style: appStyle(
                                size: 18.sp,
                                color: Kcolor.background,
                                fontWeight: FontWeight.w600),
                          ),
                    textColor: Kcolor.background,
                    bgColor: Kcolor.primary,
                    func: () {
                      if (sourceCountry != "" &&
                          shipmentHeightController.text.isNotEmpty &&
                          shipmentWidthController.text.isNotEmpty &&
                          shipmentLengthController.text.isNotEmpty &&
                          shipmentWeightController.text.isNotEmpty &&
                          shipmentTypeController.text.isNotEmpty) {
                        orderController.addShipment(ShipmentModel(
                          shipmentType: shipmentTypeController.text,
                          shipmentWeight:
                              double.parse(shipmentWeightController.text),
                          shipmentSize: {
                            "width": shipmentWidthController.text,
                            "height": shipmentHeightController.text,
                            "length": shipmentLengthController.text,
                          },
                          submitedDate:
                              "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                          senderId:
                              customerController.currentCustomer.value.uid,
                          receiverName: customerController
                              .currentCustomer.value.companyName,
                          senderAddress: sourceCountry,
                          receiverAddress: customerController
                              .currentCustomer.value.companyAddress,
                          shipmentStatus: ShipmentStatus.waitingApproval,
                        ));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
