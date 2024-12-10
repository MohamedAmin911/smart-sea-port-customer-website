import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Kcolor.background,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(left: 150.w),
          child: Row(
            children: [
              Flexible(
                child: SvgPicture.asset(
                  width: 600.w,
                  fit: BoxFit.fitWidth,
                  color: Kcolor.primary,
                  KIconAssets.smartPortLogo,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
