import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/getx_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final _auth = FirebaseAuth.instance;
  var isLoading = false.obs;
  final DatabaseReference _shipmentRef =
      FirebaseDatabase.instance.ref().child('shipments');

  Rx<ShipmentModel?> currentShipment = Rx<ShipmentModel?>(null);
  RxList<ShipmentModel> shipmentsList = <ShipmentModel>[].obs;
  final CustomerController customerController = Get.put(CustomerController());

  @override
  void onInit() async {
    super.onInit();
    fetchUserShipments(_auth.currentUser!.uid);
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
        getxSnackbar(title: "Success", msg: "Order submitted successfully");
      } else {
        isLoading.value = false;
        getxSnackbar(title: "Error", msg: 'Failed to generate shipment ID');
      }
    } catch (e) {
      isLoading.value = false;
      getxSnackbar(title: "Error", msg: 'Error adding shipment: $e');
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
        print('No shipments found for this user.');
        shipmentsList.clear(); // Clear the list if no shipments are found
      }
    });
  }
}
