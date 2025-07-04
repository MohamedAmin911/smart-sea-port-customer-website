import 'package:final_project_customer_website/blockchain_test_screen.dart';
import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/authentication_controller.dart';
import 'package:final_project_customer_website/view/screens/authentication_screens/main_screen.dart';
import 'package:final_project_customer_website/view/screens/authentication_screens/signup_or_login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDBicds8Fdspr6n377IdIRLjRAsOXzL124",
        authDomain: "smart-port-8ba03.firebaseapp.com",
        databaseURL: "https://smart-port-8ba03-default-rtdb.firebaseio.com",
        projectId: "smart-port-8ba03",
        storageBucket: "smart-port-8ba03.firebasestorage.app",
        messagingSenderId: "701859352905",
        appId: "1:701859352905:web:a7c28811f63f18d47d0a98"),
  );
  Get.put(AuthController());
  // Get.put(ShipController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(MediaQuery.of(context).copyWith().size.width,
            MediaQuery.of(context).copyWith().size.height),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Port',
            theme: ThemeData(
              scaffoldBackgroundColor: Kcolor.background,
              appBarTheme: AppBarTheme(
                toolbarHeight: 80.h,
                centerTitle: true,
                elevation: 0,
                backgroundColor: Kcolor.background,
                iconTheme: const IconThemeData(size: 60),
                titleTextStyle: appStyle(
                        size: 30.sp,
                        color: Kcolor.primary,
                        fontWeight: FontWeight.bold)
                    .copyWith(letterSpacing: 4.r),
              ),
              colorScheme: ColorScheme.fromSeed(seedColor: Kcolor.background),
              useMaterial3: false,
            ),
            home:
                // TestContainerApiScreen(),

                // const PaymentScreen(),

                // const SignUpOrLogInScreen(),
                const MainScreen(),
          );
        });
  }
}
