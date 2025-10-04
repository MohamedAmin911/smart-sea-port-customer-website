// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:convert';
import 'package:final_project_customer_website/constants/apikeys.dart';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/getx_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OrderController extends GetxController {
  final _auth = FirebaseAuth.instance;
  var isLoading = false.obs;
  final DatabaseReference _shipmentRef =
      FirebaseDatabase.instance.ref().child('shipments');

  Rx<ShipmentModel?> currentShipment = Rx<ShipmentModel?>(null);
  RxList<ShipmentModel> shipmentsList = <ShipmentModel>[].obs;
  final CustomerController customerController = Get.put(CustomerController());

  StreamSubscription<DatabaseEvent>? _shipmentsSubscription;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchUserShipments(user.uid);
      } else {
        shipmentsList.clear();
        currentShipment.value = null;
        _shipmentsSubscription?.cancel();
      }
    });
  }

  @override
  void onClose() {
    _shipmentsSubscription?.cancel();
    super.onClose();
  }

  Future<void> addShipment(ShipmentModel shipment) async {
    isLoading.value = true;
    try {
      String? shipmentId = _shipmentRef.push().key;
      if (shipmentId != null && shipmentId.isNotEmpty) {
        shipment.shipmentId = shipmentId.toUpperCase();
        await _shipmentRef.child(shipment.shipmentId).set(shipment.toJson());

        List<String> updatedOrders =
            List.from(customerController.currentCustomer.value.orders)
              ..add(shipment.shipmentId);

        await customerController.updateCustomerData(
          customerController.currentCustomer.value.uid,
          {
            'orders': updatedOrders,
            'currentOrderId': shipment.shipmentId,
          },
          1,
        );

        isLoading.value = false;
        Get.back();
        getxSnackbar(
          title: "Success",
          msg: "Order submitted successfully, please wait for approval.",
        );
      } else {
        throw Exception('Failed to generate shipment ID');
      }
    } catch (e) {
      isLoading.value = false;
      getxSnackbar(title: "Error", msg: 'Error submitting shipment: $e');
    }
  }

  Future<void> fetchUserShipments(String userId) async {
    await _shipmentsSubscription?.cancel();
    _shipmentsSubscription = _shipmentRef
        .orderByChild('senderId')
        .equalTo(userId)
        .onValue
        .listen((event) {
      final List<ShipmentModel> userShipments = [];
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          userShipments.add(ShipmentModel.fromFirebase(
              Map<String, dynamic>.from(value as Map)));
        });

        for (var shipment in userShipments) {
          bool hasEnteredPort = shipment.PortEntryTrigger == 1;
          bool isStored = shipment.ContainerStoredTrigger == 1;

          if (hasEnteredPort &&
              !isStored &&
              shipment.shipmentStatus != ShipmentStatus.enteredPort) {
            updateShipmentStatus(
                shipment.shipmentId, ShipmentStatus.enteredPort);
          } else if (hasEnteredPort &&
              isStored &&
              shipment.shipmentStatus != ShipmentStatus.unLoaded) {
            updateShipmentStatus(shipment.shipmentId, ShipmentStatus.unLoaded);
          }
        }

        shipmentsList.value = userShipments;
      } else {
        shipmentsList.clear();
      }
    }, onError: (error) {
      print('Error fetching user shipments: $error');
    });
  }

  Future<void> updateShipmentStatus(
      String shipmentId, ShipmentStatus shipmentStatus) async {
    try {
      await _shipmentRef.child(shipmentId).update({
        'shipmentStatus': shipmentStatus.name,
      });
      print('Shipment $shipmentId status updated to ${shipmentStatus.name}');
    } catch (e) {
      print('Failed to update shipment status for $shipmentId: $e');
    }
  }

  Future<void> updateShipmentOrderId(String shipmentId, String orderId) async {
    try {
      await _shipmentRef
          .child(shipmentId)
          .update({'orderId': orderId.toUpperCase()});
    } catch (e) {
      throw Exception("Failed to update shipment order ID: $e");
    }
  }

  Future<void> updateShipmentPaymentStatus(
      String shipmentId, bool paymentStatus) async {
    try {
      await _shipmentRef.child(shipmentId).update({
        'isPaid': paymentStatus,
        'shipmentStatus': ShipmentStatus.inTransit.name,
      });
    } catch (e) {
      throw Exception("Failed to update shipment payment status: $e");
    }
  }

  Future<void> postContainerId(String containerId) async {
    final url = Uri.parse('${KapiKeys.blockChainUrl}');

    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    final body = jsonEncode({'containerId': containerId});

    isLoading.value = true;
    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Container successfully posted to the blockchain.');
      } else {
        print(
            'Error posting container ID: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception posting container ID: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
