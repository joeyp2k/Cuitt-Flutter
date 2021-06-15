import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/data/datasources/buttons.dart';
import 'package:cuitt/features/groups/domain/usecases/write_group_data.dart';
import 'package:cuitt/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/pages/join_group.dart';
import 'package:cuitt/features/groups/presentation/widgets/action_button.dart';
import 'package:cuitt/features/groups/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/groups/presentation/widgets/group_id_box.dart';
import 'package:cuitt/features/groups/presentation/widgets/text_entry_box.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final firestoreInstance = FirebaseFirestore.instance;
var firebaseUser;

class CreateCasualPage extends StatefulWidget {
  @override
  _CreateCasualPageState createState() => _CreateCasualPageState();
}

class _CreateCasualPageState extends State<CreateCasualPage> {
  final _formKey = GlobalKey<FormState>();
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupBloc>(
      create: (BuildContext context) => GroupBloc(),
      child: BlocConsumer<GroupBloc, GroupsState>(
        listener: (context, state) {
          if (state is Success) {
            await groups();
            Navigator.of(context).pushReplacement(
              FadeRoute(
                enterPage: GroupsList(),
                exitPage: CreateCasualPage(),
              ),
            );
          } else if (state is Fail) {
            _success = false;
          }
        },
        builder: (context, state) {
          groupBlocSink = BlocProvider.of<GroupBloc>(context);
          return Scaffold(
            backgroundColor: Green,
            bottomSheet: Row(
              children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
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
                            exitPage: CreateCasualPage(),
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
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          FadeRoute(
                            enterPage: JoinGroupPage(),
                            exitPage: CreateCasualPage(),
                          ),
                        );
                      },
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
            appBar: AppBar(
              backgroundColor: Green,
              centerTitle: true,
              title: RichText(
                text: TextSpan(style: TileHeader, text: 'Create Casual Group'),
              ),
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
                                    exitPage: CreateCasualPage(),
                                    enterPage: Dashboardb(),
                                  ),
                                      (Route<dynamic> route) => false,
                                );
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
                                Navigator.of(context).push(FadeRoute(
                                  enterPage: SettingsPage(),
                                  exitPage: CreateCasualPage(),
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
            body: SafeArea(
              child: Column(
                children: [
                  GroupIDBox(
                    color: LightBlue,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: spacer.x.xs,
                          child: Column(
                            children: [
                              Padding(
                                padding: spacer.top.sm,
                              ),
                              Form(
                                key: _formKey,
                                child: Padding(
                                  padding: spacer.x.xxl,
                                  child: Column(
                                    children: [
                                      TextEntryBox(
                                        text: "Group Name",
                                        obscureText: false,
                                        color: TransWhitePlus,
                                        textController:
                                        writeGroupData.groupNameController,
                                      ),
                                      Padding(
                                        padding: spacer.y.xs,
                                        child: TextEntryBox(
                                          text: "Group Password",
                                          obscureText: true,
                                          color: TransWhitePlus,
                                          textController: writeGroupData
                                              .groupPasswordController,
                                        ),
                                      ),
                                      TextEntryBox(
                                        text: "Verify Password",
                                        obscureText: true,
                                        color: TransWhitePlus,
                                        textController: writeGroupData
                                            .verifyGroupPasswordController,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ActionButtonBlue(
                                success: _success,
                                paddingStart: spacer.x.xl,
                                paddingEnd: spacer.x.xxl * 2.58,
                                text: "Create Casual Group",
                                function: () async {
                                  print("tap");
                                  groupBlocSink.add(CreateCasualEvent());
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
        },
      ),
    );
  }
}
