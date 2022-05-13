import 'location.dart';

// pulling geometry param from google places api json
class Geometry {
  final Location? loc;

  Geometry({this.loc});

  factory Geometry.fromJson(Map<dynamic, dynamic> json) {
    return Geometry(
      loc: Location.fromJson(json['location']),
    );
  }
}
