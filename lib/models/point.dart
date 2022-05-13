import 'package:google_maps_flutter/google_maps_flutter.dart';

// pull point param from google directions api json
// this is a specific point within a leg of the trip (ex. turn right on ...)
class Point {
  final int? meters; // distance from prev point
  //final String? endAddress;
  final LatLng? endLocation; // location of this point

  Point({
    this.meters,
    this.endLocation,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
        meters: json['distance']['value'],
        //endAddress: json['end_address']['value'],
        endLocation: LatLng(
          json['end_location']['lat'],
          json['end_location']['lng'],
        ));
  }
}
