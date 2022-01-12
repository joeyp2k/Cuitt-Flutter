import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/core/routes/slide.dart';
import 'package:cuitt/features/dashboard/data/datasources/tile_buttons.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/domain/usecases/get_group_data.dart';
import 'package:cuitt/features/groups/domain/usecases/write_group_data.dart';
import 'package:cuitt/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:cuitt/features/groups/presentation/pages/create_group.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/widgets/action_button.dart';
import 'package:cuitt/features/groups/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/groups/presentation/widgets/text_entry_box.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

var firebaseUser;

class JoinGroupPage extends StatefulWidget {
  @override
  _JoinGroupPageState createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupBloc>(
      create: (BuildContext context) => GroupBloc(),
      child: BlocConsumer<GroupBloc, GroupsState>(
          listener: (context, state) async {
        if (state is Success) {
          await getGroupData.groups();
          Navigator.of(context).pushReplacement(
            FadeRoute(
              enterPage: GroupsList(),
              exitPage: JoinGroupPage(),
            ),
          );
        } else if (state is Fail) {
          _success = false;
        }
      }, builder: (context, state) {
        groupBlocSink = BlocProvider.of<GroupBloc>(context);
        return Scaffold(
          backgroundColor: DarkBlue,
          bottomSheet: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    FadeRoute(
                      enterPage: CreateGroupPage(),
                      exitPage: JoinGroupPage(),
                    ),
                  );
                },
                child: Container(
                  color: Green,
                  height: gridSpacer * 7.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: White,
                      ),
                      RichText(
                        text: TextSpan(style: DWMY, text: 'Create'),
                      ),
                    ],
                  ),
                ),
              )),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    FadeRoute(
                      enterPage: GroupsList(),
                      exitPage: JoinGroupPage(),
                    ),
                  );
                },
                child: Container(
                  color: LightBlue,
                  height: gridSpacer * 7.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list,
                        color: White,
                      ),
                      RichText(
                        text: TextSpan(style: DWMY, text: 'Groups'),
                      ),
                    ],
                  ),
                ),
              )),
              Expanded(
                  child: GestureDetector(
                onTap: () {},
                child: Container(
                  color: DarkBlue,
                  height: gridSpacer * 7.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link,
                        color: White,
                      ),
                      RichText(
                        text: TextSpan(style: DWMY, text: 'Join'),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
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
                            color: Green,
                            text: dashTile.header,
                            icon: dashTile.icon,
                            iconColor: White,
                            function: () async {
                              Navigator.of(context).pushAndRemoveUntil(
                                  FadeRoute(
                                    enterPage: Dashboardb(),
                                    exitPage: JoinGroupPage(),
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
                                exitPage: JoinGroupPage(),
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
          appBar: AppBar(
            backgroundColor: DarkBlue,
            centerTitle: true,
            title: RichText(
              text: TextSpan(style: TileHeader, text: 'Join Group'),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    child: Center(
                      child: Padding(
                        padding: spacer.x.xs + spacer.top.xxl,
                        child: Column(
                          children: [
                            Form(
                              key: _formKey,
                              child: Padding(
                                padding: spacer.x.xxl,
                                child: Column(
                                  children: [
                                    TextEntryBox(
                                      text: "Group ID",
                                      obscureText: false,
                                      color: TransWhite,
                                      textController:
                                          writeGroupData.groupIDController,
                                    ),
                                    Padding(
                                      padding: spacer.top.xs,
                                      child: TextEntryBox(
                                        text: "Group Password",
                                        obscureText: true,
                                        color: TransWhite,
                                        textController: writeGroupData
                                            .groupPasswordController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ActionButton(
                              paddingStart: spacer.x.xxl * 1.3 + spacer.top.xl,
                              success: _success,
                              text: "Join Group",
                              function: () {
                                groupBlocSink.add(JoinEvent());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
