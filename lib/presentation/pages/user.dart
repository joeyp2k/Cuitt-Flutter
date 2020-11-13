import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/data/datasources/dash_tiles.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/widgets/dashboard_tile_large.dart';
import 'package:cuitt/presentation/widgets/dashboard_tile_square.dart';
import 'package:cuitt/presentation/widgets/dmwy_bar.dart';
import 'package:cuitt/presentation/widgets/usage_dial.dart';
import 'package:cuitt/presentation/widgets/usage_graph.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final firestoreInstance = Firestore.instance;
var firebaseUser;

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: BarChart(),
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
                    DialChart(),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
