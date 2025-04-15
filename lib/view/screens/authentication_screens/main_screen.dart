import 'package:final_project_customer_website/controller/authentication_controller.dart';
import 'package:final_project_customer_website/view/screens/authentication_screens/signup_or_login_screen.dart';
import 'package:final_project_customer_website/view/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: authController.isRememberMe.value
            ? const TabsScreen()
            : const SignUpOrLogInScreen(),
      ),
    );
  }
}
