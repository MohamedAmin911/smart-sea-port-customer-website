import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/google_maps_widget3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool isMapReady = true;
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        isMapReady = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600.w,
      height: 320.h,
      decoration: BoxDecoration(
        border: Border.all(
            color: Kcolor.primary.withValues(alpha: 0.2), width: 4.w),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: const MapScreen(),

        // const ShipMap(),

        // ShipMapWidget(),
      ),
    );
  }
}
