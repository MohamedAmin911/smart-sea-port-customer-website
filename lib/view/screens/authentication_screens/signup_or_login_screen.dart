import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/view/widgets/signup_or_login_screen_widgets/logo_widget.dart';
import 'package:final_project_customer_website/view/widgets/signup_or_login_screen_widgets/signup_login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpOrLogInScreen extends StatelessWidget {
  const SignUpOrLogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Kcolor.background,
      body: Center(
        // Center the content
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 20.w, vertical: 40.h), // Increased vertical padding
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Added for small screens
                child: ConstrainedBox(
                  // Prevents unbounded height issues
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    // Makes Column take only necessary height
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround, // Distribute space
                      children: [
                        buildLogo(),
                        buildButtons(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
