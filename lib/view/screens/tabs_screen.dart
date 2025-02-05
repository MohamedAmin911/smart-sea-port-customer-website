import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/view/screens/history_screen.dart';
import 'package:final_project_customer_website/view/screens/profile_screen.dart';
import 'package:final_project_customer_website/view/screens/tracking_screen.dart';
import 'package:final_project_customer_website/view/widgets/home_screen_widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = [
    const Tab(
      text: 'Tracking',
    ),
    const Tab(
      text: 'History',
    ),
    const Tab(
      text: 'Profile',
    ),
  ];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  PageController controller = PageController();
  final CustomerController customerController = Get.put(CustomerController());
  final OrderController ordersController = Get.put(OrderController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.h,
        bottomOpacity: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: SizedBox(
          height: 60.h,
          width: 400.w,
          child: TabBarWidget(
              tabController: _tabController,
              tabs: _tabs,
              controller: controller),
        ),
        leadingWidth: 70.w,
        actions: [
          Obx(
            () => Column(
              children: [
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 7.h),
                        Text(
                            customerController
                                .currentCustomer.value.companyName,
                            style: appStyle(
                                size: 20.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 5.h),
                        Text(
                            customerController
                                .currentCustomer.value.companyEmail,
                            style: appStyle(
                                size: 12.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w400)),
                      ],
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      Icons.corporate_fare_rounded,
                      color: Kcolor.primary,
                      size: 55.sp,
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ],
            ),
          )
        ],
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
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          TrackingScreen(),
          HistoryScreen(),
          ProfileScreen(),
        ],
      ),
    );
  }
}
