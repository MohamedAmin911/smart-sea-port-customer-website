import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _focusedDay;
  late DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDate;
    _focusedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      width: 400.w,
      height: 440.h,
      decoration: BoxDecoration(
        color: Kcolor.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Kcolor.primary,
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Text(
                  "Estimated arrival: July 19, 2024",
                  textAlign: TextAlign.start,
                  style: appStyle(
                      size: 13.sp,
                      color: Kcolor.background,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Kcolor.primary,
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Text(
                  "7 days left",
                  textAlign: TextAlign.start,
                  style: appStyle(
                      size: 13.sp,
                      color: Kcolor.primary,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          TableCalendar(
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.primary,
                  fontWeight: FontWeight.bold),
              weekendStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.primary,
                  fontWeight: FontWeight.bold),
            ),
            headerStyle: HeaderStyle(
              rightChevronIcon: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Kcolor.primary,
              ),
              leftChevronIcon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Kcolor.primary,
              ),
              titleCentered: true,
              formatButtonVisible: false,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Kcolor.primary,
                borderRadius: BorderRadius.circular(22.r),
              ),
              titleTextStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.primary,
                  fontWeight: FontWeight.bold),
            ),
            calendarStyle: CalendarStyle(
              outsideTextStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.primary,
                  fontWeight: FontWeight.bold),
              weekendTextStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.primary,
                  fontWeight: FontWeight.bold),
              weekNumberTextStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.primary,
                  fontWeight: FontWeight.bold),
              todayTextStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.primary,
                  fontWeight: FontWeight.bold),
              selectedTextStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.background,
                  fontWeight: FontWeight.bold),
              holidayTextStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.primary,
                  fontWeight: FontWeight.bold),
              defaultTextStyle: appStyle(
                  size: 14.sp,
                  color: Kcolor.primary,
                  fontWeight: FontWeight.bold),
              selectedDecoration: const BoxDecoration(
                color: Kcolor.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                border: Border.all(
                  color: Kcolor.primary,
                  width: 2.w,
                ),
                shape: BoxShape.circle,
              ),
              defaultDecoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              // setState(() {
              //   _selectedDay = selectedDay;
              //   _focusedDay = focusedDay;
              // });
              // widget.onDateSelected(selectedDay);
            },
            calendarFormat: CalendarFormat.month,
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        ],
      ),
    );
  }
}
