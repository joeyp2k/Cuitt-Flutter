import 'package:connectivity/connectivity.dart';
import 'package:convert/convert.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_bloc.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_event.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectBLE {
  bool refresh = false;
  bool firstTransmit = true;
  var _readval;
  var _lastval;

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic _ledChar;
  var _myService = "00001523-1212-efde-1523-785feabcd123";
  var _myChar = "00001524-1212-efde-1523-785feabcd123";

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
    print('Draw Length Total (CALC A) pre calculation: ' +
        drawLengthTotal.toString());
    drawLengthTotal += drawLength;
    print('Draw Length Total (CALC A): ' + drawLengthTotal.toString());
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
    DateTime plotTime;
    var group;
    var timeReciever = [];
    var totalReciever = [];
    int currentIndex = dayData.length - 1;
    var connectivityResult = await (Connectivity().checkConnectivity());
    print("ATTEMPTING TRANSMISSION");
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
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

          //check if current time exists
          //if time does not exist already add new time and new plot total by pulling array, adding, and pushing new array
          //if time exists, increment plot total

          await firestoreInstance
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
                print(plotTime);
                print(dayData.last.time)
                if (plotTime == dayData.last.time) {
                  print("INCREMENTING");
                  group = await firestoreInstance.collection("groups")
                      .doc(element.id)
                      .get();

                  totalReciever = group["plot total"];
                  timeReciever = group["plot time"];
                  totalReciever.last.increment(dayData.last.seconds);
                  timeReciever.last.increment(dayData.last.time);

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
                } else if (plotTime != dayData.last.time) {
                  print("ADDING");
                  group = await firestoreInstance.collection("groups")
                      .doc(element.id)
                      .get();

                  totalReciever = group["plot total"];
                  timeReciever = group["plot time"];
                  totalReciever.add(dayData.last.seconds);
                  timeReciever.add(dayData.last.time);

                  firestoreInstance
                      .collection("groups")
                      .doc(element.id)
                      .set({
                    "plot total": totalReciever,
                    "plot time": timeReciever,
                  });
                }
              }));

          firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .collection('data')
              .doc('day data')
              .get()
              .then((value) {
            timeReciever = value["time"];
            totalReciever = value["draw length"];

            //TODO Fix first 12 dayData entries not being inserted into group chart and user chart

            print(timeReciever);
            print(totalReciever);
            timeReciever.add(dayData.last.time);
            totalReciever.add(dayData.last.seconds);
            print(timeReciever);
            print(totalReciever);
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
          );

          /*
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
                timeReciever.add(dayData.last.time);
                totalReciever.add(dayData.last.seconds);

                firestoreInstance
                    .collection("users")
                    .doc(firebaseUser.uid)
                    .collection("data")
                    .doc('day data')
                    .set({
                  "time" : timeReciever,
                  "draw length" : totalReciever,
                });
              });
            } else {
              timeReciever.add(dayData.last.time);
              totalReciever.add(dayData.last.seconds);

              firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("data")
                  .doc('day data')
                  .set({
                "time" : timeReciever,
                "draw length" : totalReciever,
              });
            }
          });
          */

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
        } else {
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
            currentIndex --;
            buffer--;
            print("BUFFER : " + buffer.toString());
          }
        }
      } catch (e) {
        //store data in buffer
        buffer++;
        print("BUFFER : " + buffer.toString() + "TRANSMISSION ERROR");
      }
    } else if (connectivityResult == ConnectivityResult.none) {
      //store data in buffer
      buffer++;
      print("BUFFER : " + buffer.toString() + "NO CONNECTION");
    }
  }

  void _listener() {
    //LISTENER RUNNING TWICE PER CHANGE
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
          refresh = true;
        }
      }
    });
  }

  bool _getLEDChar(List<BluetoothService> services) {
    for (BluetoothService s in services) {
      if (s.uuid.toString() == _myService) {
        var characteristics = s.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == _myChar) {
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
    bool _success;
    flutterBlue.stopScan();
    try {
      await device.connect();
    } catch (e) {
      if (e.code != 'already_connected') {
        throw e;
      }
    } finally {
      List<BluetoothService> services = await device.discoverServices();
      _success = _getLEDChar(services);
    }
    if (_success) {
      connectBlocSink.add(Pair());
      return true;
    } else {
      connectBlocSink.add(Failed());
      return false;
    }
  }

  void scanForDevice() {
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.name == "Cuitt") {
          //disconnect to any device already connected when you attempt a new connection
          result.device.disconnect();
          _connectDevice(result.device);
        }
      }
    });
    flutterBlue.startScan();
  }
}
