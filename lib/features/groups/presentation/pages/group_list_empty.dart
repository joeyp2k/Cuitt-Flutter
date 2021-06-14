import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/data/datasources/buttons.dart';
import 'package:cuitt/features/groups/presentation/pages/create_group.dart';
import 'package:cuitt/features/groups/presentation/pages/join_group.dart';
import 'package:cuitt/features/groups/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
import 'package:flutter/material.dart';

class GroupListEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightBlue,
      appBar: AppBar(
        backgroundColor: LightBlue,
        centerTitle: true,
        title: RichText(
          text: TextSpan(style: TileHeader, text: 'My Groups'),
        ),
      ),
      bottomSheet: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                FadeRoute(
                  enterPage: CreateGroupPage(),
                  exitPage: GroupListEmpty(),
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
            onTap: () {},
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
                  exitPage: GroupListEmpty(),
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
                              exitPage: GroupListEmpty(),
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
                            exitPage: GroupListEmpty(),
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: spacer.x.sm * 1.2 + spacer.bottom.xxl * 1.5,
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: White,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(30))),
                  child: Padding(
                    padding: spacer.all.xs,
                    child: RichText(
                      text: TextSpan(
                        style: Description,
                        text:
                            "Administrative groups allow for one or more users to oversee a group of others."
                            "\n"
                            "\n"
                            "Casual groups allow for a group of users to all oversee one another.",
                      ),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
