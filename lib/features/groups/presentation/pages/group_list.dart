import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/core/routes/slide.dart';
import 'package:cuitt/features/dashboard/data/datasources/tile_buttons.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:cuitt/features/groups/domain/usecases/get_group_data.dart';
import 'package:cuitt/features/groups/presentation/pages/create_group.dart';
import 'package:cuitt/features/groups/presentation/pages/join_group.dart';
import 'package:cuitt/features/groups/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/features/groups/presentation/widgets/syncfusion_chart.dart';
import 'package:cuitt/features/settings/presentation/pages/settings_home.dart';
import 'package:flutter/material.dart';

import 'user_list.dart';
import 'user_list_empty.dart';

class GroupsList extends StatefulWidget {
  @override
  _GroupsListState createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Row(
        children: [
          Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    FadeRoute(
                      enterPage: CreateGroupPage(),
                      exitPage: GroupsList(),
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
                      exitPage: GroupsList(),
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
      backgroundColor: LightBlue,
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
                                exitPage: GroupsList(),
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
                            exitPage: GroupsList(),
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
        backgroundColor: LightBlue,
        centerTitle: true,
        title: RichText(
          text: TextSpan(style: TileHeader, text: 'My Groups'),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment(0, 0.60),
                end: Alignment(0, 0.75),
                colors: [Colors.black, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              shrinkWrap: true,
              padding: spacer.x.xs,
              physics: BouncingScrollPhysics(),
              itemCount: groupNameList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: spacer.top.xs,
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    onTap: () async {
                      selection = '${groupIDList[index]}';
                      groupName = '${groupNameList[index]}';
                      //groupSelection();
                      await getGroupData.loadUsersInGroup();
                      if (userNameList.isEmpty) {
                        Navigator.of(context).push(FadeRoute(
                          enterPage: UserListEmpty(),
                          exitPage: GroupsList(),
                        ));
                      } else {
                        Navigator.of(context).push(FadeRoute(
                          enterPage: UserList(),
                          exitPage: GroupsList(),
                        ));
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: TransWhitePlus,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: spacer.x.xs + spacer.top.xs,
                            child: Builder(
                              builder: (BuildContext context) {
                                //TODO index number of users and profile photos to create circles
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: '${groupNameList[index]}',
                                        style: TileData,
                                      ),
                                    ),
                                    Stack(
                                      children: [
                                        Container(
                                          margin: spacer.left.md,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: White,
                                          ),
                                          height: 50,
                                          width: 50,
                                        ),
                                        Container(
                                          margin: spacer.left.md,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: White,
                                          ),
                                          height: 50,
                                          width: 50,
                                        ),
                                        Container(
                                          margin: spacer.left.md * 2,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: White,
                                          ),
                                          height: 50,
                                          width: 50,
                                        ),
                                        Container(
                                          margin: spacer.left.md * 3,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: White,
                                          ),
                                          height: 50,
                                          width: 50,
                                        ),
                                        Container(
                                          margin: spacer.left.md * 4,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: White,
                                          ),
                                          height: 50,
                                          width: 50,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: spacer.top.xxs * 0.75,
                            child: Divider(
                              color: TransWhitePlus,
                              thickness: 1,
                              indent: 15,
                              endIndent: 15,
                            ),
                          ),
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Padding(
                                padding: spacer.bottom.xl * 0.95,
                                child: Builder(
                                  builder: (BuildContext context) {
                                    if (groupPlots[index] == null) {
                                      return Container();
                                    } else {
                                      return Container(
                                        height: 100,
                                        width: double.infinity,
                                        child: OverviewChart(
                                          plots: groupPlots[index],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: groupSecondsChange[index] >= 0
                                        ? Red
                                        : Green,
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(20))),
                                child: Padding(
                                  padding: spacer.all.xs,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'Today\'s Total: ',
                                              style: TileHeader,
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text:
                                                  '${groupSeconds[index].toStringAsFixed(1)}' +
                                                      's',
                                              style: TileHeader,
                                            ),
                                          ),
                                        ],
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: ' (' +
                                              '${groupChangeSymbol[index]}' +
                                              '${groupSecondsChange[index].toStringAsFixed(1)}' +
                                              ')',
                                          style: TileHeader,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
