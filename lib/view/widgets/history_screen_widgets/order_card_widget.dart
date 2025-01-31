import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderCardWidget extends StatelessWidget {
  const OrderCardWidget({
    super.key,
    required this.id,
    required this.date,
    required this.from,
    required this.to,
    required this.status,
    required this.cost,
  });
  final String id;
  final String date;
  final String from;
  final String to;
  final String status;
  final String cost;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: Kcolor.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //id
            SizedBox(
              width: 200.w,
              child: Text(
                maxLines: 1,
                id,
                overflow: TextOverflow.ellipsis,
                style: appStyle(
                    size: 18.sp,
                    color: Kcolor.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
            //date
            SizedBox(
              width: 200.w,
              child: Text(
                maxLines: 1,
                date,
                overflow: TextOverflow.ellipsis,
                style: appStyle(
                    size: 18.sp,
                    color: Kcolor.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
            //from
            SizedBox(
              width: 200.w,
              child: Text(
                maxLines: 1,
                from,
                overflow: TextOverflow.ellipsis,
                style: appStyle(
                    size: 18.sp,
                    color: Kcolor.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
            //to
            SizedBox(
              width: 200.w,
              child: Text(
                maxLines: 1,
                to,
                overflow: TextOverflow.ellipsis,
                style: appStyle(
                    size: 18.sp,
                    color: Kcolor.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
            //status
            Row(
              children: [
                SizedBox(
                  width: 100.w,
                  height: 30.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Kcolor.primary,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Center(
                      child: Text(
                        maxLines: 1,
                        status,
                        overflow: TextOverflow.ellipsis,
                        style: appStyle(
                            size: 18.sp,
                            color: Kcolor.background,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 100.w),
              ],
            ),
            //cost
            SizedBox(
              width: 200.w,
              child: Text(
                maxLines: 1,
                cost,
                overflow: TextOverflow.ellipsis,
                style: appStyle(
                    size: 18.sp,
                    color: Kcolor.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
