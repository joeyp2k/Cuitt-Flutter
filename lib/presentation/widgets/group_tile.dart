import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/data/datasources/user.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/pages/user_list.dart';
import 'package:cuitt/presentation/pages/user_list_empty.dart';
import 'package:flutter/material.dart';

final firestoreInstance = FirebaseFirestore.instance;
var firebaseUser;

class GroupTile extends StatefulWidget {
  int index;

  GroupTile({
    Key key,
    this.index,
  }) : super(key: key);

  @override
  _GroupTileState createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
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
    return Container(
      margin: spacer.top.xs,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        onTap: () {
          selection = '${groupIDList[widget.index]}';
          groupName = '${groupNameList[widget.index]}';
          groupSelection();
        },
        child: Container(
          padding: spacer.x.xs + spacer.bottom.xxl + spacer.top.xs,
          decoration: BoxDecoration(
            color: TransWhite,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                  text: '${groupNameList[widget.index]}',
                  style: TileHeader,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
