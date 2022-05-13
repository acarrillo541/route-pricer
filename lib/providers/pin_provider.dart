import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:capstone/models/place.dart';

//used to create pins for station list
class PinProvider {
  Marker createPin(Place place, int id) {
    var pinID = place.name;
    return Marker(
        draggable: false,
        markerId: MarkerId(pinID!),
        position: LatLng(
          place.geometry!.loc!.lat!,
          place.geometry!.loc!.long!,
        ),
        infoWindow: InfoWindow(
          title: place.name,
        ));
  }
}
