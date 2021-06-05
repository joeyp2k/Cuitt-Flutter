import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/core_new/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/data/datasources/dash_tiles.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list_empty.dart';
import 'package:cuitt/features/partner_mode_dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/partner_mode_dashboard/data/datasources/user_data.dart';
import 'package:cuitt/features/partner_mode_dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:cuitt/features/partner_mode_dashboard/presentation/bloc/dashboard_state.dart';
import 'package:cuitt/features/partner_mode_dashboard/presentation/widgets/average_waitperiod_tile.dart';
import 'package:cuitt/features/partner_mode_dashboard/presentation/widgets/dashboard_chart.dart';
import 'package:cuitt/features/partner_mode_dashboard/presentation/widgets/dashboard_tile_large.dart';
import 'package:cuitt/features/partner_mode_dashboard/presentation/widgets/drawer_button.dart';
import 'package:cuitt/features/partner_mode_dashboard/presentation/widgets/draws_tile.dart';
import 'package:cuitt/features/partner_mode_dashboard/presentation/widgets/radial_chart.dart';
import 'package:cuitt/features/partner_mode_dashboard/presentation/widgets/radial_chart_back.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PartnerDashboard extends StatefulWidget {
  @override
  _PartnerDashboardState createState() => _PartnerDashboardState();
}

class _PartnerDashboardState extends State<PartnerDashboard> {
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
