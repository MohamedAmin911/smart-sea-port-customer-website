import 'package:final_project_customer_website/model/customer_model.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/getx_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CustomerController extends GetxController {
  final DatabaseReference customerssRef =
      FirebaseDatabase.instance.ref("customers");
  var isEditing1 = false.obs;
  var isLoading1 = false.obs;

  var isEditing2 = false.obs;
  var isLoading2 = false.obs;

  var isEditing3 = false.obs;
  var isLoading3 = false.obs;

  var isEditing4 = false.obs;
  var isLoading4 = false.obs;

  var isEditing5 = false.obs;
  var isLoading5 = false.obs;

  var isEditing6 = false.obs;
  var isLoading6 = false.obs;

  var isEditing7 = false.obs;
  var isLoading7 = false.obs;

  final _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('customers');
  var customersList = <CustomerModel>[].obs;
  Rx<CustomerModel> currentCustomer = CustomerModel(
    uid: '',
    companyName: '',
    companyAddress: '',
    companyEmail: '',
    companyPhoneNumber: '',
    companyCity: '',
    companyRegistrationNumber: '',
    companyImportLicenseNumber: '',
  ).obs;

  @override
  void onInit() async {
    super.onInit();
    // fetchAllCustomers();

    // Wait for auth to initialize and check if user exists
    await Future.delayed(
        const Duration(seconds: 0)); // Give time for auth to initialize
    if (_auth.currentUser != null) {
      fetchCurrentCustomer(_auth.currentUser!.uid);
    } else {
      print('No authenticated user found');
    }
  }
//add user

  Future<void> addCustomer(CustomerModel customer) async {
    await _databaseReference
        .child(_auth.currentUser!.uid)
        .set(customer.toJson());
  }

  // Method to fetch a specific user's data
  void fetchCurrentCustomer(String customerId) {
    if (customerId.isEmpty) {
      print('Invalid customer ID');
      return;
    }

    _databaseReference.child(customerId).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value;
        if (data != null) {
          try {
            Map<String, dynamic> customerData =
                Map<String, dynamic>.from(data as Map);
            currentCustomer.value = CustomerModel.fromFirebase(customerData);
          } catch (e) {
            print('Error parsing customer data: $e');
          }
        } else {
          print('User data is null');
        }
      } else {
        print('User not found in the database - creating new record');
        // Consider creating a new customer record here if appropriate
      }
    }, onError: (error) {
      print('Error fetching customer: $error');
    });
  }

// Fetch all drivers from the database
  Future<void> fetchAllCustomers() async {
    _databaseReference.onValue.listen((event) {
      final List<CustomerModel> updatedUsers = [];

      // Cast the data properly to avoid type errors
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          Map<String, dynamic> userData =
              Map<String, dynamic>.from(value); // Cast each value
          updatedUsers.add(CustomerModel.fromFirebase(userData));
        });

        customersList.value = updatedUsers; // Update the observable list
      }
    });
  }

// Listen for real-time updates
  void listenToCustomerData(String customerId) {
    _databaseReference.child(customerId).onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> customerData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        currentCustomer.value = CustomerModel.fromFirebase(customerData);
      }
    });
  }

  // Update driver data
  Future<void> updateCustomerData(
      String customerId, Map<String, dynamic> updatedData, int index) async {
    if (customerId.isEmpty) {
      getxSnackbar(title: "Error", msg: "Invalid customer ID");

      return;
    }

    switch (index) {
      case 1:
        isEditing1.value = false;
        isLoading1.value = true;
        break;
      case 2:
        isEditing2.value = false;
        isLoading2.value = true;
        break;
      case 3:
        isEditing3.value = false;
        isLoading3.value = true;
        break;
      case 4:
        isEditing4.value = false;
        isLoading4.value = true;
        break;
      case 5:
        isEditing5.value = false;
        isLoading5.value = true;
        break;
      case 6:
        isEditing6.value = false;
        isLoading6.value = true;
        break;
      case 7:
        isEditing7.value = false;
        isLoading7.value = true;
        break;
      default:
        break;
    }
    try {
      await _databaseReference.child(customerId).update(updatedData);
    } catch (e) {
      getxSnackbar(title: "Error", msg: "Failed to update profile: $e");
    } finally {
      switch (index) {
        case 1:
          isLoading1.value = false;
          break;
        case 2:
          isLoading2.value = false;
          break;
        case 3:
          isLoading3.value = false;
          break;
        case 4:
          isLoading4.value = false;
          break;
        case 5:
          isLoading5.value = false;
          break;
        case 6:
          isLoading6.value = false;
          break;
        case 7:
          isLoading7.value = false;
          break;
        default:
          break;
      }
    }
  }

  Future<void> addCurrentOrderIdToCustomer(String orderId) async {
    try {
      await customerssRef
          .child(currentCustomer.value.uid)
          .update({'currentOrderId': orderId});
    } catch (e) {
      rethrow;
    }
  }
}
