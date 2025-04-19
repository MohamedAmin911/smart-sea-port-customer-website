class ShipLocationModel {
  ShipLocation? shipLocation;

  ShipLocationModel({this.shipLocation});

  ShipLocationModel.fromJson(Map<String, dynamic> json) {
    shipLocation = json['ship_location'] != null
        ? new ShipLocation.fromJson(json['ship_location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.shipLocation != null) {
      data['ship_location'] = this.shipLocation!.toJson();
    }
    return data;
  }
}

class ShipLocation {
  double? latitude;
  double? longitude;
  String? timestamp;

  ShipLocation({this.latitude, this.longitude, this.timestamp});

  ShipLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['timestamp'] = this.timestamp;
    return data;
  }
}
