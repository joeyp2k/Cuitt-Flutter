import 'dart:async';

import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/core/routes/slide.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/dashboard/data/datasources/dash_tiles.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/tile_buttons.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:cuitt/features/dashboard/presentation/pages/drawer.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/average_waitperiod_tile.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/dashboard_chart.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/dashboard_tile_large.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/draws_tile.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/radial_chart.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list_empty.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Dashboardb extends StatefulWidget {
  final Animation<double> opacityAnimation;

  const Dashboardb({Key key, this.opacityAnimation}) : super(key: key);

  @override
  _DashboardbState createState() => _DashboardbState();
}

class _DashboardbState extends State<Dashboardb> {
  @override
  int arrayIndex;
  var value;
  bool update = false;

  Future<void> _getGroupsWithUser() async {
    arrayIndex = 0;

    var firebaseUser = FirebaseAuth.instance.currentUser;

    value = await firestoreInstance
        .collection("groups")
        .where("members", arrayContains: firebaseUser.uid)
        .get();
    print(value);
  }

  Future<void> _loadGroupData() async {
    groupNameList.clear();
    groupIDList.clear();

    value.docs.forEach((element) {
      groupNameList.insert(arrayIndex, element.get("group name"));
      groupIDList.insert(arrayIndex, element.id);
      arrayIndex++;
    });
    print(groupNameList);
  }

  void groups() async {
    await _getGroupsWithUser();
    await _loadGroupData();
    if (groupNameList.isEmpty) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return GroupListEmpty();
      }));
    } else {
      print("Navigating");
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return GroupsList();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashBloc>(
      create: (BuildContext context) => DashBloc(),
      child: BlocConsumer<DashBloc, DashBlocState>(
        listener: (context, state) {
          if (state is DrawerOpen) {
            Navigator.push(
              context,
              FadeRoute(
                exitPage: Dashboardb(),
                enterPage: BlocProvider.value(
                  value: BlocProvider.of<DashBloc>(context),
                  child: DrawerPage(),
                ),
              ),
            );
          } else if (state is DrawerClosed) {
            Navigator.pop;
          } else if (state is DataState) {
            print("UPDATE DATA");
            update = true;
          }
        },
        builder: (context, state) {
          counterBlocSink = BlocProvider.of<DashBloc>(context);
          return Scaffold(
            drawer: SafeArea(
              child: Drawer(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: DashboardButton(
                              color: profileTile.color,
                              text: profileTile.header,
                              icon: profileTile.icon,
                              iconColor: White,
                              function: () async {},
                            ),
                          ),
                          Expanded(
                            child: DashboardButton(
                              color: locationTile.color,
                              text: locationTile.header,
                              icon: locationTile.icon,
                              iconColor: White,
                              function: () async {},
                            ),
                          ),
                          Expanded(
                            child: DashboardButton(
                              color: groupsTile.color,
                              text: groupsTile.header,
                              icon: Icons.list,
                              iconColor: White,
                              function: () async {
                                groups();
                              },
                            ),
                          ),
                          Expanded(
                            child: DashboardButton(
                              color: settingsTile.color,
                              text: settingsTile.header,
                              icon: Icons.settings,
                              iconColor: White,
                              function: () async {
                                Navigator.of(context).push(SlideRoute(
                                  enterPage: SettingsPage(),
                                  exitPage: DrawerPage(),
                                ));
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
            backgroundColor: Background,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                print('Draw Count: ' + drawCount.toString());
                print('Draw Length: ' + drawLength.toString());
                print('Draw Length Total: ' + drawLengthTotal.toString());
                print('Draw Length Average: ' + drawLengthAverage.toString());
                print(viewportSelectionStart.toString());
                print(viewportSelectionEnd.toString());
                timeData = timeData.add(Duration(hours: 1));
              },
            ),
            appBar: AppBar(
              backgroundColor: Background,
              centerTitle: true,
              title: RichText(
                text: TextSpan(style: TileHeader, text: 'Today\'s Activity'),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: spacer.x.xs,
                    child: Column(
                      children: [
                        Stack(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RadialChart(),
                            ],
                          ),
                          Padding(
                            padding: spacer.y.xxl * 1.8,
                            child: Center(
                              child: Column(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: Radial,
                                      text: "Goal",
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: RadialLarge,
                                      text: (state as DataState)
                                              .newAverageDrawLengthTotalYestValue
                                              .toString() +
                                          's',
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: Radial,
                                      text: "Current: " +
                                          (state as DataState)
                                              .newDrawLengthTotalValue
                                              .toString() +
                                          's',
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
                              header: timeUntilTile.header,
                              textData: timeUntilTile.textData,
                              color: Red,
                              timeUntilNext: timeUntilNext,
                            ),
                          ],
                        ),
                        DashboardChart(),
                        Row(
                          children: [
                            DrawsTile(
                              color: TransWhite,
                              header: avgDrawTile.header,
                              header2: drawTile.header,
                              textData: (state as DataState)
                                      .newAverageDrawLengthValue
                                      .toString() +
                                  ' seconds',
                              textData2: (state as DataState)
                                  .newDrawCountValue
                                  .toString(),
                            ),
                          ],
                        ),
                        Padding(
                          padding: spacer.y.xs,
                          child: Row(
                            children: [
                              AverageTimeBetweenTile(
                                header: avgWaitTile.header,
                                textData: avgWaitTile.textData,
                                color: TransWhite,
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
