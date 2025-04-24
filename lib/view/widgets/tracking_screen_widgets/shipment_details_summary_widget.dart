import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShipmentDetailsSummaryWidget extends StatelessWidget {
  const ShipmentDetailsSummaryWidget({
    super.key,
    required this.currentShipment,
  });

  final ShipmentModel currentShipment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      margin: EdgeInsets.only(bottom: 20.h, top: 30.h),
      width: 600.w,
      height: 200.h,
      decoration: BoxDecoration(
        color: Kcolor.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shipment details summary",
            textAlign: TextAlign.start,
            style: appStyle(
                size: 13.sp,
                color: Kcolor.primary,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 20.h),
          //order id
          Row(
            children: [
              Text(
                "Order #${currentShipment.shipmentId}",
                textAlign: TextAlign.start,
                style: appStyle(
                    size: 20.sp,
                    color: Kcolor.primary,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              //order status
              Container(
                width: 200.w,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Kcolor.primary,
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Center(
                  child: Text(
                    currentShipment.shipmentStatus.name == "inTransit"
                        ? "IN TRANSIT"
                        : currentShipment.shipmentStatus.name == "waitingPickup"
                            ? "WAITING PICKUP"
                            : currentShipment.shipmentStatus.name.toUpperCase(),
                    style: appStyle(
                        size: 13.sp,
                        color: Kcolor.primary,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10.h),
          //shipment type- size
          Text(
            "${currentShipment.shipmentSize["length"]}cm x ${currentShipment.shipmentSize["width"]}cm x ${currentShipment.shipmentSize["height"]}cm - ${currentShipment.shipmentType.toUpperCase()}",
            textAlign: TextAlign.start,
            style: appStyle(
                size: 15.sp,
                color: Kcolor.primary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20.h),
          //source - destination
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 200.w,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Kcolor.primary,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Center(
                  child: Text(
                    currentShipment.senderAddress,
                    style: appStyle(
                        size: 15.sp,
                        color: Kcolor.background,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Row(
                children: [
                  Icon(
                    Icons.arrow_circle_right_rounded,
                    color: Kcolor.primary,
                    size: 30.sp,
                  ),
                  Icon(
                    Icons.arrow_circle_right_rounded,
                    color: Kcolor.primary,
                    size: 30.sp,
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Container(
                width: 200.w,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Kcolor.primary,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Center(
                  child: Text(
                    "Egypt",
                    style: appStyle(
                        size: 15.sp,
                        color: Kcolor.background,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
