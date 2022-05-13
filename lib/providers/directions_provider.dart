import 'package:capstone/models/directions.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert' as convert;

class DirectionsProvider {
  final apiKey = "";
  // get directions data from origin to dest (simple, no waypoints)
  Future<Directions> getDirections(LatLng origin, LatLng dest) async {
    double startLat = origin.latitude;
    double startLong = origin.longitude;
    double endLat = dest.latitude;
    double endLong = dest.longitude;
    var url =
        "https://maps.googleapis.com/maps/api/directions/json?destination=$endLat,$endLong&origin=$startLat,$startLong&key=$apiKey";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['routes'] as List;
    return Directions.fromJson(results);
  }

  //get directions from origin to dest w/ list of gas stations to stop at (w/waypoints)
  Future<Directions> getFinalPath(LatLng origin, LatLng dest, List? stations) async {
    double startLat = origin.latitude;
    double startLong = origin.longitude;
    double endLat = dest.latitude;
    double endLong = dest.longitude;

    //make list of waypoints into a single string for url
    String? waypoints;
    if (stations != null && stations.isNotEmpty) {
      waypoints = '';
      for (int i = 0; i < stations.length; i++) {
        String lat = stations[i].geometry!.loc!.lat!.toString();
        String long = stations[i].geometry!.loc!.long!.toString();
        waypoints = waypoints! + "$lat,$long|";
      }
    }

    var url =
        "https://maps.googleapis.com/maps/api/directions/json?destination=$endLat,$endLong&origin=$startLat,$startLong&waypoints=$waypoints&key=$apiKey";
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['routes'] as List;
    return Directions.fromJson(results);
  }
}
