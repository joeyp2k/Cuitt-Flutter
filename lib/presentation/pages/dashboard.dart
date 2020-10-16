import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:cuitt/presentation/widgets/dmwy_bar.dart';
import 'package:cuitt/presentation/widgets/list_button.dart';
import 'package:cuitt/presentation/widgets/usage_dial.dart';
import 'package:cuitt/presentation/widgets/usage_graph.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final firestoreInstance = Firestore.instance;
var firebaseUser;

class Dashboardb extends StatefulWidget {
  @override
  _DashboardbState createState() => _DashboardbState();
}

class _DashboardbState extends State<Dashboardb> {
  void groups() async {
    int arrayindex = 0;
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    var value = await firestoreInstance
        .collection("groups")
        .where("members", arrayContains: firebaseUser.uid)
        .getDocuments();

    groupNameList.clear();
    groupIDList.clear();
    value.documents.forEach((element) {
      groupNameList.insert(arrayindex, element.data["group name"]);
      groupIDList.insert(arrayindex, element.documentID);
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Background,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: spacer.x.xs,
                child: Column(
                  children: [
                    Padding(
                      padding: spacer.y.xs,
                      child: DMWYBar(),
                    ),
                    Padding(
                      padding: spacer.bottom.xs,
                      child: dayViewChartWidget,
                    ),
                    Row(
                      children: [
                        DashboardTile(
                          header: drawTile.header,
                          data: drawTile.textData,
                        ),
                        Padding(
                          padding: spacer.left.sm,
                        ),
                        DashboardTile(
                          header: seshTile.header,
                          data: drawTile.textData,
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
                      loopChartWidget,
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
                                  text: "Current: 32s",
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
                          textData: avgDrawTile.textData,
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
                                }
                            ),
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
      ),
    );
  }
}
