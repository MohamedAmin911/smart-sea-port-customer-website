// import 'package:flutter/material.dart';
// import 'package:final_project_customer_website/constants/colors.dart';
// import 'package:final_project_customer_website/constants/icon_assets.dart';
// import 'package:final_project_customer_website/constants/text.dart';
// import 'package:final_project_customer_website/controller/customer_controller.dart';
// import 'package:final_project_customer_website/controller/order_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_instance/get_instance.dart';
// import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

// class CustomAppBar extends StatefulWidget {
//   const CustomAppBar({super.key, required this.title});
//   final String title;
//   @override
//   State<CustomAppBar> createState() => _CustomAppBarState();
// }

// class _CustomAppBarState extends State<CustomAppBar> {
//   final customerController = Get.put(CustomerController());

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       toolbarHeight: 80.h,
//       bottomOpacity: 0,
//       automaticallyImplyLeading: false,
//       centerTitle: true,
//       title: Text(
//         widget.title,
//         style: appStyle(
//             size: 30.sp, color: Kcolor.primary, fontWeight: FontWeight.bold),
//       ),
//       leadingWidth: 70.w,
//       actions: [
//         Obx(
//           () => Column(
//             children: [
//               SizedBox(height: 8.h),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       SizedBox(height: 7.h),
//                       Text(customerController.currentCustomer.value.companyName,
//                           style: appStyle(
//                               size: 20.sp,
//                               color: Kcolor.primary,
//                               fontWeight: FontWeight.bold)),
//                       SizedBox(height: 5.h),
//                       Text(
//                           customerController.currentCustomer.value.companyEmail,
//                           style: appStyle(
//                               size: 12.sp,
//                               color: Kcolor.primary,
//                               fontWeight: FontWeight.w400)),
//                     ],
//                   ),
//                   SizedBox(width: 5.w),
//                   Icon(
//                     Icons.corporate_fare_rounded,
//                     color: Kcolor.primary,
//                     size: 55.sp,
//                   ),
//                   SizedBox(width: 8.w),
//                 ],
//               ),
//             ],
//           ),
//         )
//       ],
//       leading: Padding(
//         padding: EdgeInsets.only(left: 15.w, top: 15.h),
//         child: SvgPicture.asset(
//           KIconAssets.smartPortLogo,
//           color: Kcolor.primary,
//           width: 100.w,
//           height: 100.h,
//         ),
//       ),
//     );
//   }
// }
