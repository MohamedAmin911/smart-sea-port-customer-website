import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/authentication_controller.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return ElevBtn1(
      width: 400.w,
      icon: authController.isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(color: Kcolor.background))
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
    );
  }
}
