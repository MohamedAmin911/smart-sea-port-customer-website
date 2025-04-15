import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
