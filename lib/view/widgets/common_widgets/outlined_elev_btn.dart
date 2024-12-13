import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutlinedElevBtn extends StatelessWidget {
  const OutlinedElevBtn({
    super.key,
    required this.width,
    required this.text,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
  final double width;
  final String text;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
          side: BorderSide(color: borderColor),
        ),
        backgroundColor: Kcolor.background,
      ),
      onPressed: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          "LOGIN",
          style: appStyle(
            size: 15.sp,
            color: Kcolor.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
