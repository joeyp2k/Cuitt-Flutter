import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/groups/data/datasources/keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WriteGroupData {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupPasswordController = TextEditingController();
  TextEditingController verifyGroupPasswordController = TextEditingController();
  TextEditingController groupIDController = TextEditingController();

  //create admin group
  Future<bool> createAdminGroup() async {
    TextEditingController();
    bool _success = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        var timePlots = [];
        var drawLengthPlots = [];

        //TODO load local storage, compare against remote storage, update local storage, push local storage

        for (int i = 0; i < dayData.length; i++) {
          timePlots.add(dayData[i].time);
          drawLengthPlots.add(dayData[i].seconds);
        }

        var currentTime =
            DateTime(viewport.year, viewport.month, viewport.day, viewport.hour)
                .toLocal();

        if (timePlots.first.isBefore(currentTime)) {
          //extend data range to current time
          while (timePlots.first != currentTime) {
            print(currentTime.toString() + " " + timePlots.first.toString());
            var zero = timePlots.first.add(Duration(hours: 1));
            timePlots.insert(0, zero);
            drawLengthPlots.insert(0, 0);
          }
        }

        firebaseUser = FirebaseAuth.instance.currentUser;
        firestoreInstance.collection("groups").doc(randID).set({
          "administrative group": true,
          "group name": groupNameController.text,
          "group password": groupPasswordController.text,
          "members": FieldValue.arrayUnion([firebaseUser.uid]),
          "plot total": drawLengthPlots,
          "plot time": timePlots,
        });
        print("Group: " +
            groupNameController.text +
            " created: updating with first user data");
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
      // I am connected to a wireless network.
      try {
        //add existing user plots to group
        var timePlots = [];
        var drawLengthPlots = [];

        for (int i = 0; i < dayData.length; i++) {
          timePlots.add(dayData[i].time);
          drawLengthPlots.add(dayData[i].seconds);
        }

        var currentTime =
            DateTime(viewport.year, viewport.month, viewport.day, viewport.hour)
                .toLocal();

        if (timePlots.first.isBefore(currentTime)) {
          //extend data range to current time
          while (timePlots.first != currentTime) {
            print(currentTime.toString() + " " + timePlots.first.toString());
            var zero = timePlots.first.add(Duration(hours: 1));
            timePlots.insert(0, zero);
            drawLengthPlots.insert(0, 0);
          }
        }

        firebaseUser = FirebaseAuth.instance.currentUser;
        firestoreInstance.collection("groups").doc(randID).set({
          "administrative group": false,
          "group name": groupNameController.text,
          "group password": groupPasswordController.text,
          "admins": firebaseUser.uid,
          "members": FieldValue.arrayUnion([firebaseUser.uid]),
          "plot total": drawLengthPlots,
          "plot time": timePlots,
        });
        print("Group: " + groupNameController.text + " created");

        _success = true;
        return _success;
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

        //pull plot total and plot time arrays, iterate over each adding corresponding values for user, and push
        var group = await firestoreInstance
            .collection("groups")
            .doc(groupIDController.text)
            .get();
        var drawLengthPlots = group["plot total"];
        var timePlots = group["plot time"];
        print("BEFORE");
        print(drawLengthPlots);
        print(timePlots);
        //if the first data in remote plots was created after the first new user's plots, extend the time range of the group data backward
        if (timePlots.first.toDate().isAfter(dayData.first.time)) {
          int i = 0;
          while (timePlots.first.toDate() != dayData.first.time) {
            timePlots.insert(0, dayData[i].time);
            drawLengthPlots.insert(0, dayData[i].seconds);
            i++;
          }
        }

        //if the last data in remote plots was created before the last new user's plots, extend the time range of the group data forward
        if (timePlots.last.toDate().isBefore(dayData.last.time)) {
          int i = dayData.length;
          while (timePlots.last.toDate() != dayData.last.time) {
            timePlots.insert(timePlots.length, dayData[i].time);
            drawLengthPlots.insert(drawLengthPlots.length, dayData[i].seconds);
            i--;
          }
        }

        //add user draw history to group data
        int a = timePlots.length - 1;
        int i = dayData.length - 1;

        assert(a == i);

        for (int i = dayData.length - 1; i > 0; i--) {
          print(timePlots[i].toDate().toString() +
              "||||" +
              dayData[i].time.toString());
          drawLengthPlots[i] += dayData[i].seconds;
        }

        print("AFTER");
        print(timePlots);
        print(drawLengthPlots);
        // firestoreInstance.collection("groups").doc(groupIDController.text).set({
        //   "plot total": drawLengthPlots,
        //   "plot time": timePlots,
        // });

        _success = true;
        return _success;
      } catch (e) {
        print("ERROR: " + e.toString());
        return _success;
      }
    } else {
      print("NOT CONNECTED TO NETWORK");
      return _success;
    }
  }

  //leave group
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
