import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cuitt/features/connect_device/data/datasources/user_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/groups/data/datasources/keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class WriteGroupData {
  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupPasswordController = TextEditingController();
  TextEditingController verifyGroupPasswordController = TextEditingController();
  TextEditingController groupIDController = TextEditingController();

  Future<void> _storeStatsData(StatInsert statInsert) async {
    final db = await userDatabase;
    //query for existing user
    List<Map<String, dynamic>> query = await db.query(
      'userstats',
      columns: ['userid'],
      where: '"userid" = ?',
      whereArgs: [statInsert.userid],
    );

    if (query.isNotEmpty) {
      //replace user stats
      var id = query[0]["id"];
      statInsert.id = id;
    }
    await db.insert(
      'userstats',
      statInsert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _storeHourData(drawTime, HourInsert hourInsert) async {
    final db = await userDatabase;
    //query for existing hour
    List<Map<String, dynamic>> query = await db.query(
      'userhour',
      columns: ['userid', 'hour'],
      where: '"userid" = ? AND "hour" = ?',
      whereArgs: [hourInsert.userid, drawTime],
    );
    if (query.isNotEmpty) {
      //update user stats
      var id = query[0]["id"];
      var total = hourInsert.drawLength + query[0]["drawLength"];
      hourInsert.drawLength = total;
      hourInsert.id = id;
    }
    await db.insert(
      'userhour',
      hourInsert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _storeDayData(drawTime, DayInsert dayInsert) async {
    final db = await userDatabase;
    //query for existing hour
    List<Map<String, dynamic>> query = await db.query(
      'userday',
      columns: ['userid', 'day'],
      where: '"userid" = ? AND "day" = ?',
      whereArgs: [dayInsert.userid, drawTime],
    );
    if (query.isNotEmpty) {
      //update user stats
      var id = query[0]["id"];
      var total = dayInsert.drawLength + query[0]["drawLength"];
      dayInsert.drawLength = total;
      dayInsert.id = id;
    }
    await db.insert(
      'userday',
      dayInsert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _storeMonthData(drawTime, MonthInsert monthInsert) async {
    final db = await userDatabase;
    //query for existing hour
    List<Map<String, dynamic>> query = await db.query(
      'usermonth',
      columns: ['userid', 'month'],
      where: '"userid" = ? AND "month" = ?',
      whereArgs: [monthInsert.userid, drawTime],
    );
    if (query.isNotEmpty) {
      //update user stats
      var id = query[0]["id"];
      var total = monthInsert.drawLength + query[0]["drawLength"];
      monthInsert.drawLength = total;
      monthInsert.id = id;
    }
    await db.insert(
      'usermonth',
      monthInsert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //create admin group
  Future<bool> createAdminGroup() async {
    TextEditingController();
    bool _success = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        firebaseUser = FirebaseAuth.instance.currentUser;
        firestoreInstance.collection("groups").doc(randID).set({
          "administrative group": true,
          "group name": groupNameController.text,
          "group password": groupPasswordController.text,
          "members": FieldValue.arrayUnion([firebaseUser.uid]),
        });
        return _success = true;
      } catch (e) {
        return _success;
      }
    }
    return _success;
  }

  //create casual group
  Future<bool> createCasualGroup() async {
        TextEditingController();
    bool _success = false;
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        firebaseUser = FirebaseAuth.instance.currentUser;
        firestoreInstance.collection("groups").doc(randID).set({
          "administrative group": false,
          "group name": groupNameController.text,
          "group password": groupPasswordController.text,
          "admins": firebaseUser.uid,
          "members": FieldValue.arrayUnion([firebaseUser.uid]),
        });

        _success = true;
        return _success;
      } catch (e) {
        return _success;
      }
    } else {
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

        var group = await firestoreInstance
            .collection("groups")
            .doc(groupIDController.text)
            .get();
        var userIDs = group["members"];
        var db = await userDatabase;
        for (int i = 0; i < userIDs.length; i++) {
          //if local data exists for user, update data from remote
          //if local data doesn't exist for user, initialize data from remote
          List<Map<String, dynamic>> queryStats = await db.query(
            'userstats',
            where: '"userid" = ?',
            whereArgs: [userIDs[i]],
          );

          final List<Map<String, dynamic>> queryHour = await db.query(
            'userhour',
            where: '"userid" = ?',
            whereArgs: [userIDs[i]],
          );

          final List<Map<String, dynamic>> queryDay = await db.query(
            'userday',
            where: '"userid" = ?',
            whereArgs: [userIDs[i]],
          );

          final List<Map<String, dynamic>> queryMonth = await db.query(
            'usermonth',
            where: '"userid" = ?',
            whereArgs: [userIDs[i]],
          );

          var data =
              await firestoreInstance.collection("users").doc(userIDs[i]).get();
          if (data.exists) {
            //copy remote storage to local
            var statInsert = StatInsert(
              userid: userIDs[i],
              drawCount: data["draws"],
              drawLengthAverage: data["draw length average"],
              drawLengthAverageYest: data["draw length average yesterday"],
              drawLengthTotal: data["draw length total"],
              drawLengthTotalYest: data["draw length total yesterday"],
              drawLengthTotalAverage: data["draw length total average"],
              drawLengthTotalAverageYest:
                  data["draw length total average yesterday"],
            );
            await _storeStatsData(statInsert);
          }

          var hourRef = await firestoreInstance
              .collection("users")
              .doc(userIDs[i])
              .collection("Hour")
              .get();
          var hours = hourRef.docs;
          if (hours.isNotEmpty) {
            //copy remote storage to local
            hours.forEach((doc) async {
              var hourInsert = HourInsert(
                userid: userIDs[i],
                drawLength: doc["draw length total"],
                hour: doc["time"].toDate().toUtc().millisecondsSinceEpoch,
              );
              var drawTime =
                  doc["time"].toDate().toUtc().millisecondsSinceEpoch;
              await _storeHourData(drawTime, hourInsert);
            });
          }

          var daysRef = await firestoreInstance
              .collection("users")
              .doc(userIDs[i])
              .collection("Day")
              .get();
          var days = daysRef.docs;
          if (days.isNotEmpty) {
            //copy remote storage to local
            days.forEach((doc) async {
              var dayInsert = DayInsert(
                userid: userIDs[i],
                drawLength: doc["draw length total"],
                day: doc["time"].toDate().toUtc().millisecondsSinceEpoch,
              );
              var drawTime =
                  doc["time"].toDate().toUtc().millisecondsSinceEpoch;
              await _storeDayData(drawTime, dayInsert);
            });
          }

          var monthsRef = await firestoreInstance
              .collection("users")
              .doc(userIDs[i])
              .collection("Month")
              .get();
          var months = monthsRef.docs;
          if (months.isNotEmpty) {
            //copy remote storage to local
            months.forEach((doc) async {
              var monthInsert = MonthInsert(
                userid: userIDs[i],
                drawLength: doc["draw length total"],
                month: doc["time"].toDate().toUtc().millisecondsSinceEpoch,
              );
              var drawTime =
                  doc["time"].toDate().toUtc().millisecondsSinceEpoch;
              await _storeMonthData(drawTime, monthInsert);
            });
          }
          _success = true;
          return _success;
        }
      } catch (e) {
        return _success;
      }
    }
    return _success;
  }

  //leave group
  Future<void> leaveGroup() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {}
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
