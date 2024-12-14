import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/view/screens/authentication_screens/signup_screen.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/outlined_elev_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Widget buildButtons() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ElevBtn1(
        func: () {
          Get.to(const SignUpScreen());
        },
        bgColor: Kcolor.primary,
        text: "REGISTER",
        textColor: Kcolor.background,
        width: 300.w,
      ),
      SizedBox(height: 20.h),
      SizedBox(
        width: 300.w,
        child: OutlinedElevBtn(
          func: () {},
          bgColor: Kcolor.background,
          borderColor: Kcolor.primary,
          text: "LOGIN",
          textColor: Kcolor.primary,
          width: 300.w,
        ),
      ),
    ],
  );
}
