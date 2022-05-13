import 'package:capstone/widgets/vehicle_list.dart';
import 'package:capstone/providers/firebase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class VehicleTab extends StatefulWidget {
  const VehicleTab({Key? key}) : super(key: key);

  @override
  _VehicleTabState createState() {
    return _VehicleTabState();
  }
}

class _VehicleTabState extends State<VehicleTab> {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        scaffoldBackgroundColor: Colors.blue[400],
      ),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          border: Border.all(color: Colors.red),
          middle: const Text(
            "My Vehicles",
            style: TextStyle(fontSize: 25),
          ),
        ),
        child: SizedBox(
          height: 766.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              VehicleList(listAction: "delete"),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
                child: ElevatedButton(
                  onPressed: () {
                    addVehicleForm(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Add Vehicle"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  addVehicleForm(BuildContext context) {
    var nameContrl = TextEditingController();
    var mpgContrl = TextEditingController();
    var rangeContrl = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text("Add Vehicle"),
            content: Column(
              children: [
                const SizedBox(height: 10),
                CupertinoTextField(
                  placeholder: "Nickname",
                  controller: nameContrl,
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  keyboardType: TextInputType.number,
                  placeholder: "Total Range",
                  controller: rangeContrl,
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  keyboardType: TextInputType.number,
                  placeholder: "MPG",
                  controller: mpgContrl,
                )
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text("Return"),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  if (nameContrl.text.isNotEmpty && mpgContrl.text.isNotEmpty && rangeContrl.text.isNotEmpty) {
                    addVehicle(
                      int.parse(rangeContrl.text),
                      int.parse(mpgContrl.text),
                      nameContrl.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              )
            ],
          );
        });
  }
}
