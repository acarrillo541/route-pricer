import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:capstone/models/leg.dart';

// used for calls to google directions api
class Directions {
  final LatLngBounds? llbounds; //used for map bounds
  final List<PointLatLng>? polyPoints; //lines between points
  final List<Leg>? legs; //each leg of the trip (waypoints)

  Directions({this.llbounds, this.polyPoints, this.legs});

  factory Directions.fromJson(List json) {
    final map = Map<String, dynamic>.from(json[0]);

    var bounds = LatLngBounds(
      southwest: LatLng(
        map['bounds']['southwest']['lat'],
        map['bounds']['southwest']['lng'],
      ),
      northeast: LatLng(
        map['bounds']['northeast']['lat'],
        map['bounds']['northeast']['lng'],
      ),
    );

    var points = PolylinePoints().decodePolyline(
      map['overview_polyline']['points'],
    );

    return Directions(
      llbounds: bounds,
      polyPoints: points,
      legs: map['legs'].map<Leg>((e) => Leg.fromJson(e)).toList(),
    );
  }
}
