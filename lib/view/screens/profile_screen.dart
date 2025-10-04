import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/authentication_controller.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/elev_btn.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/getx_snackbar.dart';
import 'package:final_project_customer_website/view/widgets/profile_screen_widgets/text_field_widget.dart';
import 'package:final_project_customer_website/view/widgets/signup_or_login_screen_widgets/signout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final companyNameController = TextEditingController();
  final companyEmailController = TextEditingController();
  final companyPhoneNumberController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companyCityController = TextEditingController();
  final companyRegistrationNumberController = TextEditingController();
  final companyImportLicenseNumberController = TextEditingController();
  final CustomerController customerController = Get.put(CustomerController());
  AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        child: SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(height: 50.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      //Company Email
                      Obx(
                        () => ProfileTextField(
                          isEdited: customerController.isEditing1.value,
                          isLoaded: customerController.isLoading1.value,
                          lableText: "Company Email",
                          controller: companyEmailController,
                          hintText: customerController
                              .currentCustomer.value.companyEmail,
                          prefixIcon: Icons.email_rounded,
                          function: () {
                            if (customerController.isEditing1.value) {
                              // If already editing, upload data
                              customerController.updateCustomerData(
                                  customerController.currentCustomer.value.uid,
                                  {
                                    "companyEmail":
                                        companyEmailController.text.trim(),
                                  },
                                  1);
                              getxSnackbar(
                                  title: "Success",
                                  msg: "Profile updated successfully!");
                            } else {
                              // Enable editing mode
                              customerController.isEditing1.value = true;
                            }
                          },
                        ),
                      ),

                      SizedBox(height: 50.h),

                      //Company Name
                      Obx(
                        () => ProfileTextField(
                          isEdited: customerController.isEditing2.value,
                          isLoaded: customerController.isLoading2.value,
                          lableText: "Company Name",
                          controller: companyNameController,
                          hintText: customerController
                              .currentCustomer.value.companyName,
                          prefixIcon: Icons.business_rounded,
                          function: () {
                            if (customerController.isEditing2.value) {
                              // If already editing, upload data
                              customerController.updateCustomerData(
                                  customerController.currentCustomer.value.uid,
                                  {
                                    "companyName":
                                        companyNameController.text.trim(),
                                  },
                                  2);
                              getxSnackbar(
                                  title: "Success",
                                  msg: "Profile updated successfully!");
                            } else {
                              // Enable editing mode
                              customerController.isEditing2.value = true;
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 50.h),

                      //Company number
                      Obx(
                        () => ProfileTextField(
                          isEdited: customerController.isEditing3.value,
                          isLoaded: customerController.isLoading3.value,
                          lableText: "Company Phone Number",
                          controller: companyPhoneNumberController,
                          hintText: customerController
                              .currentCustomer.value.companyPhoneNumber,
                          prefixIcon: Icons.phone_rounded,
                          function: () {
                            if (customerController.isEditing3.value) {
                              // If already editing, upload data
                              customerController.updateCustomerData(
                                  customerController.currentCustomer.value.uid,
                                  {
                                    "companyPhoneNumber":
                                        companyPhoneNumberController.text
                                            .trim(),
                                  },
                                  3);
                              getxSnackbar(
                                  title: "Success",
                                  msg: "Profile updated successfully!");
                            } else {
                              // Enable editing mode
                              customerController.isEditing3.value = true;
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 50.h),
                      //Company address
                      Obx(
                        () => ProfileTextField(
                          isEdited: customerController.isEditing4.value,
                          isLoaded: customerController.isLoading4.value,
                          lableText: "Company Address",
                          controller: companyAddressController,
                          hintText: customerController
                              .currentCustomer.value.companyAddress,
                          prefixIcon: Icons.pin_drop_rounded,
                          function: () {
                            if (customerController.isEditing4.value) {
                              // If already editing, upload data
                              customerController.updateCustomerData(
                                  customerController.currentCustomer.value.uid,
                                  {
                                    "companyAddress":
                                        companyAddressController.text.trim(),
                                  },
                                  4);
                              getxSnackbar(
                                  title: "Success",
                                  msg: "Profile updated successfully!");
                            } else {
                              // Enable editing mode
                              customerController.isEditing4.value = true;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      //Company City
                      Obx(
                        () => ProfileTextField(
                          isEdited: customerController.isEditing5.value,
                          isLoaded: customerController.isLoading5.value,
                          lableText: "Company City",
                          controller: companyCityController,
                          hintText: customerController
                              .currentCustomer.value.companyCity,
                          prefixIcon: Icons.location_city_rounded,
                          function: () {
                            if (customerController.isEditing5.value) {
                              customerController.updateCustomerData(
                                  customerController.currentCustomer.value.uid,
                                  {
                                    "companyCity":
                                        companyCityController.text.trim(),
                                  },
                                  5);
                              getxSnackbar(
                                  title: "Success",
                                  msg: "Profile updated successfully!");
                            } else {
                              // Enable editing mode
                              customerController.isEditing5.value = true;
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 50.h),

                      // Registration Number
                      Obx(
                        () => ProfileTextField(
                          isEdited: customerController.isEditing6.value,
                          isLoaded: customerController.isLoading6.value,
                          lableText: "Registration Number/Tax ID",
                          controller: companyRegistrationNumberController,
                          hintText: customerController
                              .currentCustomer.value.companyRegistrationNumber,
                          prefixIcon: Icons.perm_identity_rounded,
                          function: () {
                            if (customerController.isEditing6.value) {
                              customerController.updateCustomerData(
                                  customerController.currentCustomer.value.uid,
                                  {
                                    "companyRegistrationNumber":
                                        companyRegistrationNumberController.text
                                            .trim(),
                                  },
                                  6);
                              getxSnackbar(
                                  title: "Success",
                                  msg: "Profile updated successfully!");
                            } else {
                              // Enable editing mode
                              customerController.isEditing6.value = true;
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 50.h),

                      // Import License Number
                      Obx(
                        () => ProfileTextField(
                          isEdited: customerController.isEditing7.value,
                          isLoaded: customerController.isLoading7.value,
                          lableText: "Import License Number",
                          controller: companyImportLicenseNumberController,
                          hintText: customerController
                              .currentCustomer.value.companyImportLicenseNumber,
                          prefixIcon: Icons.credit_card_rounded,
                          function: () {
                            if (customerController.isEditing7.value) {
                              customerController.updateCustomerData(
                                  customerController.currentCustomer.value.uid,
                                  {
                                    "companyImportLicenseNumber":
                                        companyImportLicenseNumberController
                                            .text
                                            .trim(),
                                  },
                                  7);
                              getxSnackbar(
                                  title: "Success",
                                  msg: "Profile updated successfully!");
                            } else {
                              customerController.isEditing7.value = true;
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 50.h),
                      ElevBtn1(
                          width: 400.w,
                          icon: Text(
                            "Change Password",
                            style: appStyle(
                              size: 15.sp,
                              color: Kcolor.background,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          textColor: Kcolor.background,
                          bgColor: Kcolor.primary,
                          func: () {}),
                    ],
                  ),
                ),
              ],
            ),
            //sign out button
            SizedBox(height: 80.h),
            Center(
              child: SignOutButton(authController: authController),
            )
          ],
        )),
      ),
    );
  }
}
