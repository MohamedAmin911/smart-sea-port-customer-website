import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CostsWidget2 extends StatelessWidget {
  const CostsWidget2({
    super.key,
    required this.currentShipment,
  });
  final ShipmentModel currentShipment;
  @override
  Widget build(BuildContext context) {
    final double customsFees =
        (((double.parse(currentShipment.shipmentSize["length"]) * 0.01) *
                    (double.parse(currentShipment.shipmentSize["width"]) *
                        0.01) *
                    (double.parse(currentShipment.shipmentSize["height"]) *
                        0.01)) *
                100) *
            50.abs();

    final double shippingCharges =
        currentShipment.shippingCost - ((1000 * 50) + (customsFees)).ceil();

    final double additionalCharges = currentShipment.shippingCost -
        ((shippingCharges) + (customsFees)).ceil();
    return Column(
      children: [
        SizedBox(
          height: 28.h,
        ),
        Container(
            width: 430,
            height: 400.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: Kcolor.primary.withValues(alpha: 0.2),
                width: 2.w,
              ),
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cost Overview",
                  textAlign: TextAlign.start,
                  style: appStyle(
                      size: 13.sp,
                      color: Kcolor.primary,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20.h),
                Text(
                  "${currentShipment.shippingCost.ceil()} EGP",
                  textAlign: TextAlign.start,
                  style: appStyle(
                      size: 40.sp,
                      color: Kcolor.primary,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                Text(
                  "Total Costs",
                  textAlign: TextAlign.start,
                  style: appStyle(
                      size: 13.sp,
                      color: Kcolor.primary.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //customs fees
                      Container(
                        // width: 250.w,
                        height: 70.h,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Kcolor.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Customs Fees",
                                  textAlign: TextAlign.start,
                                  style: appStyle(
                                      size: 13.sp,
                                      color:
                                          Kcolor.primary.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "${customsFees.ceil()} EGP",
                                  textAlign: TextAlign.start,
                                  style: appStyle(
                                      size: 20.sp,
                                      color: Kcolor.primary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              Icons.policy_rounded,
                              color: Kcolor.primary,
                              size: 40.r,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),

                      //shipping charges
                      Container(
                        // width: 250.w,
                        height: 70.h,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Kcolor.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Shipping Charges",
                                  textAlign: TextAlign.start,
                                  style: appStyle(
                                      size: 13.sp,
                                      color:
                                          Kcolor.primary.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "${shippingCharges.ceil()} EGP",
                                  textAlign: TextAlign.start,
                                  style: appStyle(
                                      size: 20.sp,
                                      color: Kcolor.primary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              Icons.directions_boat_rounded,
                              color: Kcolor.primary,
                              size: 40.r,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.h),

                      //additional charges
                      Container(
                        // width: 250.w,
                        height: 70.h,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Kcolor.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Additional Charges",
                                  textAlign: TextAlign.start,
                                  style: appStyle(
                                      size: 13.sp,
                                      color:
                                          Kcolor.primary.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "${additionalCharges.ceil()} EGP",
                                  textAlign: TextAlign.start,
                                  style: appStyle(
                                      size: 20.sp,
                                      color: Kcolor.primary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(
                              Icons.price_change_rounded,
                              color: Kcolor.primary,
                              size: 40.r,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )),
      ],
    );
  }
}
