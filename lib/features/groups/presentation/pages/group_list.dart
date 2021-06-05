import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:cuitt/features/groups/presentation/pages/create_group.dart';
import 'package:cuitt/features/groups/presentation/pages/join_group.dart';
import 'package:flutter/material.dart';

import 'user_list.dart';
import 'user_list_empty.dart';

class GroupsList extends StatefulWidget {
  @override
  _GroupsListState createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  var userNameIndex;
  var value;
  int stack = 0;

  void _getUsers() async {
    userNameIndex = 0;

    var value = await firestoreInstance
        .collection("groups")
        .doc(selection) //selection = group name and should be group ID
        .get()
        .then((value) => userIDList = value.get("members"));

    userNameIndex = userIDList.length;
  }

  void _loadUserData() async {
    userNameList.clear();

    for (int i = 0; i < userNameIndex; i++) {
      value = await firestoreInstance
          .collection("users")
          .doc(userIDList[i])
          .get()
          .then((value) {
        userNameList.insert(i, value.get("username"));
      });
    }
  }

  void groupSelection() async {
    _getUsers();
    _loadUserData();

    if (userNameList.isEmpty) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return UserListEmpty();
      }));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return UserList();
      }));
    }
  }

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
                  exitPage: GroupsList(),
                  enterPage: Dashboardb(),
                ),
                (Route<dynamic> route) => false,
              );
              //push new dashboard and clear rest of stack
            },
          ),
        ],
        title: RichText(
          text: TextSpan(style: TileHeader, text: 'My Groups'),
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: stack,
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: spacer.x.xs,
                    physics: BouncingScrollPhysics(),
                    itemCount: groupNameList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: spacer.top.xs,
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          onTap: () {
                            selection = '${groupIDList[index]}';
                            groupName = '${groupNameList[index]}';
                            groupSelection();
                          },
                          child: Container(
                            padding:
                                spacer.x.xs + spacer.bottom.xxl + spacer.top.xs,
                            decoration: BoxDecoration(
                              color: TransWhite,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: '${groupNameList[index]}',
                                    style: TileHeader,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Column(),
            Column(),
          ],
        ),
      ),
    );
  }
}
