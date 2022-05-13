import 'package:capstone/utilities/app_state.dart';
import 'package:flutter/material.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:provider/provider.dart';
import 'package:capstone/models/place.dart';
import '../widgets/stop_info.dart';

class NearestGasTab extends StatefulWidget {
  const NearestGasTab({Key? key}) : super(key: key);

  @override
  _NearestGasTabState createState() {
    return _NearestGasTabState();
  }
}

class _NearestGasTabState extends State<NearestGasTab> {
  late GoogleMapController mapController;
  final searchContrl = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.blue[400]),
      home: Scaffold(
        body: (appState.currentLocation == null)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  Container(
                    color: Colors.blue[400],
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                        controller: searchContrl,
                        onChanged: (value) => appState.searchPlaces(value, "single"),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.my_location),
                              onPressed: () async {
                                searchContrl.text = appState.startLoc![0].name! +
                                    ", " +
                                    appState.startLoc![0].locality! +
                                    ", " +
                                    appState.startLoc![0].administrativeArea! +
                                    ", USA";
                                await appState.setSinglePoint(searchContrl.text, "single");
                                appState.setNearestVars();
                              }),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter Search Location",
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(width: 2, color: Colors.black),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(width: 5, color: Colors.black),
                          ),
                          labelText: "Search",
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              //fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              height: 1.8),
                          contentPadding: const EdgeInsets.all(20.0),
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      SizedBox(
                        height: 300.0,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          markers: Set<Marker>.from(appState.singleMarkerSet!),
                          initialCameraPosition: CameraPosition(
                              target: LatLng(
                                appState.currentLocation!.latitude,
                                appState.currentLocation!.longitude,
                              ),
                              zoom: 14),
                          onMapCreated: _onMapCreated,
                        ),
                      ),
                      if (appState.searchResults != null && appState.searchResults!.isNotEmpty)
                        SizedBox(
                          height: 300.0,
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.8),
                            ),
                          ),
                        ),
                      if (appState.searchResults != null && appState.searchResults!.isNotEmpty)
                        SizedBox(
                          height: 300.0,
                          child: ListView.builder(
                            itemCount: appState.searchResults!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  appState.searchResults![index].address!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () async {
                                  await appState.setNewLocation(appState.searchResults![index].placeId!, "single");
                                  newLocation(appState.singlePlace!);
                                  searchContrl.text = appState.singlePlace!.address!;
                                  appState.setNearestVars();
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  Container(
                    color: Colors.white.withOpacity(0.9),
                    child: (appState.stationList == null || appState.stationList!.isEmpty)
                        ? SizedBox(
                            height: 350,
                            child: Container(
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            ),
                          )
                        : SizedBox(
                            height: 350,
                            child: CustomScrollView(
                              semanticChildCount: appState.stationList!.length,
                              slivers: <Widget>[
                                SliverSafeArea(
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (index < appState.stationList!.length - 1) {
                                          return StopInfo(
                                            //display max 20 closest,
                                            last: index ==
                                                ((20 < appState.stationList!.length - 1)
                                                    ? 20
                                                    : appState.stationList!.length - 1),
                                            placeInfo: appState.stationList![index],
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
                  )
                ],
              ),
      ),
    );
  }

  void newLocation(Place place) async {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            place.geometry!.loc!.lat!,
            place.geometry!.loc!.long!,
          ),
          zoom: 14.0,
        ),
      ),
    );
  }
}
