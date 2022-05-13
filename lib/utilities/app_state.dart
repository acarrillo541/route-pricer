import 'package:capstone/providers/pin_provider.dart';
import 'package:capstone/models/geometry.dart';
import 'package:capstone/providers/geolocator_provider.dart';
import 'package:capstone/providers/places_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:capstone/models/place_search.dart';
import 'package:capstone/models/place.dart';
import 'package:capstone/models/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:capstone/providers/directions_provider.dart';
import 'package:capstone/models/directions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:capstone/models/leg.dart';

// all the state management goes on here

class AppState with ChangeNotifier {
  //calling different service functions / making api calls
  //used to fill models
  final pinProvider = PinProvider();
  final geolocatorProvider = GeolocatorProvider();
  final placesProvider = PlacesProvider();
  final directionProvider = DirectionsProvider();

  //vars used by plan_trip and nearest_gas
  LocationPermission? permission;
  Position? currentLocation;

  //used by nearest_gas
  List<PlaceSearch>? searchResults;
  List<Place>? stationList;
  Set<Marker>? singleMarkerSet;

  //used by plan_trip
  List<PlaceSearch>? searchResultsOrigin;
  List<PlaceSearch>? searchResultsDest;
  List<Place>? pathPlaceList;
  List<geo.Location>? originLoc;
  List<geo.Location>? destinationLoc;
  Set<Marker>? stationMarkersSet;
  Place? singlePlace;
  Place? originPlace;
  Place? destinationPlace;
  List<geo.Placemark>? startLoc;
  Leg? finalDest;
  Directions? directions;
  Directions? finalPath;

  //car info
  int? startRange;
  int? totalRange;
  int? mpg;

  AppState() {
    setCurrentLocation();
    setStationList();
  }

  //reset list of autosuggestions
  resetList(String type) {
    if (type == "single") {
      searchResults = null;
    } else if (type == "origin") {
      searchResultsOrigin = null;
    } else if (type == "destination") {
      searchResultsDest = null;
    }
    notifyListeners();
  }

  //get the current location and set initial params bases on current location
  setCurrentLocation() async {
    permission = await Geolocator.requestPermission();
    currentLocation = await geolocatorProvider.getCurrentLocation();
    startLoc = await geo.placemarkFromCoordinates(
      currentLocation!.latitude,
      currentLocation!.longitude,
    );
    singlePlace = Place(
      name: startLoc![0].name,
      geometry: Geometry(
        loc: Location(
          lat: currentLocation!.latitude,
          long: currentLocation!.longitude,
        ),
      ),
    );
    await setNearestVars();

    notifyListeners();
  }

  //get markers for nearest station
  //put in a set
  setNearestVars() async {
    stationList = [];
    stationList = await placesProvider.getStations(
      //lat, lng
      singlePlace!.geometry!.loc!.lat!,
      singlePlace!.geometry!.loc!.long!,
    );
    singleMarkerSet = {};
    if (stationList != null && stationList!.isNotEmpty) {
      singleMarkerSet!.add(pinProvider.createPin(singlePlace!, 0));
      for (int i = 0; i < stationList!.length - 1; i++) {
        singleMarkerSet!.add(pinProvider.createPin(stationList![i], i + 1));
      }
    }
    notifyListeners();
  }

  //intial get directions with no way points
  setDirections() async {
    LatLng start = LatLng(
      originPlace!.geometry!.loc!.lat!,
      originPlace!.geometry!.loc!.long!,
    );
    LatLng end = LatLng(
      destinationPlace!.geometry!.loc!.lat!,
      destinationPlace!.geometry!.loc!.long!,
    );
    directions = await directionProvider.getDirections(start, end);
    notifyListeners();
  }

  //yes
  setCarInfo(int estMPG, int start, int total) async {
    startRange = start;
    totalRange = total;
    mpg = estMPG;
    notifyListeners();
  }

  //find path of ideal stations to stop at
  //traverse through intial directions to find where youll run out of gas
  setStationPath() async {
    pathPlaceList = [];
    int lowest = 60 * 1609;
    int most = (totalRange! * 1609.344).toInt();
    int current = (startRange! * 1609.344).toInt();
    int dist = 0;
    int filled = 0;
    double pricePerGallon = 0.0;

    //add origin
    pathPlaceList!.add(originPlace!);

    //add stations
    for (int i = 0; i < directions!.legs![0].steps!.points!.length; i++) {
      dist = directions!.legs![0].steps!.points![i].meters!;
      current = current - dist;

      if (i != directions!.legs![0].steps!.points!.length - 1 &&
          current - directions!.legs![0].steps!.points![i + 1].meters! <= 0) {
        filled = most - current;
        current = most;

        pathPlaceList!.add(await placesProvider.closestStation(
            directions!.legs![0].steps!.points![i].endLocation!.latitude,
            directions!.legs![0].steps!.points![i].endLocation!.longitude));
        pricePerGallon = double.parse(pathPlaceList![pathPlaceList!.length - 1].pricePerGallon!);
        pathPlaceList![pathPlaceList!.length - 1].priceTotal = (pricePerGallon * (filled ~/ 1609) * (1 / mpg!));
      } else if (current < lowest) {
        filled = most - current;
        current = most;
        pathPlaceList!.add(await placesProvider.closestStation(
            directions!.legs![0].steps!.points![i].endLocation!.latitude,
            directions!.legs![0].steps!.points![i].endLocation!.longitude));
        pricePerGallon = double.parse(pathPlaceList![pathPlaceList!.length - 1].pricePerGallon!);
        pathPlaceList![pathPlaceList!.length - 1].priceTotal = (pricePerGallon * (filled ~/ 1609) * (1 / mpg!));
      }
    }

    pathPlaceList!.add(destinationPlace!);

    notifyListeners();
    await setStationMarkers();
  }

