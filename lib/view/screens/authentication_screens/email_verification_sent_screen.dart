import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class EmailVerificationSentScreen extends StatelessWidget {
  const EmailVerificationSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.h,
        bottomOpacity: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "",
        ),
        leadingWidth: 70.w,
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Email Verification Sent",
                style: appStyle(
                  color: Kcolor.accent,
                  size: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Please check your email to verify your account",
                style: appStyle(
                  size: 20,
                  color: Kcolor.accent,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
