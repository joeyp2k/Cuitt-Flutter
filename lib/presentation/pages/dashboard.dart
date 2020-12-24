import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:cuitt/presentation/widgets/dashboard_chart.dart';
import 'package:cuitt/presentation/widgets/dashboard_tile_large.dart';
import 'package:cuitt/presentation/widgets/drawer_button.dart';
import 'package:cuitt/presentation/widgets/draws_tile.dart';
import 'package:cuitt/presentation/widgets/list_button.dart';
import 'package:cuitt/presentation/widgets/radial_chart.dart';
import 'package:cuitt/presentation/widgets/radial_chart_back.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final firestoreInstance = FirebaseFirestore.instance;
var firebaseUser;
int refresh = 0;

class Dashboardb extends StatefulWidget {
  @override
  _DashboardbState createState() => _DashboardbState();
}

class _DashboardbState extends State<Dashboardb> {
  @override
  int arrayIndex;
  var value;

  void _getGroupsWithUser() async {
    arrayIndex = 0;

    var firebaseUser = await FirebaseAuth.instance.currentUser;
    value = await firestoreInstance
        .collection("groups")
        .where("members", arrayContains: firebaseUser.uid)
        .get();
  }

  void _loadGroupData() {
    groupNameList.clear();
    groupIDList.clear();

    value.docs.forEach((element) {
      groupNameList.insert(arrayIndex, element.get("group name"));
      groupIDList.insert(arrayIndex, element.id);
      arrayIndex++;
    });
  }

  void groups() async {
    _getGroupsWithUser();
    _loadGroupData();

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
    return BlocProvider<DashBloc>(
      create: (BuildContext context) => DashBloc(),
      child: BlocBuilder<DashBloc, DashBlocState>(
        builder: (context, state) {
          counterBlocSink = BlocProvider.of<DashBloc>(context);
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: White,
              onPressed: () {
                print(drawLengthTotal.toString());
                usage += 10;
              },
            ),
            backgroundColor: Background,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: spacer.x.xs,
                    child: Column(
                      children: [
                        Padding(
                          padding: spacer.left.xxs * 1.25 + spacer.top.xxs,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DrawerButton(),
                              RichText(
                                text: TextSpan(
                                    style: TileHeader, text: 'My Activity'),
                              ),
                              IconButton(
                                  color: White,
                                  icon: Icon(Icons.person),
                                  onPressed: () => {}),
                            ],
                          ),
                        ),
                        Stack(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedRadialChart(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RadialChartBack(),
                            ],
                          ),
                          Center(
                            child: Padding(
                              padding: spacer.y.xxl * 2,
                              child: Column(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: Radial,
                                      text: "Week Goal",
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
                              header: timeUntilTile.header,
                              textData: timeUntilTile.textData,
                              color: Red,
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
                              DashboardTileLarge(
                                header: avgWaitTile.header,
                                textData: avgWaitTile.textData,
                                color: TransWhite,
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
                          text: "Recent Group",
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
