import 'package:final_project_customer_website/constants/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElevBtn1 extends StatelessWidget {
  const ElevBtn1(
      {super.key,
      required this.width,
      required this.text,
      required this.textColor,
      required this.bgColor,
      required this.func});
  final double width;
  final String text;
  final Color textColor;
  final Color bgColor;
  final void Function() func;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.r))),
        onPressed: func,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text(
            text,
            style: appStyle(
              size: 15.sp,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
