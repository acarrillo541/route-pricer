import 'package:flutter/material.dart';
import 'package:capstone/models/leg.dart';
import 'package:capstone/models/place.dart';

// ignore: must_be_immutable
class StopInfo extends StatelessWidget {
  StopInfo({this.leg, required this.last, required this.placeInfo, required this.pos, Key? key}) : super(key: key);

  Leg? leg;
  final Place placeInfo;
  final bool last;
  final int pos;

  @override
  Widget build(BuildContext context) {
    var distance = ((leg == null) ? '' : leg!.distance);
    var time = ((leg == null) ? '' : leg!.duration);
    var name = placeInfo.name;
    var address = placeInfo.address;

    final item = SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            //height: 50.0,
            width: 35,
            child: (last == true || pos == 0)
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5.0, 5.0),
                    child: Icon(
                      (leg == null) ? Icons.local_gas_station : Icons.location_pin,
                      color: (leg == null) ? Colors.black : Colors.red,
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 5.0, 5.0),
                    child: Icon(Icons.local_gas_station),
                  ),
          ),
          SizedBox(
            width: 250,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 5.0, 5.0),
              child: Column(
                children: <Widget>[
                  if (pos == 0 && leg != null)
                    const Text(
                      "Starting Point",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (last && leg != null)
                    const Text(
                      "Destination Point",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (name != null)
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (address != null)
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (time != null && pos != 0 && leg != null)
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "Leg Time: $time",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: (pos == 0)
                ? null
                : Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5.0, 5.0),
                    child: Column(
                      children: <Widget>[
                        if (!last)
                          Text(
                            (leg == null)
                                ? "\$x.xx"
                                : "\$${double.parse("${placeInfo.priceTotal!}").toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (distance != null)
                          Text(
                            distance,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
          )
        ],
      ),
    );

    if (last) {
      return item;
    }

    return Column(
      children: [
        item,
        Container(
          height: 2,
          width: 360,
          color: Colors.red,
        )
      ],
    );
  }
}
