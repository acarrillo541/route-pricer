import 'package:capstone/models/point.dart';

// pull steps param from google directions api
class Steps {
  //list of single points ([turn right on..., go straight for ...])
  final List<Point>? points;

  Steps({this.points});

  factory Steps.fromJson(List json) {
    return Steps(
      points: json.map((e) => Point.fromJson(e)).toList(),
    );
  }
}
