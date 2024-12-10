import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/view/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Port',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Kcolor.background),
              useMaterial3: true,
            ),
            home: const MainScreen(),
          );
        });
  }
}
