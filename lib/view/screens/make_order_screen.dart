import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/styled_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MakeOrderScreen extends StatefulWidget {
  const MakeOrderScreen({super.key});

  @override
  State<MakeOrderScreen> createState() => _MakeOrderScreenState();
}

class _MakeOrderScreenState extends State<MakeOrderScreen> {
  final TextEditingController senderAddressController = TextEditingController();
  final TextEditingController receiverAddressController =
      TextEditingController();
  final TextEditingController shippingCostController = TextEditingController();
  final orderController = Get.put(OrderController());
  final customerController = Get.put(CustomerController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.h,
        bottomOpacity: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "MAKE ORDER",
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50.h),
              // Sender Address
              StyledFormField(
                width: 600,
                keyboardType: TextInputType.streetAddress,
                obscureText: false,
                hintText: 'Sender Address',
                prefixIcon: Icons.location_on,
                controller: senderAddressController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter sender address'
                    : null,
              ),
              SizedBox(height: 15.h),

              // Receiver Address
              StyledFormField(
                width: 600,
                keyboardType: TextInputType.streetAddress,
                obscureText: false,
                hintText: 'Receiver Address',
                prefixIcon: Icons.location_on,
                controller: receiverAddressController,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter receiver address'
                    : null,
              ),
              SizedBox(height: 15.h),

              // Shipping Cost
              StyledFormField(
                width: 600,
                keyboardType: TextInputType.number,
                obscureText: false,
                hintText: 'Shipping Cost',
                prefixIcon: Icons.attach_money,
                controller: shippingCostController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter shipping cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 50.h),
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
                      if (senderAddressController.text.isNotEmpty &&
                          receiverAddressController.text.isNotEmpty &&
                          shippingCostController.text.isNotEmpty) {
                        orderController.addShipment(ShipmentModel(
                          submitedDate:
                              "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                          senderId:
                              customerController.currentCustomer.value.uid,
                          senderName: customerController
                              .currentCustomer.value.companyName,
                          senderAddress: senderAddressController.text,
                          receiverAddress: receiverAddressController.text,
                          shipmentStatus: ShipmentStatus.waitingApproval,
                          shippingCost:
                              double.parse(shippingCostController.text),
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
