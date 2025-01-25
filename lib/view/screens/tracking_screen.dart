import 'package:final_project_customer_website/controller/authentication_controller.dart';
import 'package:final_project_customer_website/view/widgets/signup_or_login_screen_widgets/signout_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());

    return Scaffold(
      body: Center(
        child: SignOutButton(authController: authController),
      ),
    );
  }
}
