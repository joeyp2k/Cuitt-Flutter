import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert/convert.dart';
import 'package:cuitt/bloc/dashboard_bloc.dart';
import 'package:cuitt/data/datasources/my_chart_data.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/pages/dashboard.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectPage extends StatefulWidget {
  ConnectPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {

  @override
  Timer timer;

  var _readval;
  var _lastval;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(hours: 24), (Timer t) {
      //TODO send all current stats before daily reset
      drawLengthTotalAverageYest = drawLengthTotalAverage;
      drawLengthTotal = 0;
      dayNum++;
    });
  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //Stop Timer
    timer?.cancel();
    super.dispose();
    //Close the Stream Sink when the widget is disposed
    counterBlocSink?.close();
    print('close');
  }

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic _ledChar;
  var _myService = "00001523-1212-efde-1523-785feabcd123";
  var _myChar = "00001524-1212-efde-1523-785feabcd123";

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

  void _connectDevice(BluetoothDevice device) async {
    flutterBlue.stopScan();
    try {
      await device.connect();
    } catch (e) {
      if (e.code != 'already_connected') {
        throw e;
      }
    } finally {
      List<BluetoothService> services = await device.discoverServices();
      _getLEDChar(services);
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
    bool result = await DataConnectionChecker().hasConnection;
    if (result == true) {
      if (transmitPointer < i) {
        while (transmitPointer < i) {
          firebaseUser = (await FirebaseAuth.instance.currentUser);

          firestoreInstance.collection("users").doc(firebaseUser.uid)
              .collection("data").doc('stats')
              .set({
            "draws": drawCount,
            "draw length average": drawLengthAverage,
            "draw length total": drawLengthTotal,
            "draw length average yesterday": drawLengthTotalAverageYest,
          });

          firestoreInstance
              .collection("users")
              .doc(firebaseUser.uid)
              .collection('data')
              .doc('day data')
              .get()
              .then((doc) {
            if (doc.exists) {
              firestoreInstance.collection("users").doc(firebaseUser.uid)
                  .collection("data").doc('day data')
                  .set({
                "time": FieldValue.arrayUnion([dayData[transmitPointer].time]),
                "draw length": FieldValue.arrayUnion(
                    [dayData[transmitPointer].seconds]),
              }, SetOptions(merge: true));
            } else {
              firestoreInstance.collection("users").doc(firebaseUser.uid)
                  .collection("data").doc('day data')
                  .set({
                "time": FieldValue.arrayUnion([dayData[transmitPointer].time]),
                "draw length": FieldValue.arrayUnion(
                    [dayData[transmitPointer].seconds]),
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
              firestoreInstance.collection("users").doc(firebaseUser.uid)
                  .collection("data").doc('week data')
                  .set({
                "date": FieldValue.arrayUnion([weekData[transmitPointer].time]),
                "draw length": FieldValue.arrayUnion(
                    [weekData[transmitPointer].seconds]),
              }, SetOptions(merge: true));
            } else {
              firestoreInstance.collection("users").doc(firebaseUser.uid)
                  .collection("data").doc('week data')
                  .set({
                "date": FieldValue.arrayUnion([weekData[transmitPointer].time]),
                "draw length": FieldValue.arrayUnion(
                    [weekData[transmitPointer].seconds]),
              });
            }
          });

          transmitPointer++;
        }
      }
      if (transmitPointer == i) {
        firebaseUser = (await FirebaseAuth.instance.currentUser);

        firestoreInstance.collection("users").doc(firebaseUser.uid).collection(
            "data").doc('stats').set({
          "draws": drawCount,
          "draw length average": drawLengthAverage,
          "draw length total": drawLengthTotal,
          "draw length average yesterday": drawLengthTotalAverageYest,
        });

        firestoreInstance
            .collection("users")
            .doc(firebaseUser.uid)
            .collection('data')
            .doc('day data')
            .get()
            .then((doc) {
          if (doc.exists) {
            firestoreInstance.collection("users").doc(firebaseUser.uid)
                .collection("data").doc('day data')
                .set({
              "time": FieldValue.arrayUnion([dayData[transmitPointer].time]),
              "draw length": FieldValue.arrayUnion(
                  [dayData[transmitPointer].seconds]),
            }, SetOptions(merge: true));
          } else {
            firestoreInstance.collection("users").doc(firebaseUser.uid)
                .collection("data").doc('day data')
                .set({
              "time": FieldValue.arrayUnion([dayData[transmitPointer].time]),
              "draw length": FieldValue.arrayUnion(
                  [dayData[transmitPointer].seconds]),
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
            firestoreInstance.collection("users").doc(firebaseUser.uid)
                .collection("data").doc('week data')
                .set({
              "date": FieldValue.arrayUnion([weekData[transmitPointer].time]),
              "draw length": FieldValue.arrayUnion(
                  [weekData[transmitPointer].seconds]),
            }, SetOptions(merge: true));
          } else {
            firestoreInstance.collection("users").doc(firebaseUser.uid)
                .collection("data").doc('week data')
                .set({
              "date": FieldValue.arrayUnion([weekData[transmitPointer].time]),
              "draw length": FieldValue.arrayUnion(
                  [weekData[transmitPointer].seconds]),
            });
          }
        });
      }
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
          refresh = 1;
        }
      }
    });
  }

  void _scanForDevice() {
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.name == "Cuitt") {
          _connectDevice(result.device);
        }
      }
    });

    flutterBlue.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashBloc>(
      create: (BuildContext context) => DashBloc(),
      child: BlocBuilder<DashBloc, DashBlocState>(
        builder: (context, state) {
          counterBlocSink = BlocProvider.of<DashBloc>(context);
          return Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            backgroundColor: Background,
            body: Container(
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Draws: ${(state as DataState).newDrawCountValue}"),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Green,
              onPressed: () {
                _scanForDevice();
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return Dashboardb(
                        opacityAnimation: animation,
                      );
                    },
                    transitionDuration: Duration(seconds: 1),
                  ),
                );
              },
              tooltip: 'Increment',
              child: Icon(Icons.bluetooth_searching),
            ),
          );
        },
      ),
    );
  }
}