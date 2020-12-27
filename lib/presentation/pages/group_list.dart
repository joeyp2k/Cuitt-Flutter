import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/data/datasources/buttons.dart';
import 'package:cuitt/data/datasources/user.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/pages/user_list.dart';
import 'package:cuitt/presentation/pages/user_list_empty.dart';
import 'package:cuitt/presentation/widgets/dashboard_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final firestoreInstance = FirebaseFirestore.instance;
var firebaseUser;

class GroupsList extends StatefulWidget {
  @override
  _GroupsListState createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  var userNameIndex;
  var value;

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
    await _getUsers();
    await _loadUserData();

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
      backgroundColor: Background,
      body: SafeArea(
        child: Column(
          children: [
            DashboardButton(
              color: groupsTile.color,
              text: groupsTile.header,
              icon: groupsTile.icon,
              iconColor: White,
              function: () {
                return null;
              },
            ),
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
                          borderRadius: BorderRadius.all(Radius.circular(10)),
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
      ),
    );
  }
}
