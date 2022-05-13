import 'package:capstone/models/place.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:io';
import 'package:capstone/models/place_search.dart';

class PlacesProvider {
  final apiKey = '';
  final gasKey = '';

  // api call for getting autocomplete data based on search string
  // expensive call because every keystroke makes a new call
  Future<List<PlaceSearch>> getAutoComplete(String search, String lat, String long) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&location=$lat,$long&types=geocode&key=$apiKey';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var listResults = json['predictions'] as List;
    return listResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  //get list of stations from lat long
  Future<List<Place>> getStations(double lat, double long) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?type=gas_station&location=$lat,$long&rank_by=distance&key=$apiKey';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var stationResults = json['results'] as List;
    return stationResults.map((place) => Place.fromJson(place)).toList();
  }

  //add price in Place shit make api call
  //get the closest station, idealy this would be cheapest, but dont have sufficient api from gas price
  Future<Place> closestStation(double lat, double long) async {
    //closest station
    var url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?type=gas_station&location=$lat,$long&rank_by=distance&key=$apiKey';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var stationResults = json['results'] as List;

    //wasted api call because this is the only way I could get state of lat,lng
    var id = stationResults[0]['place_id'];
    var wastelol = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$id&key=$apiKey';
    var wasteResponse = await http.get(Uri.parse(wastelol));
    var wasteJson = convert.jsonDecode(wasteResponse.body);
    var addrList = wasteJson['result']['address_components'] as List;
    var state = '';
    for (int i = 0; i < addrList.length; i++) {
      state = addrList[i]['short_name'];
      if (state.length == 2) break;
    }

    //get gas price (not a very good api / would switch to crowd source approach like gas buddy)
    var gasByState = 'https://api.collectapi.com/gasPrice/stateUsaPrice?state=$state';

    var gasResponse = await http.get(
      Uri.parse(gasByState),
      headers: {
        HttpHeaders.authorizationHeader: 'apiKey $gasKey',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    var gasJson = convert.jsonDecode(gasResponse.body);
    var price = gasJson['result']['state']['gasoline'];

    return Place.fromJsonWithPrice(stationResults[0], price);
  }

  //get location data from placeID given by place_search call
  Future<Place> getPlace(String placeID) async {
    var url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$apiKey';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;
    return Place.fromJson(results);
  }
}
