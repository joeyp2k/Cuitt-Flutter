import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:convert/convert.dart';
import 'package:cuitt/features/connect_device/data/datasources/user_data.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_bloc.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_event.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:sqflite/sqflite.dart';

class ConnectBLE {
  bool refresh = false;
  bool firstTransmit = true;
  var _readval;
  var _lastval;
  var _devKitID = "EA:AE:28:55:CC:33";
  var _transferService = "43831400-7675-4236-a2d4-446e41499891";
  var _transferChar = "43831401-7675-4236-a2d4-446e41499891";

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic _ledChar;

  Future<void> insertUserData(UserData userData) async {
    // Get a reference to the database.
    final db = await userDatabase;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'userdata',
      userData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertDayData(DayPlotData userData) async {
    // Get a reference to the database.
    final db = await userDatabase;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'daydata',
      userData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertMonthData(MonthPlotData userData) async {
    // Get a reference to the database.
    final db = await userDatabase;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'monthdata',
      userData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<UserData>> _getUserData() async {
    // Get a reference to the database.
    final db = await userDatabase;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('userdata');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return UserData(
        id: maps[i]['id'],
        drawCount: maps[i]['drawCount'],
        drawLengthTotal: maps[i]['drawLengthTotal'],
        drawLengthTotalAverage: maps[i]['drawLengthTotalAverage'],
        drawLengthTotalAverageYest: maps[i]['drawLengthTotalAverageYest'],
        drawLengthTotalYest: maps[i]['drawLengthTotalYest'],
        drawLengthAverageYest: maps[i]['drawLengthAverageYest'],
        drawLengthAverage: maps[i]['drawLengthAverage'],
      );
    });
  }

  Future<List<DayPlotData>> _getDayData() async {
    // Get a reference to the database.
    final db = await userDatabase;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('daydata');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return DayPlotData(
        id: maps[i]['id'],
        plotTotal: maps[i]["plotTotal"],
        plotTime: maps[i]["plotTime"],
      );
    });
  }

  Future<List<MonthPlotData>> _getMonthData() async {
    // Get a reference to the database.
    final db = await userDatabase;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('monthdata');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return MonthPlotData(
        id: maps[i]['id'],
        plotTotal: maps[i]["plotTotal"],
        plotTime: maps[i]["plotTime"],
      );
    });
  }

  void printData() {
    // print("DAY");
    // for(int i = 0; i < dayData.length; i++){
    //   print(dayData[i].time);
    // }
    print("MONTH");
    for (int i = 0; i < monthData.length; i++) {
      print(monthData[i].time);
    }
  }

  Future<void> initializeData() async {
    //TODO load local storage, compare against remote storage, update local storage, push local storage to display layer
    firebaseUser = FirebaseAuth.instance.currentUser;
    //load local storage
    //load remote storage
    //if remote more up to date than local, update local
    //if local more up to date than remote, update remote
    //push local storage to display layer

    var stats = await _getUserData();
    if (stats.isNotEmpty) {
      print("Getting local stats");
      //store stats
      drawCount = stats[0].drawCount;
      drawLengthTotal = stats[0].drawLengthTotal;
      drawLengthTotalAverage = stats[0].drawLengthTotalAverage;
      drawLengthTotalYest = stats[0].drawLengthTotalYest;
      drawLengthTotalAverageYest = stats[0].drawLengthTotalAverageYest;
      drawLengthAverageYest = stats[0].drawLengthAverageYest;
      drawLengthAverage = stats[0].drawLengthAverage;
    } else {
      //get remote data
      print("Get remote stats data");
      var value = await firestoreInstance
          .collection("users")
          .doc(firebaseUser.uid)
          .collection("data")
          .doc('stats')
          .get();
      if (value != null) {
        print("Remote data exists");
        drawLengthAverageYest = value["draw length average yesterday"];
        drawLengthTotal = value["draw length total"];
        drawLengthAverage = value["draw length average"];
        drawCount = value["draws"];
      }
    }
    //replace current plots with local storage
    //TODO FIX DATA ERROR "FIRST RUN CAUSES INDEX SHIFTING DUE TO 0 INDEXES NOT BEING THE SAME VALUE"
    var day = await _getDayData();
    if (day.isNotEmpty) {
      print("Getting local day data");
      dayData.clear();
      for (int i = day.length; i > 0; i--) {
        var time = DateTime.fromMillisecondsSinceEpoch(day[i].plotTime);
        var seconds = day[i].plotTotal;
        var insert = UsageData(time, seconds);
        dayData.insert(0, insert);
      }
    } else {
      print("Getting remote day data");
      await firestoreInstance
          .collection("users")
          .doc(firebaseUser.uid)
          .collection("data")
          .doc('day data')
          .get()
          .then((value) {
        var currentTime =
            DateTime(viewport.year, viewport.month, viewport.day, viewport.hour)
                .toLocal();
        if (value["time"].last.toDate().isAfter(currentTime)) {
          //extend data range to current time
          while (value["time"].last.toDate() != dayData.last.time) {
            print(value["time"].last.toDate.toString() +
                "||||" +
                dayData.last.time.toString());
            var zero = dayData.last.time.add(Duration(hours: 1));
            dayData.add(UsageData(zero, 0));
          }
        }
        //populate values
        int i = dayData.length - 1;
        int a = value["time"].length - 1;
        print(i);
        print(a);
        while (value["time"].first.toDate() != dayData[i].time && a != -1) {
          print(value["time"].first.toDate().toString() +
              "||||" +
              dayData[i].time.toString() +
              " A: " +
              a.toString());
          if (i == 0) {
            dayData.insert(0,
                UsageData(value["time"][a].toDate(), value["draw length"][a]));
            a--;
          } else {
            dayData[i] =
                UsageData(value["time"][a].toDate(), value["draw length"][a]);
            a--;
            i--;
          }
        }
        print(value["time"].first.toDate().toString() +
            "||||" +
            dayData[i].time.toString() +
            " A: " +
            a.toString());
      });
      //TODO update local data
    }

    var month = await _getMonthData();
    if (month.isNotEmpty) {
      print("Getting local month data");
      monthData.clear();
      for (int i = month.length; i > 0; i--) {
        var time = DateTime.fromMillisecondsSinceEpoch(month[i].plotTime);
        var seconds = month[i].plotTotal;
        var insert = UsageData(time, seconds);
        monthData.insert(0, insert);
      }
    } else {
      print("Getting remote month data");
      await firestoreInstance
          .collection("users")
          .doc(firebaseUser.uid)
          .collection("data")
          .doc('month data')
          .get()
          .then((value) {
        var currentTime =
            DateTime(viewport.year, viewport.month, viewport.day, viewport.hour)
                .toLocal();
        if (value["time"].last.toDate().isAfter(currentTime)) {
          //extend data range to current time
          print("extending data range");
          while (value["time"].last.toDate() != monthData.last.time) {
            var zero = monthData.last.time.add(Duration(hours: 1));
            monthData.add(UsageData(zero, 0));
          }
        }
        //populate values
        int i = monthData.length - 1;
        int a = value["time"].length - 1;
        print(i);
        print(a);
        print(monthData[i].time);
        print(value["time"][a].toDate().toString() + "\n");
        print(monthData[2].time.toString());
        print(monthData[1].time.toString());
        print(monthData[0].time.toString());
        while (value["time"].first.toDate() != monthData[i].time && a != -1) {
          print(value["time"].first.toDate().toString() +
              "||||" +
              monthData[i].time.toString() +
              " A: " +
              a.toString() +
              " I: " +
              i.toString());
          if (i == 0) {
            print("INSERTION");
            monthData.insert(0,
                UsageData(value["time"][a].toDate(), value["draw length"][a]));
            a--;
          } else {
            print("MO DAT " +
                i.toString() +
                " BEFORE: " +
                monthData[i].time.toString());
            monthData[i] =
                UsageData(value["time"][a].toDate(), value["draw length"][a]);
            print("MO DAT " +
                i.toString() +
                " AFTER: " +
                monthData[i].time.toString());
            a--;
            i--;
          }
        }
        print(value["time"].first.toDate().toString() +
            "||||" +
            monthData[i].time.toString() +
            " A: " +
            a.toString());
        print(monthData[2].time.toString());
        print(monthData[1].time.toString());
        print(monthData[0].time.toString());
      });
    }
    //TODO update local data
    print("DATA INITIALIZATION COMPLETE");
  }

  Future<void> storeData() async {
    //if no table ID, initialize database with first data
    if (statTableID == null) {
      print("initialize local data");
      statTableID = 0;
      var data = UserData(
        id: statTableID,
        drawCount: drawCount,
        drawLengthTotal: drawLengthTotal,
        drawLengthTotalAverage: drawLengthTotalAverage,
        drawLengthTotalAverageYest: drawLengthTotalAverageYest,
        drawLengthTotalYest: drawLengthTotalYest,
        drawLengthAverageYest: drawLengthAverageYest,
        drawLengthAverage: drawLengthAverage,
      );

      await insertUserData(data);

      dayTableID = 0;
      for (int i = 0; i < dayData.length; i++) {
        var data = DayPlotData(
          id: dayTableID,
          plotTime: dayData[i].time.toUtc().millisecondsSinceEpoch,
          plotTotal: dayData[i].seconds,
        );
        await insertDayData(data);
        dayTableID++;
      }
      monthTableID = 0;
      for (int i = 0; i < monthData.length; i++) {
        var data = MonthPlotData(
          id: monthTableID,
          plotTime: monthData[i].time.toUtc().millisecondsSinceEpoch,
          plotTotal: monthData[i].seconds,
        );
        await insertMonthData(data);
        monthTableID++;
      }
      print("LOCAL DAY DATA LENGTH: " + monthData.toString());
      print("LOCAL MONTH DATA LENGTH: " + dayData.toString());
    } else {
      //update with new data
      var statInsertion = UserData(
        id: statTableID,
        drawCount: drawCount,
        drawLengthTotal: drawLengthTotal,
        drawLengthTotalAverage: drawLengthTotalAverage,
        drawLengthTotalAverageYest: drawLengthTotalAverageYest,
        drawLengthTotalYest: drawLengthTotalYest,
        drawLengthAverageYest: drawLengthAverageYest,
        drawLengthAverage: drawLengthAverage,
      );

      await insertUserData(statInsertion);

      var dayInsertion = DayPlotData(
        id: dayTableID,
        plotTime: dayData.last.time.toUtc().millisecondsSinceEpoch,
        plotTotal: dayData.last.seconds,
      );
      await insertDayData(dayInsertion);
      dayTableID++;

      var monthInsertion = MonthPlotData(
        id: monthTableID,
        plotTime: monthData.last.time.toUtc().millisecondsSinceEpoch,
        plotTotal: monthData.last.seconds,
      );
      await insertMonthData(monthInsertion);
      monthTableID++;
    }
  }

  void _copyData() {
    currentTime =
        int.parse(hex.encode(_readval.sublist(0, 4)).toString(), radix: 16);
    drawLength =
        int.parse(hex.encode(_readval.sublist(4, 6)).toString(), radix: 16) /
            1000;
    drawCount =
        int.parse(hex.encode(_readval.sublist(6, 8)).toString(), radix: 16);
    seshCount =
        int.parse(hex.encode(_readval.sublist(8, 10)).toString(), radix: 16);
  }

  void _calculateA() {
    //print('Draw Length Total (CALC A) pre calculation: ' +
    //drawLengthTotal.toString());
    drawLengthTotal += drawLength;
    //print('Draw Length Total (CALC A): ' + drawLengthTotal.toString());
    drawLengthAverage = drawLengthTotal / drawCount;
    drawLengthTotalAverage =
        drawLengthTotal / dayNum; //CHANGE TO CALCULATION ARRAY FOR DLT BY DAY
    drawCountAverage =
        drawCount / dayNum; //CHANGE TO CALCULATION ARRAY FOR DCT BY DAY
    seshCountAverage =
        seshCount / dayNum; //CHANGE TO CALCULATION ARRAY FOR DCT BY DAY
    suggestion = drawLengthTotalAverage / drawCountAverage * decay;
  }

  void _checkTime() {
    // subFromInteger called on null
    if (hitTimeNow == 0) {
      print(
          'Hit Time Now = 0, Check for Updated Current Time to Load Into Hit Time Now and Hit Time Then');
      hitTimeNow = currentTime;
      hitTimeThen = hitTimeNow;
      print('Hit Time Now = ' +
          hitTimeNow.toString() +
          ' and Hit Time Then = ' +
          hitTimeThen.toString());
    } else {
      print(
          'Hit Time Now != 0, Update Hit Time Then and Load Current Time into Hit Time Now');
      hitTimeThen = hitTimeNow;
      hitTimeNow = currentTime;
      print('Hit Time Now = ' +
          hitTimeNow.toString() +
          ' and Hit Time Then = ' +
          hitTimeThen.toString());
    }
  }

  void _calculateB() {
    waitPeriod = (16 / seshCountAverage * 60 * 60).round();
    timeBetween = hitTimeNow - hitTimeThen;
    timeUntilNext = waitPeriod - timeBetween;

    if (seshCount > 1) {
      timeBetweenAverage = (timeBetweenAverage + timeBetween) / (seshCount - 1);
      avgWaitTileSecs = timeBetweenAverage.round() % 60;
      avgWaitTileMinutes = (timeBetweenAverage.round() / 60).truncate();
      avgWaitTileHours = (timeBetweenAverage.round() / 3600).truncate();
    } else {
      timeBetweenAverage = 0;
    }
    hitLengthArray.add(drawLength);
    timestampArray.add(currentTime);
    if (drawLengthTotal == 0) {
      usage = 0;
    } else {
      usage = (drawLengthTotal / drawLengthTotalAverageYest) *
          100; //percentage of allowed usage for chart
    }
  }

  void _sendData() async {
    var plotTime;
    var group;
    var timeReciever = [];
    var totalReciever = [];
    int currentIndex = dayData.length - 1;
    var connectivityResult = await (Connectivity().checkConnectivity());
    print("ATTEMPTING TRANSMISSION");
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        //TODO WHEN PREEXISTING DATA IN GROUP EXISTS, NEW USERS ADDED WILL NOT HAVE SAME CHART INDEX AS GROUP
        if (buffer == 0) {
          //proceed normally with one send
          firebaseUser = FirebaseAuth.instance.currentUser;

          await firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .collection("data")
              .doc('stats')
              .set({
            "draws": drawCount,
            "draw length average": drawLengthAverage,
            "draw length total": drawLengthTotal,
            "draw length average yesterday": drawLengthTotalAverageYest,
          });
          //Groups Transmission
          //check if current time exists
          //if time does not exist already add new time and new plot total by pulling array, adding, and pushing new array
          //if time exists, increment plot total
          print("GROUPS TRANSMISSION");
          await firestoreInstance
              .collection("groups")
              .where("members", arrayContains: firebaseUser.uid)
              .get()
              .then((value) async {
            //upon catching error, function doesn't continue past try point
            print("GROUPS WHERE CURRENT USER IS A MEMBER: " +
                value.docs.toString());
            for (int i = 0; i < value.docs.length; i++) {
              print(value.docs[i].id);
              plotTime = await value.docs[i].get("plot time");
              if (plotTime.isNotEmpty) {
                if (plotTime.last.toDate() == dayData[graphIndex].time) {
                  print("INCREMENTING");

                  group = await firestoreInstance
                      .collection("groups")
                      .doc(value.docs[i].id)
                      .get();

                  totalReciever = group["plot total"];

                  print(totalReciever.last);
                  totalReciever.last += drawLength;
                  print(totalReciever.last);

                  firestoreInstance
                      .collection("groups")
                      .doc(value.docs[i].id)
                      .update({
                    "plot total": totalReciever,
                  });
                } else {
                  print("ADDING");
                  group = await firestoreInstance
                      .collection("groups")
                      .doc(value.docs[i].id)
                      .get();

                  totalReciever = group["plot total"];
                  timeReciever = group["plot time"];
                  totalReciever.add(dayData[graphIndex].seconds);
                  timeReciever.add(dayData[graphIndex].time);

                  firestoreInstance
                      .collection("groups")
                      .doc(value.docs[i].id)
                      .update({
                    "plot total": totalReciever,
                    "plot time": timeReciever,
                  });
                }
              } else {
                print("PLOT TIME IS EMPTY");
                print("ADDING");

                group = await firestoreInstance
                    .collection("groups")
                    .doc(value.docs[i].id)
                    .get();

                totalReciever = group["plot total"];
                timeReciever = group["plot time"];
                totalReciever.add(dayData[graphIndex].seconds);
                timeReciever.add(dayData[graphIndex].time);

                firestoreInstance
                    .collection("groups")
                    .doc(value.docs[i].id)
                    .update({
                  "plot total": totalReciever,
                  "plot time": timeReciever,
                });
              }
            }
            /*
            value.docs.forEach((element) async {
                //get the last plot time from each group the user is in
                plotTime = await element
                    .get("plot time");
                //if the plot time is the same as the current day data time, increment the plot total
                print("PLOT TIME");
                print(plotTime);
                print(dayData[graphIndex].time);
                print(plotTime.runtimeType);
                print(dayData[graphIndex].time.runtimeType);

                if (plotTime.toDate() == dayData[graphIndex].time) {
                  print("INCREMENTING");
                  group = await firestoreInstance.collection("groups")
                      .doc(element.id)
                      .get();

                  totalReciever = group["plot total"];
                  totalReciever.last.increment(drawLength);

                  firestoreInstance
                      .collection("groups")
                      .doc(element.id)
                      .set({
                    "plot total": totalReciever,
                  });

                  //if the last plot time is not the same as the current day data time
                  //pull the plot total and plot time, add the new values, and push
                } else if (plotTime != dayData[graphIndex].time) {
                  print("ADDING");
                  group = await firestoreInstance.collection("groups")
                      .doc(element.id)
                      .get();

                  totalReciever = group["plot total"];
                  timeReciever = group["plot time"];
                  totalReciever.add(dayData[graphIndex].seconds);
                  timeReciever.add(dayData[graphIndex].time);

                  firestoreInstance
                      .collection("groups")
                      .doc(element.id)
                      .set({
                    "plot total": totalReciever,
                    "plot time": timeReciever,
                  });
                }
          });

             */
          });
          //user transmission
          print("USER TRANSMISSION");
          //TODO INCREASE EFFICIENCY OF users transmission
          timeReciever.clear();
          totalReciever.clear();

          for (int i = 0; i < dayData.length; i++) {
            timeReciever.add(dayData[i].time);
            totalReciever.add(dayData[i].seconds);
          }

          firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .collection('data')
              .doc('day data')
              .set({
            "time": timeReciever,
            "draw length": totalReciever,
          });

          timeReciever.clear();
          totalReciever.clear();

          for (int i = 0; i < monthData.length; i++) {
            timeReciever.add(monthData[i].time);
            totalReciever.add(monthData[i].seconds);
          }

          firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .collection('data')
              .doc('month data')
              .set({
            "time": timeReciever,
            "draw length": totalReciever,
          });
          /*
          firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .collection('data')
              .doc('week data')
              .get()
              .then((doc) {
            if (doc.exists) {
              firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("data")
                  .doc('week data')
                  .get().then((value) {
                totalReciever = value["draw length"];
                timeReciever = value["date"];
                totalReciever.add(weekData.last.seconds);
                timeReciever.add(weekData.last.time);

                firestoreInstance
                    .collection("users")
                    .doc(firebaseUser.uid)
                    .collection("data")
                    .doc("week data")
                    .set({
                  "date": timeReciever,
                  "draw length": totalReciever,
                });
              });
            } else {
              timeReciever.add(weekData.last.time);
              totalReciever.add(weekData.last.seconds);

              firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("data")
                  .doc("week data")
                  .set({
                "date": timeReciever,
                "draw length": totalReciever,
              });
            }
          });
          */
        }
        /*
        else {
          //proceed to increment down the last x amount of transmissions on the buffer
          while (buffer > 0) {
            firebaseUser = FirebaseAuth.instance.currentUser;

            firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("data")
                .doc('stats')
                .set({
              "draws": drawCount,
              "draw length average": drawLengthAverage,
              "draw length total": drawLengthTotal,
              "draw length average yesterday": drawLengthTotalAverageYest,
            });

            //check if current time exists
            //if time does not exist already add new time and new plot total by pulling array, adding, and pushing new array
            //if time exists, increment plot total

            firestoreInstance
                .collection("groups")
                .where("members", arrayContains: firebaseUser.uid)
                .get().
            then((value) =>
                value.docs.forEach((element) async {
                  //get the last plot time from each group the user is in
                  plotTime = await element
                      .get("plot time")
                      .last;
                  //if the plot time is the same as the current day data time, increment the plot total
                  if (plotTime == dayData[currentIndex].time) {
                    group = await firestoreInstance.collection("groups")
                        .doc(element.id)
                        .get();

                    totalReciever = group["plot total"];
                    timeReciever = group["plot time"];
                    totalReciever.last.increment(dayData[currentIndex].seconds);
                    timeReciever.last.increment(dayData[currentIndex].time);

                    firestoreInstance
                        .collection("groups")
                        .doc(element.id)
                        .set({
                      "plot total": totalReciever,
                      "plot time": timeReciever,
                    });
                    //plot time and total field initialized when group created
                    //if the last plot time is not the same as the current day data time
                    //pull the plot total and plot time, add the new values, and push
                  } else if (plotTime != dayData[currentIndex].time) {
                    group = await firestoreInstance.collection("groups")
                        .doc(element.id)
                        .get();

                    totalReciever = group["plot total"];
                    timeReciever = group["plot time"];
                    totalReciever.add(dayData[currentIndex].seconds);
                    timeReciever.add(dayData[currentIndex].time);

                    firestoreInstance
                        .collection("groups")
                        .doc(element.id)
                        .set({
                      "plot total": totalReciever,
                      "plot time": timeReciever,
                    });
                  }
                }));

            //user data transmission

            firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection('data')
                .doc('day data')
                .get()
                .then((doc) {
              if (doc.exists) {
                firestoreInstance
                    .collection("users")
                    .doc(firebaseUser.uid)
                    .collection("data")
                    .doc('day data')
                    .get().then((value) {
                  timeReciever = value["time"];
                  totalReciever = value["draw length"];
                  timeReciever.add(dayData[currentIndex].time);
                  totalReciever.add(dayData[currentIndex].seconds);

                  firestoreInstance
                      .collection("users")
                      .doc(firebaseUser.uid)
                      .collection("data")
                      .doc('day data')
                      .set({
                    "time": timeReciever,
                    "draw length": totalReciever,
                  });
                });
              } else {
                timeReciever.add(dayData[currentIndex].time);
                totalReciever.add(dayData[currentIndex].seconds);

                firestoreInstance
                    .collection("users")
                    .doc(firebaseUser.uid)
                    .collection("data")
                    .doc('day data')
                    .set({
                  "time": timeReciever,
                  "draw length": totalReciever,
                });
              }
            });
            /*
            firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection('data')
                .doc('week data')
                .get()
                .then((doc) {
              if (doc.exists) {
                firestoreInstance
                    .collection("users")
                    .doc(firebaseUser.uid)
                    .collection("data")
                    .doc('week data')
                    .get().then((value) {
                  totalReciever = value["draw length"];
                  timeReciever = value["date"];
                  totalReciever.add(weekData[currentIndex].seconds);
                  timeReciever.add(weekData[currentIndex].time);

                  firestoreInstance
                      .collection("users")
                      .doc(firebaseUser.uid)
                      .collection("data")
                      .doc("week data")
                      .set({
                    "date": timeReciever,
                    "draw length": totalReciever,
                  });
                });
              } else {
                timeReciever.add(weekData[currentIndex].time);
                totalReciever.add(weekData[currentIndex].seconds);

                firestoreInstance
                    .collection("users")
                    .doc(firebaseUser.uid)
                    .collection("data")
                    .doc("week data")
                    .set({
                  "date": timeReciever,
                  "draw length": totalReciever,
                });
              }
            });
            */
            currentIndex --;
            buffer--;
            print("BUFFER : " + buffer.toString());
          }
        }
        */
      } catch (e) {
        //store data in buffer
        buffer++;
        print("BUFFER [" + buffer.toString() + "]: TRANSMISSION ERROR");
        print(e.toString());
      }
    } else if (connectivityResult == ConnectivityResult.none) {
      //store data in buffer
      buffer++;
      print("BUFFER [" + buffer.toString() + "]: NO CONNECTION");
    }
  }

  void _listener() {
    _ledChar.setNotifyValue(true);
    _ledChar.value.listen((event) async {
      if (_ledChar == null) {
        print('READ VALUE IS NULL');
      } else {
        _readval = await _ledChar.read();
        if (_readval.toString() == _lastval.toString()) {
        } else {
          _copyData();
          _calculateA();
          _checkTime();
          _calculateB();
          counterBlocSink.add(UpdateDataEvent());
          _lastval = _readval;
          _sendData();
          storeData();

          refresh = true;
        }
      }
    });
  }

  bool _getLEDChar(List<BluetoothService> services) {
    print("GETTING SERVICES");
    for (BluetoothService s in services) {
      if (s.uuid.toString() == _transferService) {
        print("SERVICE FOUND: " + s.uuid.toString());
        var characteristics = s.characteristics;
        print("GETTING CHARACTERISTICS");
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == _transferChar) {
            print("CHARACTERISTIC FOUND: " + c.uuid.toString());
            _ledChar = c;
            print("ATTEMPTING LISTENER");
            _listener();
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<bool> _connectDevice(BluetoothDevice device) async {
    print("CONNECTING DEVICE");
    bool _success = false;
    List<BluetoothService> svs;
    flutterBlue.stopScan();
    try {
      await device.disconnect();
      await device.connect();
      print("PAIR PROMPT OPENING");
      print(device.name);
      svs = await device.discoverServices();
      //AWAIT PAIRING FOR 7 SECONDS THEN FAIL
      await Future.delayed(const Duration(seconds: 7));
    } catch (e) {
      print("ERROR: " + e.toString());
      if (e.code != 'already_connected') {
        throw e;
      }
    } finally {
      //_success = true;
      _success = _getLEDChar(svs);
      print(_success);
    }
    if (_success) {
      print("PAIRING");
      connectBlocSink.add(Pair());
      return true;
    } else {
      print("BLE CONNECTION FAILED");
      connectBlocSink.add(Failed());
      return false;
    }
  }

  void scanForDevice() async {
    await flutterBlue.connectedDevices.then((value) async {
      print("CONNECTED DEVICES: " + value.toString());
      if (value.isEmpty) {
        print("NO CONNECTED DEVICES: SCANNING");
        flutterBlue.scanResults.listen((List<ScanResult> results) {
          for (ScanResult result in results) {
            if (result.device.id.toString() == _devKitID) {
              print("CUITT FOUND: " + result.device.toString());
              _connectDevice(result.device);
            }
          }
        });
        flutterBlue.startScan();
      } else {
        for (int i = 0; i < value.length; i++) {
          if (value[i].id.toString() == _devKitID) {
            print("CUITT ALREADY CONNECTED: " + value[i].id.toString());
            var services = await value[i].discoverServices();
            for (BluetoothService s in services) {
              if (s.uuid.toString() == _transferService) {
                var characteristics = s.characteristics;
                for (BluetoothCharacteristic c in characteristics) {
                  if (c.uuid.toString() == _transferChar) {
                    _ledChar = c;
                    print("LISTENER INITIALIZED");
                    //TODO LISTENER CALLING READ CHARACTERISTIC BEFORE LAST COMPLETES, TERMINATING LISTENER
                    _listener();
                  }
                }
              }
            }
            //proceed to dashboard and use current listener
            connectBlocSink.add(Pair());
          } else {
            print("NO CUITT CONNECTED: SCANNING");
            flutterBlue.scanResults.listen((List<ScanResult> results) {
              for (ScanResult result in results) {
                if (result.device.id.toString() == _devKitID) {
                  print("CUITT FOUND: " + result.device.toString());
                  _connectDevice(result.device);
                }
              }
            });
            flutterBlue.startScan();
          }
        }
      }
    });
    await flutterBlue.connectedDevices.then((value) {
      print("CONNECTED DEVICES: " + value.toString());
    });
  }
}