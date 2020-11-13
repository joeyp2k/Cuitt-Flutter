import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert/convert.dart';
import 'package:cuitt/bloc/dashboard_bloc.dart';
import 'package:cuitt/data/datasources/buttons.dart';
import 'package:cuitt/data/datasources/dash_tiles.dart';
import 'package:cuitt/data/datasources/user.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/pages/create_group.dart';
import 'package:cuitt/presentation/pages/group_list.dart';
import 'package:cuitt/presentation/pages/group_list_empty.dart';
import 'package:cuitt/presentation/pages/join_group.dart';
import 'package:cuitt/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/presentation/widgets/dashboard_tile_large.dart';
import 'package:cuitt/presentation/widgets/dashboard_tile_square.dart';
import 'package:cuitt/presentation/widgets/list_button.dart';
import 'package:cuitt/presentation/widgets/usage_dial.dart';
import 'package:cuitt/presentation/widgets/usage_graph.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final firestoreInstance = FirebaseFirestore.instance;
var firebaseUser;
int refresh = 0;

CounterBloc _counterBlocSink;

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
      //send all current stats before daily reset
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
    _counterBlocSink?.close();
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

  void _listener() {
    _ledChar.setNotifyValue(true);
    _ledChar.value.listen((event) async {
      if (_ledChar == null) {
        print('READ VALUE IS NULL');
      } else {
        _readval = await _ledChar.read();
        if (_readval.toString() == _lastval.toString()) {} else {
          print('READ VALUE A = ' + _readval.toString());
          currentTime = int.parse(hex.encode(_readval.sublist(0, 4)).toString(),
              radix: 16);
          drawLength = int.parse(hex.encode(_readval.sublist(4, 6)).toString(),
              radix: 16) /
              1000;
          drawCount = int.parse(hex.encode(_readval.sublist(6, 8)).toString(),
              radix: 16);
          seshCount = int.parse(hex.encode(_readval.sublist(8, 10)).toString(),
              radix: 16);

          drawLengthTotal += drawLength;
          drawLengthAverage = drawLengthTotal / drawCount;
          drawLengthTotalAverage = drawLengthTotal /
              dayNum; //CHANGE TO CALCULATION ARRAY FOR DLT BY DAY
          drawCountAverage =
              drawCount / dayNum; //CHANGE TO CALCULATION ARRAY FOR DCT BY DAY
          seshCountAverage =
              seshCount / dayNum; //CHANGE TO CALCULATION ARRAY FOR DCT BY DAY
          suggestion = drawLengthTotalAverage / drawCountAverage * decay;

          if (hitTimeNow == null) {
            hitTimeNow = currentTime;
          } else {
            hitTimeThen = hitTimeNow;
            hitTimeNow = currentTime;
          }

          waitPeriod = 16 / seshCountAverage * 60 * 60;
          timeBetween = hitTimeNow - hitTimeThen;
          timeUntilNext = waitPeriod - timeBetween;
          hitLengthArray.add(drawLength);
          timestampArray.add(currentTime);

          _counterBlocSink.add(UpdateDataEvent());

          _lastval = _readval;
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
    return BlocProvider<CounterBloc>(
      create: (BuildContext context) => CounterBloc(),
      child: BlocBuilder<CounterBloc, CounterBlocState>(
        builder: (context, state) {
          _counterBlocSink = BlocProvider.of<CounterBloc>(context);
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
                    MaterialPageRoute(builder: (context) {
                      return Dashboardb();
                    }));
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

class Dashboardb extends StatefulWidget {
  @override
  _DashboardbState createState() => _DashboardbState();
}

class _DashboardbState extends State<Dashboardb> {
  @override
  void groups() async {
    int arrayindex = 0;
    var firebaseUser = await FirebaseAuth.instance.currentUser;
    var value = await firestoreInstance
        .collection("groups")
        .where("members", arrayContains: firebaseUser.uid)
        .get();

    groupNameList.clear();
    groupIDList.clear();
    value.docs.forEach((element) {
      groupNameList.insert(arrayindex, element.get("group name"));
      groupIDList.insert(arrayindex, element.id);
      arrayindex++;
    });
    if (groupNameList.isEmpty) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return GroupListEmpty();
      }));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return GroupsList();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (BuildContext context) => CounterBloc(),
      child: BlocBuilder<CounterBloc, CounterBlocState>(
        builder: (context, state) {
          _counterBlocSink = BlocProvider.of<CounterBloc>(context);
          return Scaffold(
          backgroundColor: Background,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: spacer.x.xs,
                  child: Column(
                    children: [
                      /*
                      Padding(
                        padding: spacer.y.xs,
                        child: Stack(
                          children: [
                            Container(
                              height: gridSpacer * 4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: spacer.left.xxl,
                                    child: Expanded(
                                      child: Container(
                                        color: White,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: LightBlue,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: LightBlue,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: LightBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                        child: Center(
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'D',
                                              style: ButtonRegular,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          padValue = 0;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                        child: Center(
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'M',
                                              style: ButtonRegular,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          padValue = 0;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                        child: Center(
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'W',
                                              style: ButtonRegular,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          padValue = 0;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                        child: Center(
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'Y',
                                              style: ButtonRegular,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          padValue = 0;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: TransWhite,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              height: gridSpacer * 4,
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: spacer.y.xs,
                        child: DMWYBar(),
                      ),

                       */
                      Padding(
                        padding: spacer.bottom.xs,
                        child: BarChart(),
                      ),
                      Row(
                        children: [
                          DashboardTile(
                            header: drawTile.header,
                            data: (state as DataState)
                                .newDrawCountValue
                                .toString(),
                          ),
                          Padding(
                            padding: spacer.left.sm,
                          ),
                          DashboardTile(
                            header: seshTile.header,
                            data: (state as DataState)
                                .newSeshCountValue
                                .toString(),
                          ),
                        ],
                      ),
                      Padding(
                        padding: spacer.top.xs,
                        child: Row(
                          children: [
                            DashboardTileLarge(
                              header: timeUntilTile.header,
                              textData: timeUntilTile.textData,
                            ),
                          ],
                        ),
                      ),
                      Stack(children: [
                        Container(
                          child: DialChart(),
                        ),
                        Center(
                          child: Padding(
                            padding: spacer.top.xxl * 1.5,
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TileHeader,
                                    text: "Week Goal",
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: TileDataLarge,
                                    text: "50s",
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: TileHeader,
                                    text: "Current: " +
                                        (state as DataState)
                                            .newDrawLengthTotalValue
                                            .toString() + 's',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      Row(
                        children: [
                          DashboardTileLarge(
                            header: avgDrawTile.header,
                            textData: (state as DataState)
                                .newAverageDrawLengthValue
                                .toString() +
                                ' seconds',
                          ),
                        ],
                      ),
                      Padding(
                        padding: spacer.y.xs,
                        child: Row(
                          children: [
                            DashboardTileLarge(
                              header: avgWaitTile.header,
                              textData: (state as DataState)
                                  .newAverageWaitPeriodValue
                                  .toString(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: spacer.bottom.xs,
                        child: Row(
                          children: [
                            Expanded(
                              child: DashboardButton(
                                color: createTile.color,
                                text: createTile.header,
                                icon: Icons.add,
                                iconColor: White,
                                function: () async {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                        return CreateGroupPage();
                                      }));
                                },
                              ),
                            ),
                            Padding(
                              padding: spacer.all.xxs,
                            ),
                            Expanded(
                              child: DashboardButton(
                                color: joinTile.color,
                                text: joinTile.header,
                                icon: joinTile.icon,
                                iconColor: White,
                                function: () async {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                        return JoinGroupPage();
                                      }));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListButton(
                        color: TransWhite,
                        text: "List Button",
                      ),
                      Padding(
                        padding: spacer.y.xs,
                        child: Row(
                          children: [
                            Expanded(
                              child: DashboardButton(
                                  color: settingsTile.color,
                                  text: settingsTile.header,
                                  icon: settingsTile.icon,
                                  iconColor: White,
                                  function: () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return null;
                                        }));
                                  }),
                            ),
                            Padding(
                              padding: spacer.left.xs,
                            ),
                            Expanded(
                              child: DashboardButton(
                                color: groupsTile.color,
                                text: groupsTile.header,
                                icon: groupsTile.icon,
                                iconColor: White,
                                function: () {
                                  groups();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}
