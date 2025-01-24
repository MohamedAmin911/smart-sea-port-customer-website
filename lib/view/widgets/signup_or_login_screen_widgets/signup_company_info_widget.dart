import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/authentication_controller.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/styled_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CompanyInfoFields extends StatelessWidget {
  const CompanyInfoFields({
    super.key,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController companyNameController,
    required TextEditingController companyPhoneNumber,
    required TextEditingController companyAddress,
    required TextEditingController companyCity,
    required TextEditingController companyRegistrationNumber,
    required TextEditingController companyImportLicenseNumber,
    required this.isWideScreen,
    required GlobalKey<FormState> formKey,
  })  : _emailController = emailController,
        _passwordController = passwordController,
        _companyNameController = companyNameController,
        _companyPhoneNumber = companyPhoneNumber,
        _companyAddress = companyAddress,
        _companyCity = companyCity,
        _companyRegistrationNumber = companyRegistrationNumber,
        _companyImportLicenseNumber = companyImportLicenseNumber,
        _formKey = formKey;

  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final TextEditingController _companyNameController;
  final TextEditingController _companyPhoneNumber;
  final TextEditingController _companyAddress;
  final TextEditingController _companyCity;
  final TextEditingController _companyRegistrationNumber;
  final TextEditingController _companyImportLicenseNumber;
  final bool isWideScreen;
  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    return Column(
      children: [
        SizedBox(height: 50.h),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Email Field
                  StyledFormField(
                    width: 600,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    hintText: 'Company email address',
                    prefixIcon: Icons.email_rounded,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      final emailRegex = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  // Password Field
                  StyledFormField(
                    width: 600,
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
                      if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                        return 'Password must contain at least one special character';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  // Company Name Field
                  StyledFormField(
                    width: 600,
                    keyboardType: TextInputType.name,
                    obscureText: false,
                    hintText: 'Company name',
                    prefixIcon: Icons.business_rounded,
                    controller: _companyNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 5) {
                        return 'Please enter company name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  // Company Phone Number Field
                  StyledFormField(
                    width: 600,
                    keyboardType: TextInputType.phone,
                    obscureText: false,
                    hintText: 'Company phone number',
                    prefixIcon: Icons.phone_rounded,
                    controller: _companyPhoneNumber,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Please enter a valid numeric phone number';
                      }
                      if (value.length < 7 || value.length > 15) {
                        return 'Phone number must be between 7 and 15 digits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Company Address Field
                  StyledFormField(
                    width: 600,
                    keyboardType: TextInputType.streetAddress,
                    obscureText: false,
                    hintText: 'Company address',
                    prefixIcon: Icons.pin_drop_rounded,
                    controller: _companyAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a company address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  // City Field
                  StyledFormField(
                    width: 600,
                    keyboardType: TextInputType.text,
                    obscureText: false,
                    hintText: 'City',
                    prefixIcon: Icons.location_city_rounded,
                    controller: _companyCity,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a city name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  // Registration Number Field
                  StyledFormField(
                    width: 600,
                    keyboardType: TextInputType.number,
                    obscureText: false,
                    hintText: 'Registration Number/Tax ID',
                    prefixIcon: Icons.perm_identity_rounded,
                    controller: _companyRegistrationNumber,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a registration number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  // Import License Number Field
                  StyledFormField(
                    width: 600,
                    keyboardType: TextInputType.number,
                    obscureText: false,
                    hintText: 'Import License Number',
                    prefixIcon: Icons.credit_card_rounded,
                    controller: _companyImportLicenseNumber,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an import license number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 100.h),

        // Register Button
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
                    "REGISTER",
                    style: appStyle(
                      size: 15.sp,
                      color: Kcolor.background,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            textColor: Kcolor.background,
            bgColor: Kcolor.primary,
            func: () {
              if (_formKey.currentState!.validate()) {
                authController.registerUser(
                    _emailController.text, _passwordController.text, context);
              }
            },
          ),
        ),
      ],
    );
  }
}
