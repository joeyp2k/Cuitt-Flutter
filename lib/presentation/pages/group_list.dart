import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/data/datasources/user.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/pages/user_list.dart';
import 'package:cuitt/presentation/pages/user_list_empty.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final firestoreInstance = Firestore.instance;
var firebaseUser;

class GroupsList extends StatefulWidget {
  @override
  _GroupsListState createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  void groupSelection() async {
    var usernameindex = 0;
    var value = await firestoreInstance
        .collection("groups")
        .document(selection) //selection = group name and should be group ID
        .get()
        .then((value) => userIDList = value.data["members"]);
    usernameindex = userIDList.length;
    userNameList.clear();
    for (int i = 0; i < usernameindex; i++) {
      value = await firestoreInstance
          .collection("users")
          .document(userIDList[i])
          .get()
          .then((value) {
        userNameList.insert(i, value.data["username"]);
      });
    }
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
        child: ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          padding: spacer.x.xs,
          itemCount: groupNameList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: spacer.y.xxs,
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                onTap: () {
                  selection = '${groupIDList[index]}';
                  groupName = '${groupNameList[index]}';
                  groupSelection();
                },
                child: Container(
                  padding: spacer.x.xs,
                  decoration: BoxDecoration(
                    color: TransWhite,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  height: gridSpacer * 5,
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '${groupNameList[index]}',
                          style: primaryList,
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
    );
  }
}
