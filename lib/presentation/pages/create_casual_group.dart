import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/data/datasources/buttons.dart';
import 'package:cuitt/data/datasources/keys.dart';
import 'package:cuitt/data/datasources/user.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/pages/group_list.dart';
import 'package:cuitt/presentation/pages/group_list_empty.dart';
import 'package:cuitt/presentation/widgets/animated_button.dart';
import 'package:cuitt/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/presentation/widgets/group_id_box.dart';
import 'package:cuitt/presentation/widgets/text_entry_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final firestoreInstance = FirebaseFirestore.instance;
var firebaseUser;

class CreateCasualPage extends StatefulWidget {
  @override
  _CreateCasualPageState createState() => _CreateCasualPageState();
}

class _CreateCasualPageState extends State<CreateCasualPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupPasswordController =
      TextEditingController();
  final TextEditingController _verifyGroupPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _success = false;

  void _createCasualGroup() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser);
    firestoreInstance.collection("groups").doc(randID).set({
      "administrative group": false,
      "group name": _groupNameController.text,
      "group password": _groupPasswordController.text,
      "admins": firebaseUser.uid,
      "members": FieldValue.arrayUnion([firebaseUser.uid]),
    });
    _success = true;
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Background,
      body: SafeArea(
        child: Column(
          children: [
            DashboardButton(
              color: casualTile.color,
              text: casualTile.header,
              icon: casualTile.icon,
              iconColor: White,
              function: () {
                return null;
              },
            ),
            GroupIDBox(
              color: Green,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  color: Background,
                  child: Center(
                    child: Padding(
                      padding: spacer.x.xs,
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
                                    textController: _groupNameController,
                                  ),
                                  Padding(
                                    padding: spacer.y.xs,
                                    child: TextEntryBox(
                                      text: "Group Password",
                                      obscureText: true,
                                      textController: _groupPasswordController,
                                    ),
                                  ),
                                  TextEntryBox(
                                    text: "Verify Password",
                                    obscureText: true,
                                    textController:
                                    _verifyGroupPasswordController,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedButton(
                            success: _success,
                            paddingStart: spacer.x.xl + spacer.top.xxs,
                            text: "Create Casual Group",
                            function: () async {
                              _createCasualGroup();
                              groups();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
