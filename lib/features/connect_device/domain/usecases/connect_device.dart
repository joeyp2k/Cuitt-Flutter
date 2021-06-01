import 'package:connectivity/connectivity.dart';
import 'package:convert/convert.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_bloc.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_event.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectBLE {
  bool refresh = false;
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
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      try {
        if (transmitPointer < i) {
          while (transmitPointer < i) {
            firebaseUser = (await FirebaseAuth.instance.currentUser);

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
                    .set({
                  "time":
                      FieldValue.arrayUnion([dayData[transmitPointer].time]),
                  "draw length":
                      FieldValue.arrayUnion([dayData[transmitPointer].seconds]),
                }, SetOptions(merge: true));
              } else {
                firestoreInstance
                    .collection("users")
                    .doc(firebaseUser.uid)
                    .collection("data")
                    .doc('day data')
                    .set({
                  "time":
                      FieldValue.arrayUnion([dayData[transmitPointer].time]),
                  "draw length":
                      FieldValue.arrayUnion([dayData[transmitPointer].seconds]),
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
                    .set({
                  "date":
                      FieldValue.arrayUnion([monthData[transmitPointer].time]),
                  "draw length": FieldValue.arrayUnion(
                      [monthData[transmitPointer].seconds]),
                }, SetOptions(merge: true));
              } else {
                firestoreInstance
                    .collection("users")
                    .doc(firebaseUser.uid)
                    .collection("data")
                    .doc('week data')
                    .set({
                  "date":
                      FieldValue.arrayUnion([monthData[transmitPointer].time]),
                  "draw length": FieldValue.arrayUnion(
                      [monthData[transmitPointer].seconds]),
                });
              }
            });

            transmitPointer++;
          }
        }
        if (transmitPointer == i) {
          firebaseUser = (await FirebaseAuth.instance.currentUser);

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
                  .set({
                "time": FieldValue.arrayUnion([dayData[transmitPointer].time]),
                "draw length":
                    FieldValue.arrayUnion([dayData[transmitPointer].seconds]),
              }, SetOptions(merge: true));
            } else {
              firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("data")
                  .doc('day data')
                  .set({
                "time": FieldValue.arrayUnion([dayData[transmitPointer].time]),
                "draw length":
                    FieldValue.arrayUnion([dayData[transmitPointer].seconds]),
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
                  .set({
                "date":
                    FieldValue.arrayUnion([monthData[transmitPointer].time]),
                "draw length":
                    FieldValue.arrayUnion([monthData[transmitPointer].seconds]),
              }, SetOptions(merge: true));
            } else {
              firestoreInstance
                  .collection("users")
                  .doc(firebaseUser.uid)
                  .collection("data")
                  .doc('week data')
                  .set({
                "date":
                    FieldValue.arrayUnion([monthData[transmitPointer].time]),
                "draw length":
                    FieldValue.arrayUnion([monthData[transmitPointer].seconds]),
              });
            }
          });
        }
      } catch (e) {
        //store data in buffer
      }
    } else if (connectivityResult == ConnectivityResult.none) {}
    //store data in buffer
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
