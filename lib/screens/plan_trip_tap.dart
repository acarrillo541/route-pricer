import 'package:capstone/utilities/app_state.dart';
import 'package:capstone/widgets/vehicle_list.dart';
import 'package:flutter/material.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:provider/provider.dart';
import 'package:capstone/models/place.dart';
import '../widgets/stop_info.dart';

class PlanTripTab extends StatefulWidget {
  const PlanTripTab({Key? key}) : super(key: key);

  @override
  _PlanTripTabState createState() {
    return _PlanTripTabState();
  }
}

class _PlanTripTabState extends State<PlanTripTab> {
  @override
  void initState() {
    super.initState();
  }

  late GoogleMapController mapController;
  //marker vars
  Marker? originMarker;
  Marker? destinationMarker;
  Set<Marker> allMarkers = {};
  LatLng? ne;
  LatLng? sw;

  //first page info
  String? origin;
  final originContrl = TextEditingController();
  String? destination;
  final destContrl = TextEditingController();

  bool showCarList = false;

  //car page info
  int step = 0;
  int? totalRange;
  int? startRange;
  int? estMPG;
  final mpgContrl = TextEditingController();
  final currentRangeContrl = TextEditingController();
  final totalRangeContrl = TextEditingController();

  //polylines set ?
  bool linesSet = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    originContrl.dispose();
    destContrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      home: Scaffold(
        body: (appState.currentLocation == null)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SizedBox(
                height: 766.0,
                child: Column(
                  children: [
                    Flexible(
                      child: Stack(
                        children: <Widget>[
                          GoogleMap(
                            onMapCreated: _onMapCreated,
                            myLocationEnabled: true,
                            markers: Set<Marker>.of(allMarkers),
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                appState.currentLocation!.latitude,
                                appState.currentLocation!.longitude,
                              ),
                              zoom: 15.0,
                            ),
                            polylines: {
                              if (appState.finalPath != null)
                                Polyline(
                                  polylineId: const PolylineId("some value"),
                                  width: 4,
                                  points: appState.finalPath!.polyPoints!
                                      .map(
                                        (e) => LatLng(e.latitude, e.longitude),
                                      )
                                      .toList(),
                                  color: Colors.blue,
                                ),
                            },
                          ),

                          if (step <= 1)
                            SafeArea(
                              child: (Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: 250,
                                  width: 400,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400]!.withOpacity(0.8),
                                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            "Find Trip Cost",
                                            style: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: TextField(
                                          controller: originContrl,
                                          onChanged: (value) {
                                            appState.searchPlaces(value, "origin");
                                          },
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: "Enter Start Position",
                                            suffixIcon: IconButton(
                                                icon: const Icon(Icons.my_location),
                                                onPressed: () {
                                                  origin = appState.startLoc![0].name! +
                                                      ", " +
                                                      appState.startLoc![0].locality! +
                                                      ", " +
                                                      appState.startLoc![0].administrativeArea! +
                                                      ", USA";
                                                  //appState.startLoc![0].country!;
                                                  originContrl.text = origin!;
                                                  appState.resetList("origin");
                                                }),
                                            enabledBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(width: 2, color: Colors.black),
                                            ),
                                            focusedBorder: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                              borderSide: BorderSide(width: 5, color: Colors.black),
                                            ),
                                            labelText: "Start",
                                            labelStyle: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              height: 1.8,
                                            ),
                                            contentPadding: const EdgeInsets.all(20.0),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: TextField(
                                            controller: destContrl,
                                            onChanged: (value) => appState.searchPlaces(value, "destination"),
                                            decoration: const InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: "Enter End Address",
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                    borderSide: BorderSide(width: 2, color: Colors.black)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                    borderSide: BorderSide(width: 5, color: Colors.black)),
                                                labelText: "Destination",
                                                labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    //fontWeight: FontWeight.bold,
                                                    fontSize: 20.0,
                                                    height: 1.8),
                                                contentPadding: EdgeInsets.all(20.0)),
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            step = 1;
                                            setState(() {});
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.red,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text("Next Step"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ),

                          //black box for search
                          if ((appState.searchResultsOrigin != null && appState.searchResultsOrigin!.isNotEmpty) ||
                              (appState.searchResultsDest != null && appState.searchResultsDest!.isNotEmpty))
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 225, 0, 0),
                              child: SizedBox(
                                height: 300.0,
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(.8),
                                    //backgroundBlendMode: BlendMode.darken
                                  ),
                                ),
                              ),
                            ),
                          //get auto complete suggestions for origin
                          if (appState.searchResultsOrigin != null &&
                              appState.searchResultsOrigin!.isNotEmpty &&
                              step == 0)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 175, 0, 0),
                              child: SizedBox(
                                height: 350.0,
                                child: ListView.builder(
                                  itemCount: appState.searchResultsOrigin!.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        appState.searchResultsOrigin![index].address!,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        appState.setNewLocation(
                                            appState.searchResultsOrigin![index].placeId!, "origin");
                                        origin = appState.searchResultsOrigin![index].address!;
                                        //print(origin);
                                        originContrl.text = origin!;
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),

                          //get auto complete suggestions for destination
                          if (appState.searchResultsDest != null && appState.searchResultsDest!.isNotEmpty && step == 0)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 175, 0, 0),
                              child: SizedBox(
                                height: 350.0,
                                child: ListView.builder(
                                  itemCount: appState.searchResultsDest!.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        appState.searchResultsDest![index].address!,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        appState.setNewLocation(
                                            appState.searchResultsDest![index].placeId!, "destination");
                                        destination = appState.searchResultsDest![index].address!;
                                        //print(destination);
                                        destContrl.text = destination!;
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),

                          //enter vehicle data
                          if (step == 1)
                            SafeArea(
                              child: (Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: 325,
                                  width: 400,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[400]!,
                                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            "Enter Vehicle Info",
                                            style: TextStyle(
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: TextField(
                                          controller: currentRangeContrl,
                                          //style: TextStyle(color: Colors.black),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              startRange = int.parse(value);
                                            }
                                          },
                                          decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: "Enter current range",
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                  borderSide: BorderSide(width: 2, color: Colors.black)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                  borderSide: BorderSide(width: 5, color: Colors.black)),
                                              labelText: "Current",
                                              labelStyle: TextStyle(color: Colors.black, fontSize: 20.0, height: 1.8),
                                              contentPadding: EdgeInsets.all(20.0)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: TextField(
                                          controller: totalRangeContrl,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              totalRange = int.parse(value);
                                            }
                                          },
                                          decoration: const InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: "Enter Total Vehicle Range",
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                borderSide: BorderSide(width: 2, color: Colors.black)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                borderSide: BorderSide(width: 5, color: Colors.black)),
                                            labelText: "Total",
                                            labelStyle: TextStyle(
                                                color: Colors.black,
                                                //fontWeight: FontWeight.bold,
                                                fontSize: 20.0,
                                                height: 1.8),
                                            contentPadding: EdgeInsets.all(20.0),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: TextField(
                                          controller: mpgContrl,
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              estMPG = int.parse(value);
                                            }
                                          },
                                          decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: "Enter Estimated MPG",
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                  borderSide: BorderSide(width: 2, color: Colors.black)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                  borderSide: BorderSide(width: 5, color: Colors.black)),
                                              labelText: "MPG",
                                              labelStyle: TextStyle(
                                                  color: Colors.black,
                                                  //fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                  height: 1.8),
                                              contentPadding: EdgeInsets.all(20.0)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    showCarList = true;
                                                    setState(() {});
                                                  },
                                                  style: ElevatedButton.styleFrom(primary: Colors.red.shade500),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(5.0),
                                                    child: Text("My Vehicles"),
                                                  )),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    step--;
                                                    setState(() {});
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.red.shade500,
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(5.0),
                                                    child: Text("Prev Step"),
                                                  )),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  step++;
                                                  setState(() {});
                                                  if ((origin != null && destination != null) &&
                                                      (origin!.isNotEmpty && destination!.isNotEmpty) &&
                                                      (startRange != null && totalRange != null && estMPG != null)) {
                                                    await appState.setSinglePoint(origin!, "origin");
                                                    await appState.setSinglePoint(destination!, "destination");

                                                    setBounds(appState.originPlace!, appState.destinationPlace!);
                                                    await appState.setDirections();
                                                    await appState.setCarInfo(estMPG!, startRange!, totalRange!);
                                                    await appState.setStationPath();
                                                    if (appState.stationMarkersSet != null) {
                                                      allMarkers = appState.stationMarkersSet!;
                                                      setState(() {});
                                                      appState.setFinal();
                                                    }

                                                    linesSet = true;
                                                  } else {
                                                    step--;
                                                  }

                                                  setState(() {});
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.red.shade500,
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: Text("Show Route"),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                            ),

                          //show vehicle list
                          if (showCarList)
                            Align(
                              alignment: Alignment.center,
                              child: VehicleList(
                                mpg: (val) => setState(
                                  () {
                                    estMPG = int.parse(val);
                                    mpgContrl.text = estMPG.toString();
                                  },
                                ),
                                range: (val) => setState(() {
                                  totalRange = int.parse(val);
                                  totalRangeContrl.text = val;
                                  startRange = totalRange;
                                  currentRangeContrl.text = val;
                                  showCarList = false;
                                }),
                                listAction: "select",
                              ),
                            ),
                          //third shit for list
                          if (step > 2)
                            Container(
                              color: Colors.white.withOpacity(0.9),
                              child: (appState.finalPath!.legs == null)
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : CustomScrollView(
                                      semanticChildCount: appState.finalPath!.legs!.length,
                                      slivers: <Widget>[
                                        SliverSafeArea(
                                          sliver: SliverList(
                                            delegate: SliverChildBuilderDelegate(
                                              (context, index) {
                                                if (index < appState.finalPath!.legs!.length - 1) {
                                                  return StopInfo(
                                                    leg: appState.finalPath!.legs![index],
                                                    last: index == (appState.finalPath!.legs!.length - 2),
                                                    placeInfo: appState.pathPlaceList![index],
                                                    pos: index,
                                                  );
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            ),

                          Align(
                            alignment: Alignment.center,
                            child: (step == 2 && linesSet == false) ? const CircularProgressIndicator() : null,
                          )
                        ],
                      ),
                    ),
                    //second child of column
                    if (step > 1)
                      Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.blue[400]!,
                        ),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              alignment: Alignment.center,
                              width: 400,
                              height: 40,
                              decoration: const BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                              child: (appState.finalDest == null)
                                  ? const Text(
                                      "Loading Route Data ...",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      "Trip Details:\nPrice: \$${double.parse(appState.finalDest!.price!).toStringAsFixed(2)}  "
                                      "Dist: ${(appState.finalDest!.distanceValue! / 1609.83).toStringAsFixed(0)} mi  "
                                      "Time: ${(appState.finalDest!.durationValue! / 60) ~/ 60} hr "
                                      "${((appState.finalDest!.durationValue! / 60) % 60).toStringAsFixed(0)} min",
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (step == 2) {
                                    step++;
                                  } else if (step == 3) {
                                    step--;
                                  }
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                ),
                                child: (step == 3) ? const Text("Show Map") : const Text("Show List"),
                              ),
                              const SizedBox(width: 80),
                              ElevatedButton(
                                onPressed: () {
                                  appState.resetAll();
                                  resetScreen(
                                      LatLng(appState.currentLocation!.latitude, appState.currentLocation!.longitude));
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                ),
                                child: const Text("Return"),
                              )
                            ],
                          )
                        ]),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  //set new bounds once origin and destination plalces are created
  void setBounds(Place originPlace, Place destPlace) {
    setState(() {
      double swLat = (originPlace.geometry!.loc!.lat! <= destPlace.geometry!.loc!.lat!)
          ? originPlace.geometry!.loc!.lat!
          : destPlace.geometry!.loc!.lat!;

      double swLong = (originPlace.geometry!.loc!.long! <= destPlace.geometry!.loc!.long!)
          ? originPlace.geometry!.loc!.long!
          : destPlace.geometry!.loc!.long!;

      double neLat = (originPlace.geometry!.loc!.lat! >= destPlace.geometry!.loc!.lat!)
          ? originPlace.geometry!.loc!.lat!
          : destPlace.geometry!.loc!.lat!;

      double neLong = (originPlace.geometry!.loc!.long! >= destPlace.geometry!.loc!.long!)
          ? originPlace.geometry!.loc!.long!
          : destPlace.geometry!.loc!.long!;

      sw = LatLng(swLat, swLong);
      ne = LatLng(neLat, neLong);
    }); //end set state

    mapController.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: sw!,
        northeast: ne!,
      ),
      80.0,
    ));
  }

  //delete all data when reset at the end
  //return camera to current position
  void resetScreen(LatLng newTarget) {
    allMarkers = {};
    step = 0;
    totalRange = null;
    startRange = null;
    estMPG = null;
    linesSet = false;
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newTarget, zoom: 15.0)));
  }
}
