import 'package:dio/dio.dart';
import 'package:final_project_customer_website/constants/apikeys.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/getx_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:get/get.dart';

class StripeController extends GetxController {
  Future<void> makePayment() async {
    try {
      String? paymentIntentClientSecret = await createPaymentIntent(10, "USD");
      if (paymentIntentClientSecret != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentClientSecret,
            style: ThemeMode.dark,
            merchantDisplayName: 'Smart Port',
          ),
        );
        await processPayment();
      }
    } catch (e) {
      Get.snackbar("Error", "Payment failed: ${e.toString()}");
      print("Payment error: $e");
    }
  }

  Future<String?> createPaymentIntent(int amount, String currency) async {
    try {
      final dio = Dio();

      final data = {
        "amount": (amount * 100).toString(),
        "currency": currency.toLowerCase(),
        "payment_method_types[]": "card"
      };

      // Convert to form-urlencoded format
      final formData = data.entries
          .map((e) => "${e.key}=${Uri.encodeComponent(e.value)}")
          .join("&");

      final response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer ${KapiKeys.stripeSecretKey}",
            "Content-Type": "application/x-www-form-urlencoded",
          },
          validateStatus: (status) =>
              status! < 500, // Don't throw for 4xx errors
        ),
      );

      if (response.statusCode == 200) {
        return response.data['client_secret']; // Return payment intent ID
      } else {
        print("Stripe API error: ${response.statusCode} - ${response.data}");
        throw Exception(
            "Failed to create payment intent: ${response.data['error']['message']}");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      getxSnackbar(title: "Success", msg: "Payment successful!");
    } catch (e) {
      getxSnackbar(title: "Error", msg: e.toString());
    }
  }
}

// class StripeService {
//   StripeService._();
//   static final StripeService instance = StripeService._();
// }
