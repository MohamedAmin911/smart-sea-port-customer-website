import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/controller/ship_tracking_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';

import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/google_maps_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ShipController shipController = Get.put(ShipController());
    final OrderController ordersController = Get.put(OrderController());

    return Container(
      width: 600.w,
      height: 300.h,
      decoration: BoxDecoration(
        border: Border.all(color: Kcolor.primary, width: 4.w),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child:
          // shipController.currentPosition.value == const LatLng(0, 0) ||
          //             shipController.destinationPosition.value ==
          //                 const LatLng(0, 0) ||
          //             shipController.sourcePosition.value == const LatLng(0, 0)
          //         ? const Center(
          //             child: CircularProgressIndicator(color: Kcolor.primary),
          //           )
          //         :
          ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: ShipMapWidget()),
    );
  }
}
