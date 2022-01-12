import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/core/routes/slide.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/data/datasources/buttons.dart';
import 'package:cuitt/features/groups/data/datasources/keys.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/pages/join_group.dart';
import 'package:cuitt/features/groups/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
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
                        color: Green,
                        text: dashTile.header,
                        icon: dashTile.icon,
                        iconColor: White,
                        function: () async {
                          Navigator.of(context).pushAndRemoveUntil(
                              FadeRoute(
                                enterPage: Dashboardb(),
                                exitPage: CreateGroupPage(),
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
                            exitPage: CreateGroupPage(),
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
      backgroundColor: Green,
      appBar: AppBar(
        backgroundColor: Green,
        centerTitle: true,
        title: RichText(
          text: TextSpan(style: TileHeader, text: 'Create Group'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            DashboardButton(
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
                    .push(FadeRoute(
                  exitPage: CreateGroupPage(),
                  enterPage: CreateAdminPage(),
                )
                );
              },
            ),
            DashboardButton(
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
                    .push(FadeRoute(
                  exitPage: CreateGroupPage(),
                  enterPage: CreateCasualPage(),
                )
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: spacer.x.sm * 1.2 + spacer.bottom.xxl * 1.5,
                child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: White,
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30))
                    ),
                    child: Padding(
                      padding: spacer.all.xs,
                      child: RichText(
                        text: TextSpan(
                          style: Description,
                          text: "Administrative groups allow for one or more users to oversee a group of others."
                              "\n"
                              "\n"
                              "Casual groups allow for a group of users to all oversee one another.",
                        ),
                      ),
                    )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
