import 'package:final_project_customer_website/constants/colors.dart';
import 'package:final_project_customer_website/constants/text.dart';
import 'package:final_project_customer_website/controller/authentication_controller.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileTextField extends StatefulWidget {
  const ProfileTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.prefixIcon,
      required this.lableText,
      required this.function,
      required this.isEdited,
      required this.isLoaded});
  final void Function() function;
  final TextEditingController controller;
  final String hintText;
  final String lableText;
  final IconData prefixIcon;
  final bool isEdited;
  final bool isLoaded;
  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  final CustomerController customerController = Get.put(CustomerController());
  final AuthController authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: widget.isEdited == false ? true : false,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: widget.lableText,
        labelStyle: appStyle(
            size: 13.sp, color: Kcolor.primary, fontWeight: FontWeight.w400),
        hintText: widget.hintText,
        hintStyle: appStyle(
            size: 15.sp,
            color: widget.isEdited ? Kcolor.background : Kcolor.primary,
            fontWeight: FontWeight.w500),
        prefixIcon: Icon(widget.prefixIcon, color: Kcolor.primary),
        suffixIcon: MaterialButton(
          onPressed: () {
            widget.function();
          },
          child: widget.isLoaded
              ? const CircularProgressIndicator(
                  color: Kcolor.primary) // Show loading
              : Icon(
                  widget.isEdited ? Icons.check : Icons.edit,
                  color: Kcolor.primary,
                ),
        ),
        alignLabelWithHint: true,
        constraints: const BoxConstraints(minHeight: 50, maxWidth: 400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Kcolor.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Kcolor.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Kcolor.primary, width: 2),
        ),
      ),
      style: appStyle(
          size: 15.sp, color: Kcolor.primary, fontWeight: FontWeight.w500),
    );
  }
}
