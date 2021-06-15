import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/data/datasources/buttons.dart';
import 'package:cuitt/features/groups/data/datasources/keys.dart';
import 'package:cuitt/features/groups/domain/usecases/write_group_data.dart';
import 'package:cuitt/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/pages/join_group.dart';
import 'package:cuitt/features/groups/presentation/widgets/action_button.dart';
import 'package:cuitt/features/groups/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/groups/presentation/widgets/group_id_box.dart';
import 'package:cuitt/features/groups/presentation/widgets/text_entry_box.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final firestoreInstance = FirebaseFirestore.instance;
var firebaseUser;

class CreateAdminPage extends StatefulWidget {
  @override
  _CreateAdminPageState createState() => _CreateAdminPageState();
}

class _CreateAdminPageState extends State<CreateAdminPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupPasswordController =
      TextEditingController();
  final TextEditingController _verifyGroupPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _success = false;

  void _createAdminGroup() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser);
    firestoreInstance.collection("groups").doc(randID).set({
      "administrative group": true,
      "group name": _groupNameController.text,
      "group password": _groupPasswordController.text,
      "admins": FieldValue.arrayUnion([firebaseUser.uid]),
      "members": FieldValue.arrayUnion([firebaseUser.uid]),
    });
    _success = true;
  }
  /*
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
  */
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
                exitPage: CreateAdminPage(),
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
            appBar: AppBar(
              backgroundColor: Green,
              centerTitle: true,
              title: RichText(
                text: TextSpan(
                    style: TileHeader, text: 'Create Administrative Group'),
              ),
            ),
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
                            exitPage: CreateAdminPage(),
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
                            exitPage: CreateAdminPage(),
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
                                    exitPage: CreateAdminPage(),
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
                                  exitPage: CreateAdminPage(),
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
                                      textController:
                                          writeGroupData.groupNameController,
                                      color: TransWhitePlus,
                                    ),
                                    Padding(
                                      padding: spacer.y.xs,
                                      child: TextEntryBox(
                                        text: "Group Password",
                                        obscureText: true,
                                        textController:
                                        writeGroupData.groupPasswordController,
                                        color: TransWhitePlus,
                                      ),
                                    ),
                                    TextEntryBox(
                                      text: "Verify Password",
                                      obscureText: true,
                                      textController:
                                      writeGroupData
                                          .verifyGroupPasswordController,
                                      color: TransWhitePlus,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ActionButtonBlue(
                              paddingStart: spacer.x.sm,
                              paddingEnd: spacer.x.xxl * 2.86,
                              success: _success,
                              text: "Create Administrative Group",
                              function: () async {
                                groupBlocSink.add(CreateAdminEvent());
                              },
                            ),
                          ],
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
