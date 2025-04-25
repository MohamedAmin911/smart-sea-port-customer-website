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
  RxMap<String, Map<String, String>> blockChainData =
      <String, Map<String, String>>{}.obs;
  final CustomerController customerController = Get.put(CustomerController());
  Timer? _portEntryTimer;
  Timer? _shipmentMonitorTimer;

  @override
  void onInit() async {
    super.onInit();
    if (_auth.currentUser != null) {
      await fetchUserShipments(_auth.currentUser!.uid);
      String? shipmentId =
          customerController.currentCustomer.value.currentOrderId;
      await listenToPortEntryTrigger(shipmentId);
    }
  }

  @override
  void onClose() {
    _portEntryTimer?.cancel();
    _shipmentMonitorTimer?.cancel();
    super.onClose();
  }

  Future<void> addShipment(ShipmentModel shipment) async {
    isLoading.value = true;
    try {
      String? shipmentId = _shipmentRef.push().key;
      if (shipmentId != null && shipmentId.isNotEmpty) {
        shipment.shipmentId = shipmentId.toUpperCase();
        customerController.currentCustomer.value.orders
            .add(shipment.shipmentId);
        await _shipmentRef.child(shipment.shipmentId).set(shipment.toJson());
        await customerController.updateCustomerData(
          customerController.currentCustomer.value.uid,
          {
            'orders': customerController.currentCustomer.value.orders,
            'currentOrderId': shipment.shipmentId,
          },
          1,
        );
        shipmentsList.add(shipment);
        isLoading.value = false;
        Get.back();
        getxSnackbar(
          title: "Success",
          msg: "Order submitted successfully, please wait for approval.",
        );
      } else {
        isLoading.value = false;
        getxSnackbar(title: "Error", msg: 'Failed to generate shipment ID');
      }
    } catch (e) {
      isLoading.value = false;
      getxSnackbar(title: "Error", msg: 'Error submitting shipment: $e');
    }
  }

  void fetchShipment(String shipmentId) {
    _shipmentRef.child(shipmentId).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          currentShipment.value =
              ShipmentModel.fromFirebase(Map<String, dynamic>.from(data));
        } else {
          print('Shipment data is null');
        }
      } else {
        print('Shipment not found in the database.');
      }
    }, onError: (error) {
      print('Error fetching shipment: $error');
    });
  }

  Future<void> fetchAllShipments() async {
    _shipmentRef.onValue.listen((event) {
      final List<ShipmentModel> updatedShipments = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          updatedShipments.add(
              ShipmentModel.fromFirebase(Map<String, dynamic>.from(value)));
        });
        shipmentsList.value = updatedShipments;
      }
    }, onError: (error) {
      print('Error fetching all shipments: $error');
    });
  }

  void listenToShipmentUpdates(String shipmentId) {
    _shipmentRef.child(shipmentId).onValue.listen((event) {
      if (event.snapshot.exists) {
        currentShipment.value = ShipmentModel.fromFirebase(
          Map<String, dynamic>.from(event.snapshot.value as Map),
        );
      }
    }, onError: (error) {
      print('Error listening to shipment updates: $error');
    });
  }

  Future<void> updateShipmentData(
      String shipmentId, Map<String, dynamic> updatedData, int index) async {
    if (shipmentId.isEmpty) {
      print("Error: Invalid shipment ID");
      return;
    }
    switch (index) {
      case 1:
        print("Updating shipment status...");
        break;
      case 2:
        print("Updating delivery details...");
        break;
      case 3:
        print("Updating payment details...");
        break;
      default:
        break;
    }
    try {
      await _shipmentRef.child(shipmentId).update(updatedData);
      print("Shipment updated successfully!");
    } catch (e) {
      print("Failed to update shipment: $e");
    }
  }

  Future<void> fetchUserShipments(String userId) async {
    _shipmentRef.orderByChild('senderId').equalTo(userId).onValue.listen(
        (event) {
      final List<ShipmentModel> userShipments = [];
      if (event.snapshot.exists && event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          userShipments.add(
              ShipmentModel.fromFirebase(Map<String, dynamic>.from(value)));
        });
        shipmentsList.value = userShipments;

        if (shipmentsList.value
                    .firstWhere((e) =>
                        e.shipmentId ==
                        customerController.currentCustomer.value.currentOrderId)
                    .portEntryTrigger ==
                "1" &&
            shipmentsList.value
                    .firstWhere((e) =>
                        e.shipmentId ==
                        customerController.currentCustomer.value.currentOrderId)
                    .containerStoredTrigger !=
                "1") {
          updateShipmentStatus(
              customerController.currentCustomer.value.currentOrderId,
              ShipmentStatus.enteredPort);
        } else if (shipmentsList.value
                    .firstWhere((e) =>
                        e.shipmentId ==
                        customerController.currentCustomer.value.currentOrderId)
                    .portEntryTrigger ==
                "1" &&
            shipmentsList.value
                    .firstWhere((e) =>
                        e.shipmentId ==
                        customerController.currentCustomer.value.currentOrderId)
                    .containerStoredTrigger ==
                "1") {
          updateShipmentStatus(
              customerController.currentCustomer.value.currentOrderId,
              ShipmentStatus.unLoaded);
        }
        print(
            'Updated shipmentsList: ${shipmentsList.map((s) => s.shipmentId).toList()}');
      } else {
        shipmentsList.clear();
        print('No shipments found for userId: $userId');
      }
    }, onError: (error) {
      print('Error fetching user shipments: $error');
      getxSnackbar(
          title: 'Error', msg: 'Failed to fetch user shipments: $error');
    });
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

  Future<void> updateShipmentSenderLocation(
      String country, String shipmentId) async {
    try {
      await _shipmentRef.child(shipmentId).update({'senderAddress': country});
    } catch (e) {
      throw Exception("Failed to update shipment sender location: $e");
    }
  }

  Future<void> updateShipmentStatus(
      String shipmentId, ShipmentStatus shipmentStatus) async {
    try {
      final snapshot =
          await _shipmentRef.child(shipmentId).child('shipmentStatus').get();
      if (snapshot.exists && snapshot.value == shipmentStatus.name) {
        print(
            'Shipment $shipmentId already has status ${shipmentStatus.name}, skipping update');
        return;
      }
      await _shipmentRef.child(shipmentId).update({
        'shipmentStatus': shipmentStatus.name,
        'enteredPort':
            shipmentStatus == ShipmentStatus.enteredPort ? 'enteredPort' : '',
      });
      print('Shipment $shipmentId updated to status ${shipmentStatus.name}');
      if (shipmentStatus == ShipmentStatus.unLoaded) {
        _portEntryTimer?.cancel();
        _shipmentMonitorTimer?.cancel();
        print('Terminal status reached for $shipmentId, stopped polling');
      }
    } catch (e) {
      print('Failed to update shipment status for $shipmentId: $e');
      throw Exception("Failed to update shipment status: $e");
    }
  }

  Future<void> postContainerId(String containerId) async {
    final url = Uri.parse(KapiKeys.blockChainUrl);
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'skip-browser-warning',
    };
    final body = jsonEncode({'containerId': containerId});

    isLoading.value = true;
    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
            'Error posting container ID: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception posting container ID: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> listenToPortEntryTrigger(String? shipmentId) async {
    if (shipmentId == null || shipmentId.trim().isEmpty) {
      print("Invalid shipmentId passed to listener.");
      return;
    }

    _shipmentRef.child(shipmentId).onValue.listen((event) async {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);

        if (data['PortEntryTrigger'] == 1 &&
            data['shipmentStatus'] != 'enteredPort') {
          await _shipmentRef.child(shipmentId).update({
            'shipmentStatus': 'enteredPort',
            'enteredPort': 'enteredPort',
          }).then((_) {
            print('Shipment $shipmentId updated to enteredPort.');
          }).catchError((error) {
            print('Failed to update shipment: $error');
          });
        }
      }
    });
  }
}
