import 'geometry.dart';

// pull place param from google places api
class Place {
  final String? name; // ex. gas station name
  final Geometry? geometry; // location info
  final String? address;
  final String? pricePerGallon;
  double? priceTotal; // total price for fill up at this location

  Place({
    this.name,
    this.geometry,
    this.address,
    this.pricePerGallon,
    this.priceTotal,
  });

  //used for finding regular location (ex. start and destination) that dont need gas price
  factory Place.fromJson(Map<dynamic, dynamic> json) {
    return Place(
      name: json['name'],
      geometry: Geometry.fromJson(json['geometry']),
      address: json['formatted_address'],
    );
  }

  //used for finding gas stations
  factory Place.fromJsonWithPrice(Map<dynamic, dynamic> json, String price) {
    return Place(
        name: json['name'],
        geometry: Geometry.fromJson(json['geometry']),
        address: json['formatted_address'],
        pricePerGallon: price);
  }
}
