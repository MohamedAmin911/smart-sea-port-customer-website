import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/view/widgets/signup_or_login_screen_widgets/signup_company_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyPhoneNumber = TextEditingController();
  final _companyAddress = TextEditingController();
  final _companyCity = TextEditingController();
  final _companyRegistrationNumber = TextEditingController();
  final _companyImportLicenseNumber = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _companyNameController.dispose();
    _companyPhoneNumber.dispose();
    _companyAddress.dispose();
    _companyCity.dispose();
    _companyRegistrationNumber.dispose();
    _companyImportLicenseNumber.dispose();
    super.dispose();
  }

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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
          child: SingleChildScrollView(
            child: CompanyInfoFields(
                emailController: _emailController,
                passwordController: _passwordController,
                companyNameController: _companyNameController,
                companyPhoneNumber: _companyPhoneNumber,
                companyAddress: _companyAddress,
                companyCity: _companyCity,
                companyRegistrationNumber: _companyRegistrationNumber,
                companyImportLicenseNumber: _companyImportLicenseNumber,
                isWideScreen: isWideScreen,
                formKey: _formKey),
          ),
        ),
      ),
    );
  }
}
