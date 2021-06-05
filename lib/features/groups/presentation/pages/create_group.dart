import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/data/datasources/buttons.dart';
import 'package:cuitt/features/groups/data/datasources/keys.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/pages/join_group.dart';
import 'package:cuitt/features/groups/presentation/widgets/dashboard_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'create_admin_group.dart';
import 'create_casual_group.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomSheet: Row(
          children: [
            Expanded(
                child: GestureDetector(
              onTap: () {},
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
                    exitPage: CreateGroupPage(),
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
                    exitPage: CreateGroupPage(),
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
        backgroundColor: Background,
        appBar: AppBar(
          backgroundColor: Background,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.data_usage_rounded),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  FadeRoute(
                    exitPage: CreateGroupPage(),
                    enterPage: Dashboardb(),
                  ),
                  (Route<dynamic> route) => false,
                );
                //push new dashboard and clear rest of stack
              },
            ),
          ],
          title: RichText(
            text: TextSpan(style: TileHeader, text: 'Create Group'),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: DashboardButton(
                  color: adminTile.color,
                  text: adminTile.header,
                  icon: adminTile.icon,
                  iconColor: White,
                  function: () async {
                    randID = secureRandom.nextString(
                        length: 5,
                        charset:
                            '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return CreateAdminPage();
                    }));
                  },
                ),
              ),
              Expanded(
                child: DashboardButton(
                  color: casualTile.color,
                  text: casualTile.header,
                  iconColor: White,
                  icon: casualTile.icon,
                  function: () {
                    randID = secureRandom.nextString(
                        length: 5,
                        charset:
                            '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return CreateCasualPage();
                    }));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
