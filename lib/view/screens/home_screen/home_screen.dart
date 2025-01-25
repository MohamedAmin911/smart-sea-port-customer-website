import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/authentication_controller.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80.h,
          bottomOpacity: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "REGISTER",
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
              children: [
                const SizedBox(height: 20),
                ElevBtn1(
                  width: 400.w,
                  icon: authController.isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                              color: Kcolor.background))
                      : Text(
                          "SIGN OUT",
                          style: appStyle(
                            size: 15.sp,
                            color: Kcolor.background,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  textColor: Kcolor.background,
                  bgColor: Kcolor.primary,
                  func: () {
                    authController.signOut(context);
                  },
                )
              ],
            ),
          ),
        ));
  }
}
