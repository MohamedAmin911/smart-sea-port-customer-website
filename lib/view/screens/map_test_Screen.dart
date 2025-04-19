import 'package:final_project_customer_website/controller/ship_tracking_controller.dart';
import 'package:final_project_customer_website/view/widgets/tracking_screen_widgets/google_maps_widget.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:get/get.dart';

class ShipMapCombinedScreen extends StatelessWidget {
  final ShipController controller = Get.put(ShipController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ship Route to Egypt'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  onSelect: (Country country) async {
                    await controller.initializePositions(country.name);
                  },
                );
              },
              child: Text('Select Source Country'),
            ),
          ),
          Expanded(
            child: ShipMapWidget(),
          ),
        ],
      ),
    );
  }
}
