import 'package:dio/dio.dart' as dioo;
import 'package:final_project_customer_website/constants/apikeys.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/screens/iframes_screen.dart';
import 'package:final_project_customer_website/view/screens/tracking_screen.dart';
import 'package:get/get.dart';

class PayMobController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    await getPaymentStatus(orderController.shipmentsList
        .firstWhere((shipment) =>
            shipment.shipmentStatus.name == ShipmentStatus.waitngPayment.name)
        .orderId);
  }

  final CustomerController customerController = Get.put(CustomerController());
  final OrderController orderController = Get.put(OrderController());

  final dio = dioo.Dio();
  RxBool isPaid = false.obs;
  RxBool isLoading = false.obs;
  Future<void> payWithPaymob(int amount) async {
    try {
      isLoading.value = true;
      String token = await getToken();
      int orderId = await getOrderId(token, (100 * amount).toString());
      String paymentKey = await getPaymentKey(
          token, orderId.toString(), (100 * amount).toString());

      // Update the shipment with the order ID
      final shipment = orderController.shipmentsList.firstWhere(
        (shipment) =>
            shipment.shipmentStatus.name == ShipmentStatus.waitngPayment.name,
      );

      await orderController.updateShipmentOrderId(
          shipment.shipmentId, orderId.toString());

      // Open payment iframe
      Get.dialog(
        PaymobPaymentDialog(
          paymentUrl:
              'https://accept.paymob.com/api/acceptance/iframes/914607?payment_token=$paymentKey',
          onCompletion: (success) async {
            if (success) {
              final verified = await verifyPayment(orderId.toString(), token) &&
                  await _verifyPaymentOnServer(paymentKey);

              if (verified) {
                isPaid.value = true;
                // Update the shipment status
                do {
                  await orderController.updateShipmentPaymentStatus(
                      shipment.shipmentId, true);
                } while (orderController.shipmentsList
                        .firstWhere((shipment) =>
                            shipment.shipmentStatus.name ==
                            ShipmentStatus.waitngPayment.name)
                        .shipmentStatus
                        .name !=
                    ShipmentStatus.inTransit.name);
                Get.offAll(() => TrackingScreen()); // Force navigation back
              }
            }
          },
        ),
        barrierDismissible: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _verifyPaymentOnServer(String paymentToken) async {
    try {
      // 1. First get transaction details from Paymob
      final authToken = await getToken();
      final transactionResponse = await dio.get(
        'https://accept.paymob.com/api/acceptance/transactions/$paymentToken',
        options: dioo.Options(headers: {
          'Authorization': 'Bearer $authToken',
        }),
      );

      final transactionId = transactionResponse.data['id'];
      final orderId = transactionResponse.data['order']['id'];
      final amountCents = transactionResponse.data['amount_cents'];

      // 2. Verify with your backend server
      final response = await dio.post(
        '${KapiKeys.payMobApiKey}/verify-payment', // Replace with your endpoint
        data: {
          'transaction_id': transactionId,
          'order_id': orderId,
          'payment_token': paymentToken,
          'amount_cents': amountCents,
        },
        options: dioo.Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${KapiKeys.payMobSecretKey}',
        }),
      );

      if (response.statusCode == 200) {
        print("successsssssssssssssssssssssssssssss");
        return response.data['success'] == true &&
            response.data['verified'] == true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
          'Verification Error', 'Could not verify payment with server');
      return false;
    }
  }

  Future<String> getToken() async {
    try {
      dioo.Response response = await dio.post(
          "https://accept.paymob.com/api/auth/tokens",
          data: {"api_key": KapiKeys.payMobApiKey});
      return response.data['token'];
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getOrderId(String token, String amount) async {
    try {
      dioo.Response response = await dio
          .post("https://accept.paymob.com/api/ecommerce/orders", data: {
        "auth_token": token,
        "delivery_needed": "false",
        "amount_cents": amount,
        "currency": "EGP",
        "items": []
      });

      return response.data['id'];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getPaymentKey(
      String token, String orderId, String amount) async {
    try {
      dioo.Response response = await dio
          .post("https://accept.paymob.com/api/acceptance/payment_keys", data: {
        "auth_token": token,
        "amount_cents": "100",
        "expiration": 3600,
        "currency": "EGP",
        "order_id": orderId,
        "integration_id": KapiKeys.payMobIntegrationId,
        "billing_data": {
          "apartment": "NA",
          "email": customerController.currentCustomer.value.companyEmail,
          "floor": "NA",
          "first_name": customerController.currentCustomer.value.companyName,
          "street": customerController.currentCustomer.value.companyAddress,
          "building": "NA",
          "phone_number":
              customerController.currentCustomer.value.companyPhoneNumber,
          "shipping_method": "NA",
          "postal_code": "NA",
          "city": customerController.currentCustomer.value.companyCity,
          "country": "EG",
          "last_name": "NA",
          "state": "NA"
        },
        "lock_order_when_paid": "false"
      });
      print(response.data['token']);
      return response.data['token'];
    } catch (e) {
      print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
      rethrow;
    }
  }

  Future<bool> verifyPayment(String transactionId, String authToken) async {
    try {
      final response = await dio.get(
        'https://accept.paymob.com/api/acceptance/transactions/$transactionId',
        options: dioo.Options(headers: {
          'Authorization': 'Bearer $authToken',
        }),
      );

      // Check response data
      if (response.statusCode == 200) {
        final transactionData = response.data;
        final bool isSuccess = transactionData['success'] == true &&
            transactionData['is_voided'] == false &&
            transactionData['is_refunded'] == false &&
            transactionData['is_3d_secure'] == true &&
            transactionData['is_captured'] == true &&
            transactionData['pending'] == false;
        print(isSuccess);
        return isSuccess;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to verify payment: ${e.toString()}');
      return false;
    }
  }

  Future<void> getPaymentStatus(String orderID) async {
    try {
      isLoading.value = true;
      // 1. First get the authentication token
      final authToken = await getToken();

      // 2. Make the request with proper authentication
      final response = await dio.post(
        "https://accept.paymob.com/api/ecommerce/orders/transaction_inquiry",
        options: dioo.Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "order_id": orderID,
        },
      );

      isLoading.value = false;

      if (response.data["success"] == true) {
        await orderController.updateShipmentPaymentStatus(
            orderController.shipmentsList
                .firstWhere((shipment) =>
                    shipment.shipmentStatus.name ==
                    ShipmentStatus.waitngPayment.name)
                .shipmentId,
            true);

        print("successsssssssssssssssssssssssssssss");
        await orderController
            .fetchUserShipments(customerController.currentCustomer.value.uid);

        // await shipController.initializePositions(orderController.shipmentsList
        //     .firstWhere((shipment) =>
        //         shipment.shipmentStatus.name == ShipmentStatus.inTransit.name)
        //     .senderAddress);

        orderController.postContainerId(orderController.shipmentsList
            .firstWhere((shipment) =>
                shipment.shipmentStatus.name == ShipmentStatus.inTransit.name)
            .containerId);

        isLoading.value = false;
      } else {
        await orderController.updateShipmentPaymentStatus(
            orderController.shipmentsList
                .firstWhere((shipment) =>
                    shipment.shipmentStatus.name ==
                    ShipmentStatus.waitngPayment.name)
                .shipmentId,
            false);
        isLoading.value = false;
      }
    } catch (e) {
      rethrow;
    }
  }
}
