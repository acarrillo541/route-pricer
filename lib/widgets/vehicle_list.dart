import 'package:capstone/providers/firebase_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'vehicle_info.dart';
import 'package:flutter/material.dart';

typedef StringCallback = void Function(String val);

// ignore: must_be_immutable
class VehicleList extends StatelessWidget {
  VehicleList({
    required this.listAction,
    this.mpg,
    this.range,
    Key? key,
  }) : super(key: key);

  final String listAction;
  StringCallback? mpg;
  StringCallback? range;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 590,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('name')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: ListView(
                children: snapshot.data!.docs.map((e) {
                  return VehicleInfo(
                      buttonAction: () {
                        if (listAction == 'delete') {
                          deleteVehicle(e.id);
                        } else if (listAction == 'select') {
                          mpg!(e['mpg'].toString());
                          range!(
                            e['range'].toString(),
                          );
                        }
                      },
                      mpg: e['mpg'],
                      range: e['range'],
                      name: e.id,
                      last: (!e.exists),
                      buttonName: (listAction == "select") ? "Select" : "Delete");
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
