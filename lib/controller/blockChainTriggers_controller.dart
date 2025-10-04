import 'dart:async';
import 'package:final_project_customer_website/controller/customer_controller.dart';
import 'package:final_project_customer_website/controller/order_controller.dart';
import 'package:final_project_customer_website/model/shipment_model.dart';
import 'package:final_project_customer_website/view/widgets/common_widgets/getx_snackbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class BlockchaintriggersController extends GetxController {
  final OrderController orderController = Get.put(OrderController());
  final CustomerController customerController = Get.put(CustomerController());
  final DatabaseReference _blockChainRef =
      FirebaseDatabase.instance.ref().child('BlockchainTriggers');

  RxMap<String, Map<String, String>> blockChainData =
      <String, Map<String, String>>{}.obs;
  Timer? _blockChainTimer;

  @override
  void onInit() async {
    super.onInit();
    await fetchPortEntryStatus();
  }

  @override
  void onClose() {
    _blockChainTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchPortEntryStatus() async {
    final orderId = customerController.currentCustomer.value.currentOrderId;
    print('Starting blockchain triggers polling for orderId: $orderId');
    _blockChainTimer?.cancel();
    _blockChainTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      try {
        // Convert orderId to uppercase for case-insensitive comparison
        final normalizedOrderId = orderId;
        if (normalizedOrderId == null || normalizedOrderId.isEmpty) {
          print('No valid orderId provided, skipping fetchPortEntryStatus');
          return;
        }
        final snapshot = await _blockChainRef
            .orderByChild('ID')
            .equalTo(normalizedOrderId)
            .get();
        final convertedData = <String, Map<String, String>>{};
        print("--------------------------------------------------------");
        if (snapshot.exists && snapshot.value != null) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          print('BlockchainTriggers data: $data');
          data.forEach((key, value) {
            final nestedMap = (value as Map<dynamic, dynamic>).map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            );
            convertedData[key.toString()] = nestedMap;
          });
          blockChainData.value = convertedData;

          print('blockChainData: ${blockChainData.value}');
          for (var entry in blockChainData.value.entries) {
            if (entry.value['ID']?.toUpperCase() == normalizedOrderId) {
              if (entry.value['PortEntryTrigger'] == '1') {
                await orderController.updateShipmentStatus(
                  orderId,
                  ShipmentStatus.enteredPort,
                );
              }
              if (entry.value['ContainerStoredTrigger'] == '1') {
                await orderController.updateShipmentStatus(
                  orderId,
                  ShipmentStatus.unLoaded,
                );
                _blockChainTimer?.cancel();
                print('Terminal status reached, stopped blockchain polling');
                break;
              }
            }
          }
        } else {
          print(
              "No BlockchainTriggers data found for normalized orderId: $normalizedOrderId");
          blockChainData.clear();
        }
      } catch (e) {
        print('Error fetching port entry status: $e');
        getxSnackbar(
            title: 'Error', msg: 'Failed to fetch port entry status: $e');
      }
    });
  }
}
