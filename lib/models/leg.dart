import 'package:capstone/models/steps.dart';

// pulling leg param from google directions api json
class Leg {
  final Steps? steps; //turn by turn steps
  final String? distance; // total leg distance (string)
  final String? duration; // total leg duration (string)
  final double? durationValue;
  final double? distanceValue;
  final String? price; // gas cost of leg

  Leg({
    this.steps,
    this.distance,
    this.duration,
    this.price,
    this.durationValue,
    this.distanceValue,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    var stepss = Steps.fromJson(json['steps']);

    return Leg(
        steps: stepss,
        distance: json['distance']['text'],
        distanceValue: json['distance']['value'].toDouble(),
        duration: json['duration']['text'],
        durationValue: json['duration']['value'].toDouble());
  }
}
