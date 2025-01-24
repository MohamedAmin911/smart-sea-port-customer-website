import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/authentication_controller.dart';
import 'package:final_project_customer_website/view/screens/authentication_screens/signup_screen.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/styled_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600; // Check for wide screens

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.h,
        bottomOpacity: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "LOGIN",
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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: 400.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50.h),
                      // Email Field
                      StyledFormField(
                        width: 400,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        hintText: 'Company email address',
                        prefixIcon: Icons.email_rounded,
                        controller: _emailController,
                      ),
                      SizedBox(height: 10.h),
                      // Password Field
                      StyledFormField(
                        width: 400,
                        keyboardType: TextInputType.visiblePassword,
                        hintText: 'Password',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Password must contain at least one uppercase letter';
                          }
                          if (!value.contains(RegExp(r'[a-z]'))) {
                            return 'Password must contain at least one lowercase letter';
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Password must contain at least one digit';
                          }
                          if (!value
                              .contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                            return 'Password must contain at least one special character';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 5.h),

                      //remember me
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Obx(
                            () => Checkbox(
                              value: authController
                                  .isRememberMe.value, // Bind to state
                              onChanged: (isChecked) async {
                                authController.isRememberMe.value = isChecked!;
                                await authController.saveRememberMe(isChecked);
                                await authController.loadRememberMe();
                              },
                              checkColor: Kcolor.background,
                              focusColor: Kcolor.primary,
                              activeColor: Kcolor.primary,
                              side: const BorderSide(color: Kcolor.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Remember me.",
                            style: appStyle(
                              size: 15.sp,
                              color: Kcolor.primary,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15.h),

                      // LogIn Button
                      Obx(
                        () => ElevBtn1(
                          width: isWideScreen ? 400.w : double.infinity,
                          icon: authController.isLoading
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(
                                      color: Kcolor.background))
                              : Text(
                                  "LOGIN",
                                  style: appStyle(
                                    size: 15.sp,
                                    color: Kcolor.background,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                          textColor: Kcolor.background,
                          bgColor: Kcolor.primary,
                          func: () {
                            authController.signInUser(_emailController.text,
                                _passwordController.text, context);
                          },
                        ),
                      ),
                      SizedBox(height: 25.h),

                      //don't have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Text(
                            "Don't have account?",
                            style: appStyle(
                              size: 15.sp,
                              color: Kcolor.primary.withOpacity(0.2),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          // SizedBox(width: 10.w),
                          TextButton(
                            onPressed: () {
                              Get.off(const SignUpScreen());
                            },
                            child: Text(
                              " Register",
                              style: appStyle(
                                size: 15.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