  //add markers for ideal stations found in setStationPath
  setStationMarkers() async {
    stationMarkersSet = {};

    if (pathPlaceList != null && pathPlaceList!.isNotEmpty) {
      for (int i = 0; i < pathPlaceList!.length; i++) {
        stationMarkersSet!.add(pinProvider.createPin(pathPlaceList![i], i + 1));
      }
    }
    await setWayPoints();
    notifyListeners();
  }

  //get all the final info in one spot
  // this isnt really a leg but they carry the same info so i used it
  setFinal() async {
    var price = 0.0;
    var length = 0.0;
    var time = 0.0;
    for (int i = 1; i < finalPath!.legs!.length - 1; i++) {
      if (i != finalPath!.legs!.length - 2) {
        price += pathPlaceList![i].priceTotal!;
      }
      length += finalPath!.legs![i].distanceValue!;
      time += finalPath!.legs![i].durationValue!;
    }

    finalDest = Leg(
      price: "$price",
      distanceValue: length,
      durationValue: time,
    );
    notifyListeners();
  }

  //add waypoints to final path and get new Directions / new polylines / new everything
  setWayPoints() async {
    LatLng start = LatLng(
      originPlace!.geometry!.loc!.lat!,
      originPlace!.geometry!.loc!.long!,
    );
    LatLng end = LatLng(
      destinationPlace!.geometry!.loc!.lat!,
      destinationPlace!.geometry!.loc!.long!,
    );
    finalPath = await directionProvider.getFinalPath(start, end, pathPlaceList);
    notifyListeners();
  }

  //setter for single points
  setSinglePoint(String address, String type) async {
    if (type == "origin") {
      originLoc = await geo.locationFromAddress(address);

      originPlace = Place(
        name: address,
        geometry: Geometry(
          loc: Location(
            lat: originLoc![0].latitude,
            long: originLoc![0].longitude,
          ),
        ),
      );
    } else if (type == "destination") {
      destinationLoc = await geo.locationFromAddress(address);

      destinationPlace = Place(
        name: address,
        geometry: Geometry(
          loc: Location(
            lat: destinationLoc![0].latitude,
            long: destinationLoc![0].longitude,
          ),
        ),
      );
    } else if (type == "single") {
      singlePlace = Place(
        name: address,
        geometry: Geometry(
          loc: Location(
            lat: currentLocation!.latitude,
            long: currentLocation!.longitude,
          ),
        ),
      );
    }
    notifyListeners();
  }

  //moving to location from autocomplete list
  setNewLocation(String placeID, String type) async {
    singlePlace = await placesProvider.getPlace(placeID);

    if (type == "single") {
      searchResults = null;
    } else if (type == "origin") {
      searchResultsOrigin = null;
    } else if (type == "destination") {
      searchResultsDest = null;
    }
    setStationList();
    notifyListeners();
  }

  setStationList() async {
    stationList = await placesProvider.getStations(
      singlePlace!.geometry!.loc!.lat!,
      singlePlace!.geometry!.loc!.long!,
    );
    notifyListeners();
  }

  searchPlaces(String search, String type) async {
    if (type == "single") {
      searchResults = await placesProvider.getAutoComplete(
        search,
        currentLocation!.latitude.toString(),
        currentLocation!.longitude.toString(),
      );
    } else if (type == "origin") {
      searchResultsOrigin = await placesProvider.getAutoComplete(
        search,
        currentLocation!.latitude.toString(),
        currentLocation!.longitude.toString(),
      );
    } else if (type == "destination") {
      searchResultsDest = await placesProvider.getAutoComplete(
        search,
        currentLocation!.latitude.toString(),
        currentLocation!.longitude.toString(),
      );
    }

    notifyListeners();
  }

  //throw everything away
  resetAll() {
    pathPlaceList = null;
    stationMarkersSet = null;
    directions = null;
    finalPath = null;
    startRange = null;
    totalRange = null;
    mpg = null;
    finalDest = null;
    startRange = null;
    totalRange = null;
    mpg = null;
  }
}
