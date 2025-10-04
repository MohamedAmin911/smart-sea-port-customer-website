import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/icon_assets.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/customer_model.dart';
import 'package:final_project_customer_website/view/screens/history_screen.dart';
import 'package:final_project_customer_website/view/screens/profile_screen.dart';
import 'package:final_project_customer_website/view/screens/tracking_screen.dart';
import 'package:final_project_customer_website/view/widgets/home_screen_widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = [
    const Tab(text: 'Tracking'),
    const Tab(text: 'History'),
    const Tab(text: 'Profile'),
  ];

  PageController controller = PageController();
  final CustomerController customerController = Get.put(CustomerController());
  final OrderController ordersController = Get.put(OrderController());
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        customerController.currentCustomer.value = CustomerModel(
          uid: user.uid,
          companyName: '',
          companyAddress: '',
          companyEmail: '',
          companyPhoneNumber: '',
          companyCity: '',
          companyRegistrationNumber: '',
          companyImportLicenseNumber: '',
          orders: [],
        );
        customerController.fetchCurrentCustomer(user.uid);
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load customer data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: isLoading.value
            ? null
            : customerController.currentCustomer.value.accountStatus.name ==
                    AccountStatus.waitingApproval.name
                ? AppBar(
                    toolbarHeight: 80.h,
                    bottomOpacity: 0,
                    automaticallyImplyLeading: false,
                    centerTitle: true,
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
                  )
                : AppBar(
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
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      customerController
                                          .currentCustomer.value.companyEmail,
                                      style: appStyle(
                                          size: 12.sp,
                                          color: Kcolor.primary,
                                          fontWeight: FontWeight.w400),
                                    ),
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
        body: isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: Kcolor.primary))
            : customerController.currentCustomer.value.uid.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Kcolor.primary))
                : customerController.currentCustomer.value.accountStatus.name ==
                        AccountStatus.waitingApproval.name
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Your Account Is Being Reviewed",
                              style: appStyle(
                                size: 40.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "You will be notified once your account is approved",
                              style: appStyle(
                                size: 16.sp,
                                color: Kcolor.primary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : customerController
                                .currentCustomer.value.accountStatus.name ==
                            AccountStatus.inactive.name
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Your Account Is Deactivated",
                                  style: appStyle(
                                    size: 40.sp,
                                    color: Kcolor.primary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Please contact support for more information",
                                  style: appStyle(
                                    size: 16.sp,
                                    color: Kcolor.primary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : PageView(
                            controller: controller,
                            children: const [
                              TrackingScreen(),
                              HistoryScreen(),
                              ProfileScreen(),
                            ],
                          ),
      ),
    );
  }
}
