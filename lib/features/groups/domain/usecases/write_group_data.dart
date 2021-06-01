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

  //create admin group
  Future<bool> createAdminGroup() async {
    bool _success = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        return _success = true;
      } catch (e) {
        return _success;
      }
    } else if (connectivityResult == ConnectivityResult.none) {}
  }

  //create casual group

  Future<bool> createCasualGroup() async {
    final TextEditingController _groupNameController = TextEditingController();
    final TextEditingController _groupPasswordController =
        TextEditingController();
    bool _success = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a mobile network.
      try {
        firebaseUser = (await FirebaseAuth.instance.currentUser);
        firestoreInstance.collection("groups").doc(randID).set({
          "administrative group": false,
          "group name": _groupNameController.text,
          "group password": _groupPasswordController.text,
          "admins": firebaseUser.uid,
          "members": FieldValue.arrayUnion([firebaseUser.uid]),
        });
        return _success = true;
      } catch (e) {
        return _success;
      }
    } else if (connectivityResult == ConnectivityResult.none) {
      // I am not connected to a wifi network.
      return _success;
    }
  }

//join group
  Future<bool> joinGroup() async {
    final TextEditingController _groupIDController = TextEditingController();
    final TextEditingController _groupPasswordController =
        TextEditingController();

    bool _success = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        firebaseUser = (await FirebaseAuth.instance.currentUser);
        firestoreInstance
            .collection("groups")
            .doc(_groupIDController.text)
            .update({
          "members": FieldValue.arrayUnion([firebaseUser.uid]),
        });
        return _success = true;
      } catch (e) {
        return _success;
      }
    } else if (connectivityResult == ConnectivityResult.none) {
      return _success;
    }
    //leave group
    Future<bool> leaveGroup() async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
      } else if (connectivityResult == ConnectivityResult.none) {}
    }

    //transmit data
    Future<bool> transmitData() async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
      } else if (connectivityResult == ConnectivityResult.none) {}
    }
  }

  WriteGroupData();
}

WriteGroupData writeGroupData = WriteGroupData();
