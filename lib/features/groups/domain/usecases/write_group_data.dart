import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/groups/data/datasources/keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WriteGroupData {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupPasswordController = TextEditingController();
  TextEditingController verifyGroupPasswordController = TextEditingController();
  final TextEditingController groupIDController = TextEditingController();

  //create admin group
  Future<bool> createAdminGroup() async {
    TextEditingController();
    bool _success = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        var empty = [];
        firebaseUser = FirebaseAuth.instance.currentUser;
        firestoreInstance.collection("groups").doc(randID).set({
          "administrative group": true,
          "group name": groupNameController.text,
          "group password": groupPasswordController.text,
          "members": FieldValue.arrayUnion([firebaseUser.uid]),
          "plot total": FieldValue.arrayUnion(empty),
          "plot time": FieldValue.arrayUnion(empty),
        });
        print("Group: " + groupNameController.text + " created");
        return _success = true;
      } catch (e) {
        print("ERROR");
        return _success;
      }
    } else {
      print("NOT CONNECTED TO NETWORK");
      return _success;
    }
  }

  //create casual group

  Future<bool> createCasualGroup() async {
        TextEditingController();
    bool _success = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.
      try {
        var empty = [];
        firebaseUser = FirebaseAuth.instance.currentUser;
        firestoreInstance.collection("groups").doc(randID).set({
          "administrative group": false,
          "group name": groupNameController.text,
          "group password": groupPasswordController.text,
          "admins": firebaseUser.uid,
          "members": FieldValue.arrayUnion([firebaseUser.uid]),
          "plot total": FieldValue.arrayUnion(empty),
          "plot time": FieldValue.arrayUnion(empty),
        });
        print("Group: " + groupNameController.text + " created");
        return _success = true;
      } catch (e) {
        print("ERROR");
        return _success;
      }
    } else {
      // I am not connected to a wifi network.
      print("NOT CONNECTED TO NETWORK");
      return _success;
    }
  }

  //join group
  Future<bool> joinGroup() async {
    bool _success = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        firebaseUser = FirebaseAuth.instance.currentUser;
        firestoreInstance
            .collection("groups")
            .doc(groupIDController.text)
            .update({
          "members": FieldValue.arrayUnion([firebaseUser.uid]),
        });
        print("Group ID: " + groupIDController.text + " joined");
        return _success = true;
      } catch (e) {
        print("ERROR");
        return _success;
      }
    } else {
      print("NOT CONNECTED TO NETWORK");
      return _success;
    }
    //leave group
  }

  Future<void> leaveGroup() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
    } else {
      print("NOT CONNECTED TO NETWORK");
    }
  }

  //transmit data
  Future<void> transmitData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
    } else {}
  }

  WriteGroupData();
}

WriteGroupData writeGroupData = WriteGroupData();
