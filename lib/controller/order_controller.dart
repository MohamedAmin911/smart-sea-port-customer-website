// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';

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
  final DatabaseReference _blockChainRef =
      FirebaseDatabase.instance.ref().child('BlockchainTriggers');

  Rx<ShipmentModel?> currentShipment = Rx<ShipmentModel?>(null);
  RxList<ShipmentModel> shipmentsList = <ShipmentModel>[].obs;
  RxMap<String, Map<String, String>> blockChainData =
      <String, Map<String, String>>{}.obs;
  final CustomerController customerController = Get.put(CustomerController());

  @override
  void onInit() async {
    super.onInit();
    await fetchUserShipments(_auth.currentUser!.uid);
  }

  // Add a new shipment with Firebase-generated ID
  Future<void> addShipment(ShipmentModel shipment) async {
    isLoading.value = true;
    try {
      String? shipmentId = _shipmentRef
          .push()
          .key; // Generate a unique shipment ID from Firebase

      if (shipmentId != null && shipmentId.isNotEmpty) {
        // Assign the Firebase-generated ID to the shipment model
        shipment.shipmentId = shipmentId;

        // Save the shipment data to Firebase

        customerController.currentCustomer.value.orders
            .add(shipment.shipmentId);
        await _shipmentRef.child(shipmentId).set(shipment.toJson());
        await customerController.updateCustomerData(
          customerController.currentCustomer.value.uid,
          {'orders': customerController.currentCustomer.value.orders},
          1,
        );
        isLoading.value = false;
        Get.back();
        getxSnackbar(
            title: "Success",
            msg: "Order submitted successfully, please wait for approval.");
      } else {
        isLoading.value = false;
        getxSnackbar(title: "Error", msg: 'Failed to generate shipment ID');
      }
    } catch (e) {
      isLoading.value = false;
      getxSnackbar(title: "Error", msg: 'Error submitting shipment: $e');
    }
  }

  // Fetch a specific shipment
  void fetchShipment(String shipmentId) {
    _shipmentRef.child(shipmentId).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          Map<String, dynamic> shipmentData = Map<String, dynamic>.from(data);
          currentShipment.value = ShipmentModel.fromFirebase(shipmentData);
        } else {
          print('Shipment data is null');
        }
      } else {
        print('Shipment not found in the database.');
      }
    });
  }

  // Fetch all shipments
  Future<void> fetchAllShipments() async {
    _shipmentRef.onValue.listen((event) {
      final List<ShipmentModel> updatedShipments = [];
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          Map<String, dynamic> shipmentData = Map<String, dynamic>.from(value);
          updatedShipments.add(ShipmentModel.fromFirebase(shipmentData));
        });
        shipmentsList.value = updatedShipments;
      }
    });
  }

  // Listen for real-time updates on a shipment
  void listenToShipmentUpdates(String shipmentId) {
    _shipmentRef.child(shipmentId).onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<String, dynamic> shipmentData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        currentShipment.value = ShipmentModel.fromFirebase(shipmentData);
      }
    });
  }

  // Update shipment details
  Future<void> updateShipmentData(
      String shipmentId, Map<String, dynamic> updatedData, int index) async {
    if (shipmentId.isEmpty) {
      print("Error: Invalid shipment ID");
      return;
    }

    // Example: Updating different parts of the shipment based on the index
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

// Fetch shipments for a specific user
  Future<void> fetchUserShipments(String userId) async {
    _shipmentRef
        .orderByChild('senderId')
        .equalTo(userId)
        .onValue
        .listen((event) {
      final List<ShipmentModel> userShipments = [];

      if (event.snapshot.exists && event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          Map<String, dynamic> shipmentData = Map<String, dynamic>.from(value);
          userShipments.add(ShipmentModel.fromFirebase(shipmentData));
        });

        shipmentsList.value =
            userShipments; // Update the observable list with user-specific shipments
      } else {
        shipmentsList.clear(); // Clear the list if no shipments are found
      }
    });
  }

  Future<void> updateShipmentOrderId(String shipmentId, String orderId) async {
    try {
      await _shipmentRef.child(shipmentId).update({'orderId': orderId});
    } catch (e) {
      throw Exception("Failed to update shipment order ID: $e");
    }
  }

  Future<void> updateShipmentPaymentStatus(
      String shipmentId, bool paymentStatus) async {
    try {
      await _shipmentRef.child(shipmentId).update({'isPaid': paymentStatus});
      await _shipmentRef
          .child(shipmentId)
          .update({'shipmentStatus': ShipmentStatus.inTransit.name});
    } catch (e) {
      throw Exception("Failed to update shipment payment status: $e");
    }
  }

  Future<void> updateShipmentSenderLocation(
      String country, String shipmentId) async {
    try {
      await _shipmentRef.child(shipmentId).update({'senderAddress': country});
    } catch (e) {
      throw Exception("Failed to update shipment payment status: $e");
    }
  }

  Future<void> updateShipmentStatus(
      String shipmentId, ShipmentStatus shipmentStatus) async {
    try {
      await _shipmentRef
          .child(shipmentId)
          .update({'shipmentStatus': shipmentStatus.name});
    } catch (e) {
      throw Exception("Failed to update shipment status: $e");
    }
  }

  Future<void> postContainerId(String containerId) async {
    final url = Uri.parse(
        'https://6eea0204e9700433e95130a6d7956795.serveo.net/containers');
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'skip-browser-warning',
    };

    final body = jsonEncode({'containerId': containerId}); // ✅ proper JSON body

    isLoading.value = true;
    // postSuccess.value = false;
    // errorMessage.value = '';

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // postSuccess.value = true;
      } else {
        // errorMessage.value = 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      // errorMessage.value = 'Exception: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPortEntryStatus(String shipmentId) async {
    _blockChainRef.orderByChild('ID').equalTo(shipmentId).onValue.listen(
        (event) {
      final convertedData = <String, Map<String, String>>{};
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final nestedMap = (value as Map<dynamic, dynamic>).map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          );
          convertedData[key.toString()] = nestedMap;
        });
        blockChainData.value = convertedData;

        if (blockChainData.value.containsKey('test456') &&
            blockChainData.value['test456']!['PortEntryTrigger'] == '1') {
          updateShipmentStatus(shipmentId, ShipmentStatus.enteredPort);
        }

        if (blockChainData.value.containsKey('test456') &&
            blockChainData.value['test456']!['ContainerStoredTrigger'] == '1') {
          updateShipmentStatus(shipmentId, ShipmentStatus.unLoaded);
        }
      } else {
        blockChainData.clear();
      }
    }, onError: (error) {
      print('Error fetching port entry status: $error');
      getxSnackbar(
          title: 'Error', msg: 'Failed to fetch port entry status: $error');
    });
  }
}
