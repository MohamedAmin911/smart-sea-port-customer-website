import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/view/screens/authentication_screens/signup_or_login_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Kcolor.background, body: SignUpOrLogInScreen());
  }
}
