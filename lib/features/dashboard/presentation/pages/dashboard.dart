import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/core/routes/slide.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_bloc.dart';
import 'package:cuitt/features/connect_device/presentation/pages/firmware_update.dart';
import 'package:cuitt/features/dashboard/data/datasources/dash_tiles.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/tile_buttons.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:cuitt/features/dashboard/presentation/pages/drawer.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/average_waitperiod_tile.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/dashboard_chart.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/dashboard_tile_large.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/draws_tile.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/radial_chart.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:cuitt/features/groups/domain/usecases/get_group_data.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list_empty.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
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
  bool update = false;
  bool reEntry = true;

  void _navigate() {
    if (groupIDList.isEmpty) {
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
            Navigator.pop(context);
          } else if (state is DataState) {
            print("UPDATE DATA");
            update = true;
          }
        },
        builder: (context, state) {
          counterBlocSink = BlocProvider.of<DashBloc>(context);
          if (reEntry) {
            counterBlocSink.add(DashReEntryEvent());
            reEntry = false;
          }
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
                                await getGroupData.groups();
                                _navigate();
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
                          ]),
                        ),
                        Padding(
                          padding: spacer.bottom.xs,
                          child: Builder(
                            builder: (BuildContext context) {
                              var firmwareUpdate = true; //received from BLE
                              if (firmwareUpdate) {
                                return Material(
                                  color: LightBlue,
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      Navigator.of(context).push(SlideRoute(
                                        enterPage: FirmwareUpdate(),
                                        exitPage: Dashboardb(),
                                      ));
                                    },
                                    child: Padding(
                                      padding: spacer.y.md,
                                      child: Center(
                                        child: RichText(
                                          text: TextSpan(
                                            text: "Firmware Update Available",
                                            style: TileHeader,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
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
