import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/core/routes/slide.dart';
import 'package:cuitt/features/dashboard/data/datasources/dash_tiles.dart';
import 'package:cuitt/features/dashboard/data/datasources/tile_buttons.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/dashboard/presentation/pages/drawer.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/draws_tile.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:cuitt/features/groups/presentation/widgets/average_waitperiod_tile.dart';
import 'package:cuitt/features/groups/presentation/widgets/dashboard_chart.dart';
import 'package:cuitt/features/groups/presentation/widgets/radial_chart.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

var firebaseUser;

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashBloc>(
      create: (BuildContext context) => DashBloc(),
      child: BlocConsumer<DashBloc, DashBlocState>(
        listener: (context, state) {},
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
                              text: dashTile.header,
                              icon: dashTile.icon,
                              iconColor: White,
                              function: () async {
                                Navigator.of(context).pushAndRemoveUntil(
                                    FadeRoute(
                                      enterPage: Dashboardb(),
                                      exitPage: UserDashboard(),
                                    ),
                                    (route) => false);
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
            backgroundColor: DarkBlue,
            appBar: AppBar(
              backgroundColor: DarkBlue,
              centerTitle: true,
              title: RichText(
                text: TextSpan(style: TileHeader, text: username),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: spacer.x.xs,
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width -
                              gridSpacer * 8,
                          child: Stack(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RadialChart(),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: Radial,
                                      text: "Limit",
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: RadialLarge,
                                      text: userAverageYest[userSelection]
                                              .round()
                                              .toString() +
                                          's',
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: Radial,
                                      text: "Current: " +
                                          userSeconds[userSelection]
                                              .round()
                                              .toString() +
                                          's',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                        DashboardChart(),
                        Row(
                          children: [
                            DrawsTile(
                              color: TransWhite,
                              header: avgDrawTile.header,
                              header2: drawTile.header,
                              textData: (userAverage[userSelection] /
                                          userDraws[userSelection])
                                      .round()
                                      .toString() +
                                  ' seconds',
                              textData2: userDraws[userSelection].toString(),
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
