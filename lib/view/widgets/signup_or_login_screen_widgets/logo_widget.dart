import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildLogo() {
  return FittedBox(
    fit: BoxFit.contain,
    child: SvgPicture.asset(
      KIconAssets.smartPortLogo,
      color: Kcolor.primary,
      width: 400.w,
      height: 400.h,
    ),
  );
}
