import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:convert/convert.dart';
import 'package:cuitt/core/design_system/colors.dart';
import 'package:cuitt/features/connect_device/data/datasources/user_data.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_bloc.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_event.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_dial_data.dart';
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

  void _copyData() {
    currentTime =
        int.parse(hex.encode(_readval.sublist(0, 8)).toString(), radix: 16);
    drawLength =
        int.parse(hex.encode(_readval.sublist(8, 9)).toString(), radix: 16) /
            10;
    drawCount++;
    daysPassed =
        int.parse(hex.encode(_readval.sublist(9, 10)).toString(), radix: 16);
  }

  void _calculateA() async {
    if (DateTime.fromMillisecondsSinceEpoch(currentTime * 1000) !=
        DateTime.now()) {
      //calibrate time using calibration characteristic
      var devices = await flutterBlue.connectedDevices;
      for (BluetoothDevice device in devices) {
        if (device.name == "Cuitt") {
          var services = await device.discoverServices();
          for (BluetoothService s in services) {
            if (s.uuid == "") {
              var characteristics = s.characteristics;
              for (BluetoothCharacteristic c in characteristics) {
                if (c.uuid == "") {
                  var newCurrentTime =
                      DateTime.now().toUtc().millisecondsSinceEpoch * 1000;
                  var string = newCurrentTime.toString();
                  var bytes = [];
                  for (int i = 0; i < 10; i += 2) {
                    var insert = string.substring(i, i + 2);
                    bytes.add(insert);
                  }
                  //c.write([bytes[0],bytes[1],bytes[2],bytes[3],bytes[4]]);
                }
              }
            }
          }
        }
      }
    }

    drawLengthTotal += drawLength;

    if (daysPassed > 0) {
      countWindow[daysPassed] += 1;
      totalWindow[daysPassed] += drawLength;
    } else {
      countWindow[0] = drawCount;
      totalWindow[0] = drawLengthTotal;
    }

    var countSum = 0;
    var totalSum = 0.0;
    for (int i = 0; i < countWindow.length; i++) {
      countSum += countWindow[i];
      totalSum += totalWindow[i];
    }

    if (countWindow.length < 14) {
      drawLengthAverage = drawLengthTotal / drawCount;
      drawLengthTotalAverage = drawLengthTotal / countWindow.length;
      drawCountAverage = drawCount / countWindow.length;
    } else {
      drawLengthAverage = totalSum / countSum;
      drawLengthTotalAverage = totalSum / 14;
      drawCountAverage = countSum / 14;
    }

    suggestion = drawLengthTotalAverage / drawCountAverage * decay;
  }

  void _checkTime() {
    // subFromInteger called on null
    if (hitTimeNow == 0) {
      hitTimeNow = currentTime;
      hitTimeThen = hitTimeNow;
    } else {
      hitTimeThen = hitTimeNow;
      hitTimeNow = currentTime;
    }
  }

  void _calculateB() {
    waitPeriod = (16 / drawCountAverage * 60 * 60).round();
    timeBetween = hitTimeNow - hitTimeThen;
    timeUntilNext = waitPeriod - timeBetween;

    if (drawCount > 1) {
      timeBetweenAverage = (timeBetweenAverage + timeBetween) / (drawCount - 1);
      avgWaitTileSecs = timeBetweenAverage.round() % 60;
      avgWaitTileMinutes = (timeBetweenAverage.round() / 60).truncate();
      avgWaitTileHours = (timeBetweenAverage.round() / 3600).truncate();
    } else {
      timeBetweenAverage = 0;
    }
  }

  Future<void> _transmitDraw() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    firebaseUser = FirebaseAuth.instance.currentUser;
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        //set data by time
        var drawTime = DateTime
            .now(); //TODO TEMPORARY FOR TESTING : should be time received from ble
        var drawHour =
            DateTime(drawTime.year, drawTime.month, drawTime.day, drawTime.hour)
                .toLocal();
        var drawDay =
            DateTime(drawTime.year, drawTime.month, drawTime.day).toLocal();
        var drawMonth = DateTime(drawTime.year, drawTime.month).toLocal();
        var hourTotal;
        var dayTotal;
        var monthTotal;

        if (buffer.length == 0) {
          //transmit current draw data
          //set stats
          await firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .update({
            "draws": drawCount,
            "draw length average": drawLengthAverage,
            "draw length average yesterday": drawLengthAverageYest,
            "draw length total": drawLengthTotal,
            "draw length total yesterday": drawLengthTotalYest,
            "draw length total average": drawLengthTotalAverage,
            "draw length total average yesterday": drawLengthTotalAverageYest,
            "time between average": timeBetweenAverage,
          });
          //set or update hour doc
          var hour = await firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .collection("Hour")
              .doc(drawHour.toIso8601String())
              .get();

          if (hour.exists) {
            //if time exists, add current draw length to draw length total field
            hourTotal = hour["draw length total"] + drawLength;
            await firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("Hour")
                .doc(drawHour.toIso8601String())
                .update({
              "draw length total": hourTotal,
            });
          } else {
            //if time doesn't exist in docs, create new doc and fill with draw data
            hourTotal = drawLength;
            await firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("Hour")
                .doc(drawHour.toIso8601String())
                .set({
              "time": drawHour,
              "draw length total": hourTotal,
            });
          }
          //set or update day doc
          var day = await firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .collection("Day")
              .doc(drawDay.toIso8601String())
              .get();
          if (day.exists) {
            //if time exists, add current draw length to draw length total field
            dayTotal = day["draw length total"] + drawLength;
            await firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("Day")
                .doc(drawDay.toIso8601String())
                .update({
              "draw length total": dayTotal,
            });
          } else {
            //if time doesn't exist in docs, create new doc and fill with draw data
            dayTotal = drawLength;
            await firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("Day")
                .doc(drawDay.toIso8601String())
                .set({
              "time": drawDay,
              "draw length total": dayTotal,
            });
          }
          //set or update day doc
          var month = await firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .collection("Month")
              .doc(drawMonth.toIso8601String())
              .get();
          if (month.exists) {
            //if time exists, add current draw length to draw length total field
            monthTotal = month["draw length total"] + drawLength;
            await firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("Month")
                .doc(drawMonth.toIso8601String())
                .update({
              "draw length total": monthTotal,
            });
          } else {
            //if time doesn't exist in docs, create new doc and fill with draw data
            monthTotal = drawLength;
            await firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("Month")
                .doc(drawMonth.toIso8601String())
                .set({
              "time": drawMonth,
              "draw length total": monthTotal,
            });
          }
        } else {
          while (buffer.length > 0) {
            //transmit buffer data
            Map<DateTime, double> data = buffer[0];
            var insertTime = data.entries.first.key;
            var insertHour = DateTime(insertTime.year, insertTime.month,
                insertTime.day, insertTime.hour);
            var insertDay =
                DateTime(insertTime.year, insertTime.month, insertTime.day);
            var insertMonth = DateTime(insertTime.year, insertTime.month);
            var insertDrawLength = data.entries.first.value;
            var hour = await firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("Hour")
                .doc(insertHour.toIso8601String())
                .get();

            if (hour.exists) {
              //if time exists, add current draw length to draw length total field
              hourTotal = hour["draw length total"] + insertDrawLength;
              await firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("Hour")
                  .doc(insertHour.toIso8601String())
                  .update({
                "draw length total": hourTotal,
              });
            } else {
              //if time doesn't exist in docs, create new doc and fill with draw data
              hourTotal = insertDrawLength;
              await firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("Hour")
                  .doc(insertHour.toIso8601String())
                  .set({
                "time": insertHour,
                "draw length total": hourTotal,
              });
            }
            //set or update day doc
            var day = await firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("Day")
                .doc(insertDay.toIso8601String())
                .get();
            if (day.exists) {
              //if time exists, add current draw length to draw length total field
              dayTotal = day["draw length total"] + insertDrawLength;
              await firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("Day")
                  .doc(insertDay.toIso8601String())
                  .update({
                "draw length total": dayTotal,
              });
            } else {
              //if time doesn't exist in docs, create new doc and fill with draw data
              dayTotal = insertDrawLength;
              await firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("Day")
                  .doc(insertDay.toIso8601String())
                  .set({
                "time": insertDay,
                "draw length total": dayTotal,
              });
            }
            //set or update day doc
            var month = await firestoreInstance
                .collection("users")
                .doc(firebaseUser.uid)
                .collection("Month")
                .doc(insertMonth.toIso8601String())
                .get();
            if (month.exists) {
              //if time exists, add current draw length to draw length total field
              monthTotal = month["draw length total"] + insertDrawLength;
              await firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("Month")
                  .doc(insertMonth.toIso8601String())
                  .update({
                "draw length total": monthTotal,
              });
            } else {
              //if time doesn't exist in docs, create new doc and fill with draw data
              monthTotal = insertDrawLength;
              await firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("Month")
                  .doc(insertMonth.toIso8601String())
                  .set({
                "time": insertMonth,
                "draw length total": monthTotal,
              });
            }
            buffer.removeAt(0);
          }
          await firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .update({
            "draws": drawCount,
            "draw length average": drawLengthAverage,
            "draw length average yesterday": drawLengthAverageYest,
            "draw length total": drawLengthTotal,
            "draw length total yesterday": drawLengthTotalYest,
            "draw length total average": drawLengthTotalAverage,
            "draw length total average yesterday": drawLengthTotalAverageYest,
            "time between average": timeBetweenAverage,
          });
        }
        //store draw data locally
        var statInsert = StatInsert(
          userid: firebaseUser.uid,
          drawCount: drawCount,
          drawLengthTotal: drawLengthTotal,
          drawLengthTotalAverage: drawLengthTotalAverage,
          drawLengthTotalAverageYest: drawLengthTotalAverageYest,
          drawLengthTotalYest: drawLengthTotalYest,
          drawLengthAverageYest: drawLengthAverageYest,
          drawLengthAverage: drawLengthAverage,
          timeBetweenAverage: timeBetweenAverage,
        );

        var hourInsert = HourInsert(
          userid: firebaseUser.uid,
          hour: drawHour.toUtc().millisecondsSinceEpoch,
          drawLength: drawLength,
        );
        var dayInsert = DayInsert(
          userid: firebaseUser.uid,
          day: drawDay.toUtc().millisecondsSinceEpoch,
          drawLength: drawLength,
        );
        var monthInsert = MonthInsert(
          userid: firebaseUser.uid,
          month: drawMonth.toUtc().millisecondsSinceEpoch,
          drawLength: drawLength,
        );

        await _storeStatsData(statInsert);
        await _storeHourData(
            drawHour.toUtc().millisecondsSinceEpoch, hourInsert);
        await _storeDayData(drawDay.toUtc().millisecondsSinceEpoch, dayInsert);
        await _storeMonthData(
            drawMonth.toUtc().millisecondsSinceEpoch, monthInsert);
      } catch (e) {
        Map<DateTime, double> drawInsert = {
          DateTime.fromMillisecondsSinceEpoch(currentTime * 1000): drawLength
        };
        buffer.insert(0, drawInsert);
        //TODO Persist buffer in database
      }
    }
  }

  Future<void> _storeStatsData(StatInsert statInsert) async {
    final db = await userDatabase;
    //query for existing user
    List<Map<String, dynamic>> query = await db.query(
      'userstats',
      columns: ['id'],
      where: '"userid" = ?',
      whereArgs: [statInsert.userid],
    );

    if (query.isNotEmpty) {
      //replace user stats
      var id = query[0]["id"];
      print(id);
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
      columns: ['id', 'drawLength'],
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
      columns: ['id', 'drawLength'],
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
      columns: ['id', 'drawLength'],
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

  initializeUserData() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    //initialize dashboard data
    final db = await userDatabase;
    //query for existing local user data
    final List<Map<String, dynamic>> queryStats = await db.query(
      'userstats',
      where: '"userid" = ?',
      whereArgs: [firebaseUser.uid],
    );

    if (queryStats.isNotEmpty) {
      //initialize from local storage
      drawCount = queryStats[0]["count"];
      drawLengthTotal = queryStats[0]["drawLengthTotal"];
      drawLengthTotalYest = queryStats[0]["drawLengthTotalYest"];
      drawLengthTotalAverage = queryStats[0]["drawLengthTotalAverage"];
      drawLengthTotalAverageYest = queryStats[0]["drawLengthTotalAverageYest"];
      drawLengthAverage = queryStats[0]["drawLengthAverage"];
      drawLengthAverageYest = queryStats[0]["drawLengthAverageYest"];
      timeBetweenAverage = queryStats[0]["timeBetweenAverage"];
      fill = drawLengthTotal > drawLengthTotalAverageYest
          ? drawLengthTotalAverageYest
          : drawLengthTotal;
      over = drawLengthTotal < drawLengthTotalAverageYest
          ? 0
          : drawLengthTotal - drawLengthTotalAverageYest;
      data = [
        DialData('Over', over, Red),
        DialData('Fill', fill, Green),
      ];
      //check for more recent remote data
      var stats = await firestoreInstance
          .collection("users")
          .doc(firebaseUser.uid)
          .get();
      if (stats.data().containsKey("draws")) {
        //copy remote storage to local
        var statInsert = StatInsert(
          userid: firebaseUser.uid,
          drawCount: stats["draws"],
          drawLengthAverage: stats["draw length average"],
          drawLengthAverageYest: stats["draw length average yesterday"],
          drawLengthTotal: stats["draw length total"],
          drawLengthTotalYest: stats["draw length total yesterday"],
          drawLengthTotalAverage: stats["draw length total average"],
          drawLengthTotalAverageYest:
              stats["draw length total average yesterday"],
          timeBetweenAverage: stats["time between average"],
        );
        await _storeStatsData(statInsert);
        final List<Map<String, dynamic>> queryStats = await db.query(
          'userstats',
          where: '"userid" = ?',
          whereArgs: [firebaseUser.uid],
        );
        drawCount = queryStats[0]["count"];
        drawLengthTotal = queryStats[0]["drawLengthTotal"];
        drawLengthTotalYest = queryStats[0]["drawLengthTotalYest"];
        drawLengthTotalAverage = queryStats[0]["drawLengthTotalAverage"];
        drawLengthTotalAverageYest =
            queryStats[0]["drawLengthTotalAverageYest"];
        drawLengthAverage = queryStats[0]["drawLengthAverage"];
        drawLengthAverageYest = queryStats[0]["drawLengthAverageYest"];
        timeBetweenAverage = queryStats[0]["timeBetweenAverage"];
      }
    } else {
      //check remote storage
      var data = await firestoreInstance
          .collection("users")
          .doc(firebaseUser.uid)
          .get();
      if (data.data().containsKey("draws")) {
        //copy remote storage to local
        var statInsert = StatInsert(
          userid: firebaseUser.uid,
          drawCount: data["draws"],
          drawLengthAverage: data["draw length average"],
          drawLengthAverageYest: data["draw length average yesterday"],
          drawLengthTotal: data["draw length total"],
          drawLengthTotalYest: data["draw length total yesterday"],
          drawLengthTotalAverage: data["draw length total average"],
          drawLengthTotalAverageYest:
              data["draw length total average yesterday"],
          timeBetweenAverage: data["time between average"],
        );
        await _storeStatsData(statInsert);
      } else {
        //initialize remote and local
        await firestoreInstance
            .collection("users")
            .doc(firebaseUser.uid)
            .update({
          "draws": drawCount,
          "draw length average": drawLengthAverage,
          "draw length average yesterday": drawLengthAverageYest,
          "draw length total": drawLengthTotal,
          "draw length total yesterday": drawLengthTotalYest,
          "draw length total average": drawLengthTotalAverage,
          "draw length total average yesterday": drawLengthTotalAverageYest,
          "time between average": timeBetweenAverage,
        });
        var statInsert = StatInsert(
          userid: firebaseUser.uid,
          drawCount: drawCount,
          drawLengthAverage: drawLengthAverage,
          drawLengthAverageYest: drawLengthTotalAverageYest,
          drawLengthTotal: drawLengthTotal,
          drawLengthTotalYest: drawLengthTotalYest,
          drawLengthTotalAverage: drawLengthTotalAverage,
          drawLengthTotalAverageYest: drawLengthTotalAverageYest,
          timeBetweenAverage: timeBetweenAverage,
        );
        await _storeStatsData(statInsert);
      }
    }

    final List<Map<String, dynamic>> queryHours = await db.query(
      'userhour',
      where: '"userid" = ?',
      whereArgs: [firebaseUser.uid],
    );

    if (queryHours.isNotEmpty) {
      //load user data into group plot
      Map<DateTime, double> hours = {};
      for (int k = 0; k < queryHours.length; k++) {
        if (hours.containsKey(
            DateTime.fromMillisecondsSinceEpoch(queryHours[k]["hour"]))) {
          hours[DateTime.fromMillisecondsSinceEpoch(queryHours[k]["hour"])] +=
              queryHours[k]["drawLength"];
        } else {
          hours[DateTime.fromMillisecondsSinceEpoch(queryHours[k]["hour"])] =
              queryHours[k]["drawLength"];
        }
      }

      //check for more recent remote data
      var lastHour = hours.keys.last;

      DateTime hourCheck = DateTime.now();
      hourCheck = DateTime(
          hourCheck.year, hourCheck.month, hourCheck.day, hourCheck.hour);
      while (hourCheck != lastHour) {
        var hourDoc = await firestoreInstance
            .collection("users")
            .doc(firebaseUser.uid)
            .collection("Hour")
            .doc(hourCheck.toIso8601String())
            .get();
        if (hourDoc.exists) {
          if (hours.containsKey(hourDoc["time"].toDate())) {
            hours[hourDoc["time"].toDate()] += hourDoc["draw length total"];
          } else {
            hours[hourDoc["time"].toDate()] = hourDoc["draw length total"];
          }
        }
        hourCheck = hourCheck.subtract(Duration(hours: 1));
      }

      var start = hours.keys.first;
      var value =
          DateTime(viewport.year, viewport.month, viewport.day, viewport.hour);
      if (hours.keys.length < 12) {
        start = start.subtract(Duration(hours: 11));
      }

      //fill in zeros for spaces between hours
      while (value != start || hours.keys.length < 12) {
        value = value.subtract(Duration(hours: 1));
        if (!hours.containsKey(value)) {
          hours[value] = 0.0;
        }
      }

      hourData.clear();
      hours.entries.forEach((element) {
        var insert = UsageData(element.key, element.value);
        hourData.add(insert);
      });
    } else {
      //check remote storage
      var hourRef = await firestoreInstance
          .collection("users")
          .doc(firebaseUser.uid)
          .collection("Hour")
          .get();
      var hours = hourRef.docs;
      if (hours.isNotEmpty) {
        //copy remote storage to local
        hours.forEach((doc) async {
          var hourInsert = HourInsert(
            userid: firebaseUser.uid,
            drawLength: doc["draw length total"],
            hour: doc["time"].toDate().toUtc().millisecondsSinceEpoch,
          );
          var drawTime = doc["time"].toDate().toUtc().millisecondsSinceEpoch;
          await _storeHourData(drawTime, hourInsert);
        });
      }
    }

    final List<Map<String, dynamic>> queryDays = await db.query(
      'userday',
      where: '"userid" = ?',
      whereArgs: [firebaseUser.uid],
    );

    if (queryDays.isNotEmpty) {
      //load user data into group plot
      Map<DateTime, double> days = {};
      for (int k = 0; k < queryDays.length; k++) {
        if (days.containsKey(
            DateTime.fromMillisecondsSinceEpoch(queryDays[k]["day"]))) {
          days[DateTime.fromMillisecondsSinceEpoch(queryDays[k]["day"])] +=
              queryDays[k]["drawLength"];
        } else {
          days[DateTime.fromMillisecondsSinceEpoch(queryDays[k]["day"])] =
              queryDays[k]["drawLength"];
        }
      }
      //check for more recent remote data

      var lastDay = days.keys.last;

      DateTime dayCheck = DateTime.now();
      dayCheck = DateTime(dayCheck.year, dayCheck.month, dayCheck.day);
      while (dayCheck != lastDay) {
        var dayDoc = await firestoreInstance
            .collection("users")
            .doc(firebaseUser.uid)
            .collection("Hour")
            .doc(dayCheck.toIso8601String())
            .get();
        if (dayDoc.exists) {
          if (days.containsKey(dayDoc["time"].toDate())) {
            days[dayDoc["time"].toDate()] += dayDoc["draw length total"];
          } else {
            days[dayDoc["time"].toDate()] = dayDoc["draw length total"];
          }
        }
        dayCheck = dayCheck.subtract(Duration(days: 1));
      }

      var start = days.keys.last;
      var value = DateTime(viewport.year, viewport.month, viewport.day);
      if (days.keys.length < 30) {
        start = start.subtract(Duration(days: 29));
      }
      //fill in zeros for spaces between days
      while (value != start || days.keys.length < 30) {
        value = value.subtract(Duration(days: 1));
        if (!days.containsKey(value)) {
          days[value] = 0.0;
        }
      }

      //initialize from local storage
      dayData.clear();
      days.entries.forEach((element) {
        var insert = UsageData(element.key, element.value);
        dayData.add(insert);
      });
    } else {
      //check remote storage
      var daysRef = await firestoreInstance
          .collection("users")
          .doc(firebaseUser.uid)
          .collection("Day")
          .get();
      var days = daysRef.docs;
      if (days.isNotEmpty) {
        //copy remote storage to local
        days.forEach((doc) async {
          var dayInsert = DayInsert(
            userid: firebaseUser.uid,
            drawLength: doc["draw length total"],
            day: doc["time"].toDate().toUtc().millisecondsSinceEpoch,
          );
          var drawTime = doc["time"].toDate().toUtc().millisecondsSinceEpoch;
          await _storeDayData(drawTime, dayInsert);
        });
      }
    }

    final List<Map<String, dynamic>> queryMonths = await db.query(
      'usermonth',
      where: '"userid" = ?',
      whereArgs: [firebaseUser.uid],
    );

    if (queryMonths.isNotEmpty) {
      //load user data into group plot
      Map<DateTime, double> months = {};
      for (int k = 0; k < queryMonths.length; k++) {
        if (months.containsKey(
            DateTime.fromMillisecondsSinceEpoch(queryMonths[k]["month"]))) {
          months[DateTime.fromMillisecondsSinceEpoch(
              queryMonths[k]["month"])] += queryMonths[k]["drawLength"];
        } else {
          months[DateTime.fromMillisecondsSinceEpoch(queryMonths[k]["month"])] =
              queryMonths[k]["drawLength"];
        }
      }

      //check for more recent remote data
      var lastMonth = months.keys.last;

      DateTime monthCheck = DateTime.now();
      monthCheck = DateTime(monthCheck.year, monthCheck.month);
      while (monthCheck != lastMonth) {
        var monthDoc = await firestoreInstance
            .collection("users")
            .doc(firebaseUser.uid)
            .collection("Hour")
            .doc(monthCheck.toIso8601String())
            .get();
        if (monthDoc.exists) {
          if (months.containsKey(monthDoc["time"].toDate())) {
            months[monthDoc["time"].toDate()] += monthDoc["draw length total"];
          } else {
            months[monthDoc["time"].toDate()] = monthDoc["draw length total"];
          }
        }
        monthCheck = DateTime(monthCheck.year, monthCheck.month - 1);
      }

      var start = months.keys.last;
      var value = DateTime(viewport.year, viewport.month);
      if (months.keys.length < 30) {
        start = DateTime(start.year, start.month - 11);
      }
      //fill in zeros for spaces between hours
      while (value != start || months.keys.length < 12) {
        value = DateTime(value.year, value.month - 1);
        if (!months.containsKey(value)) {
          months[value] = 0.0;
        }
      }

      monthData.clear();
      months.entries.forEach((element) {
        var insert = UsageData(element.key, element.value);
        monthData.add(insert);
      });
    } else {
      //check remote storage
      var monthsRef = await firestoreInstance
          .collection("users")
          .doc(firebaseUser.uid)
          .collection("Month")
          .get();
      var months = monthsRef.docs;
      if (months.isNotEmpty) {
        //copy remote storage to local
        months.forEach((doc) async {
          var monthInsert = MonthInsert(
            userid: firebaseUser.uid,
            drawLength: doc["draw length total"],
            month: doc["time"].toDate().toUtc().millisecondsSinceEpoch,
          );
          var drawTime = doc["time"].toDate().toUtc().millisecondsSinceEpoch;
          await _storeMonthData(drawTime, monthInsert);
        });
      }
    }
  }

  void _listener() {
    _ledChar.setNotifyValue(true);
    _ledChar.value.listen((event) async {
      if (_ledChar == null) {
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
          await _transmitDraw();

          refresh = true;
        }
      }
    });
  }

  bool _getLEDChar(List<BluetoothService> services) {
    for (BluetoothService s in services) {
      if (s.uuid.toString() == _transferService) {
        var characteristics = s.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == _transferChar) {
            _ledChar = c;
            _listener();
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<bool> _connectDevice(BluetoothDevice device) async {
    bool _success = false;
    List<BluetoothService> svs;
    flutterBlue.stopScan();
    try {
      await device.disconnect();
      await device.connect();

      svs = await device.discoverServices();
      //AWAIT PAIRING FOR 7 SECONDS THEN FAIL
      await Future.delayed(const Duration(seconds: 7));
    } catch (e) {
      if (e.code != 'already_connected') {
        throw e;
      }
    } finally {
      //_success = true;
      _success = _getLEDChar(svs);
    }
    if (_success) {
      connectBlocSink.add(Pair());
      return true;
    } else {
      connectBlocSink.add(Failed());
      return false;
    }
  }

  void scanForDevice() async {
    await flutterBlue.connectedDevices.then((value) async {
      if (value.isEmpty) {
        flutterBlue.scanResults.listen((List<ScanResult> results) {
          for (ScanResult result in results) {
            if (result.device.id.toString() == _devKitID) {
              _connectDevice(result.device);
            }
          }
        });
        flutterBlue.startScan();
      } else {
        for (int i = 0; i < value.length; i++) {
          if (value[i].id.toString() == _devKitID) {
            var services = await value[i].discoverServices();
            for (BluetoothService s in services) {
              if (s.uuid.toString() == _transferService) {
                var characteristics = s.characteristics;
                for (BluetoothCharacteristic c in characteristics) {
                  if (c.uuid.toString() == _transferChar) {
                    _ledChar = c;
                    //TODO LISTENER CALLING READ CHARACTERISTIC BEFORE LAST COMPLETES, TERMINATING LISTENER
                    _listener();
                  }
                }
              }
            }
            //proceed to dashboard and use current listener
            connectBlocSink.add(Pair());
          } else {
            flutterBlue.scanResults.listen((List<ScanResult> results) {
              for (ScanResult result in results) {
                if (result.device.id.toString() == _devKitID) {
                  _connectDevice(result.device);
                }
              }
            });
            flutterBlue.startScan();
          }
        }
      }
    });
    await flutterBlue.connectedDevices.then((value) {});
  }
}