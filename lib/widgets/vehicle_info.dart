import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class VehicleInfo extends StatelessWidget {
  const VehicleInfo(
      {required this.name,
      required this.mpg,
      required this.range,
      required this.last,
      required this.buttonAction,
      required this.buttonName,
      Key? key})
      : super(key: key);

  final String name;
  final int mpg;
  final int range;
  final bool last;
  final VoidCallback buttonAction;
  final String buttonName;

  @override
  Widget build(BuildContext context) {
    final item = Row(
      children: <Widget>[
        const SizedBox(
          width: 35,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(CupertinoIcons.car_detailed),
          ),
        ),
        SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0, 5.0, 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "Nickname: $name",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Total Range: $range",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "MPG: $mpg",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: buttonAction,
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
          ),
          child: Text(buttonName),
        ),
      ],
    );
    if (last) {
      return item;
    }
    return Column(
      children: [
        item,
        const SizedBox(height: 15),
        Container(
          height: 2,
          width: 360,
          color: Colors.red,
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
