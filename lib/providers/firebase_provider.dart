import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// register new user from login screen
Future<String?> register(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    return null;
  } on FirebaseAuthException catch (e) {
    return (e.toString());
  }
}

//login existing user or do nothing if invalid
Future<String?> login(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    return e.toString();
  }
  return null;
}

//add vehicle to firestore (error checking done prior so assume all info is correct)
Future<void> addVehicle(int totalRange, int mpg, String name) async {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DocumentReference docRef = FirebaseFirestore.instance.collection('Users').doc(uid).collection('name').doc(name);

  FirebaseFirestore.instance.runTransaction((transaction) async {
    docRef.set({"mpg": mpg, "range": totalRange});
  });
}

//remove vehicle from firestore
Future<void> deleteVehicle(String name) async {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  DocumentReference docRef = FirebaseFirestore.instance.collection('Users').doc(uid).collection('name').doc(name);
  docRef.delete();
}
