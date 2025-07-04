import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:flutter/material.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShipmentCheckpoint extends StatelessWidget {
  final ShipmentStatus currentStatus;

  ShipmentCheckpoint({super.key, required this.currentStatus});

  final Map<ShipmentStatus, String> statusLabels = {
    ShipmentStatus.inTransit: "In Transit",
    ShipmentStatus.checkPointA: "Checkpoint A",
    ShipmentStatus.delivered: "Delivered",
    ShipmentStatus.enteredPort: "Entered Port",
    ShipmentStatus.unLoaded: "Unloaded",
    ShipmentStatus.waitingPickup: "Waiting Pickup",
  };

  List<ShipmentStatus> get orderedSteps => [
        ShipmentStatus.inTransit,
        ShipmentStatus.checkPointA,
        ShipmentStatus.delivered,
        ShipmentStatus.enteredPort,
        ShipmentStatus.unLoaded,
        ShipmentStatus.waitingPickup,
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 860.w,
      height: 100.h,
      padding: EdgeInsets.symmetric(
        vertical: 20.h,
      ),
      decoration: BoxDecoration(
        color: Kcolor.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: orderedSteps.map((status) {
            final isActive = orderedSteps.indexOf(status) <=
                orderedSteps.indexOf(currentStatus);
            final isLast = orderedSteps.last == status;

            return Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 8.w),
                    Column(
                      children: [
                        Text(statusLabels[status]!,
                            style: appStyle(
                              size: 15.sp,
                              color: isActive
                                  ? Kcolor.primary
                                  : Kcolor.primary.withValues(alpha: 0.5),
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            )),
                        SizedBox(height: 10.h),
                        //checkpoint icon
                        Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isActive ? Kcolor.primary : Kcolor.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isActive ? Icons.check_rounded : Icons.circle,
                            size: 20.sp,
                            color: Kcolor.background,
                            weight: 1,
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Column(
                        children: [
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? Kcolor.primary
                                      : Kcolor.primary.withValues(alpha: 0.2),
                                  // borderRadius: BorderRadius.circular(22.r),
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? Kcolor.primary
                                      : Kcolor.primary.withValues(alpha: 0.2),
                                  // borderRadius: BorderRadius.circular(22.r),
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? Kcolor.primary
                                      : Kcolor.primary.withValues(alpha: 0.2),
                                  // borderRadius: BorderRadius.circular(22.r),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
