import 'package:geolocator/geolocator.dart';

class GeolocatorProvider {
  //return postion of current location from geolocator
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
