import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/view/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
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
            home: const MainScreen(),
          );
        });
  }
}
