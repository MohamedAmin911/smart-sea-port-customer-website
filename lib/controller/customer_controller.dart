import 'package:final_project_customer_website/model/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CustomerController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('customers');
  var CustomersList = <CustomerModel>[].obs;
  Rx<CustomerModel> currentCustomer = CustomerModel(
    uid: '',
    companyName: '',
    companyAddress: '',
    isBlocked: '',
    companyEmail: '',
    companyPhoneNumber: '',
    companyCity: '',
    companyRegistrationNumber: '',
    companyImportLicenseNumber: '',
  ).obs;
  final DatabaseReference customerRef =
      FirebaseDatabase.instance.ref('customers');
  @override
  void onInit() async {
    super.onInit();
    fetchAllCustomers();
    _auth.currentUser != null
        ? fetchCurrentCustomer(_auth.currentUser!.uid)
        : null;
  }

//add user

  Future<void> addCustomer(CustomerModel customer) async {
    await _databaseReference
        .child(_auth.currentUser!.uid)
        .set(customer.toJson());
  }

  // Method to fetch a specific user's data
  void fetchCurrentCustomer(String customerId) {
    customerRef.child(customerId).onValue.listen((event) {
      if (event.snapshot.exists) {
        // Ensure the snapshot contains valid data
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          // Cast the data to Map<String, dynamic> safely
          Map<String, dynamic> customerData = Map<String, dynamic>.from(data);
          // print(userData);
          currentCustomer.value = CustomerModel.fromFirebase(customerData);
        } else {
          print('User data is null');
        }
      } else {
        print('User not found in the database.');
      }
    });
  }

// Fetch all drivers from the database
  Future<void> fetchAllCustomers() async {
    customerRef.onValue.listen((event) {
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

        CustomersList.value = updatedUsers; // Update the observable list
      }
    });
  }
}
