import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/slide.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/dashboard/data/datasources/group_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/tile_buttons.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/drawer_button.dart';
import 'package:cuitt/features/groups/presentation/pages/create_group.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list_empty.dart';
import 'package:cuitt/features/groups/presentation/pages/join_group.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DrawerPage extends StatefulWidget {
  final Animation<double> transitionAnimation;

  const DrawerPage({Key key, this.transitionAnimation}) : super(key: key);

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
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
    await _getGroupsWithUser();
    await _loadGroupData();

    if (groupNameList.isEmpty) {
      Navigator.of(context).push(SlideRoute(
        enterPage: GroupListEmpty(),
        exitPage: DrawerPage(),
      ));
    } else {
      Navigator.of(context).push(SlideRoute(
        enterPage: GroupsList(),
        exitPage: DrawerPage(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: spacer.y.xxs * 0.45 + spacer.x.xs,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DrawerButton(),
                  IconButton(
                      color: White,
                      icon: Icon(Icons.person),
                      onPressed: () => {}),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: DashboardButton(
                      color: createTile.color,
                      text: createTile.header,
                      icon: Icons.add,
                      iconColor: White,
                      function: () async {
                        Navigator.of(context).push(SlideRoute(
                          enterPage: CreateGroupPage(),
                          exitPage: DrawerPage(),
                        ));
                      },
                    ),
                  ),
                  Expanded(
                    child: DashboardButton(
                      color: joinTile.color,
                      text: joinTile.header,
                      icon: Icons.link,
                      iconColor: White,
                      function: () async {
                        Navigator.of(context).push(SlideRoute(
                          enterPage: JoinGroupPage(),
                          exitPage: DrawerPage(),
                        ));
                      },
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
    );
  }
}
