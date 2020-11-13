import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/data/datasources/keys.dart';
import 'package:cuitt/data/datasources/user.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/pages/group_list.dart';
import 'package:cuitt/presentation/pages/group_list_empty.dart';
import 'package:cuitt/presentation/widgets/button.dart';
import 'package:cuitt/presentation/widgets/group_id_box.dart';
import 'package:cuitt/presentation/widgets/text_entry_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final firestoreInstance = Firestore.instance;
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

  void _createCasualGroup() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser);
    firestoreInstance.collection("groups").doc(randID).set({
      "administrative group": false,
      "group name": _groupNameController.text,
      "group password": _groupPasswordController.text,
      "admins": firebaseUser.uid,
      "members": FieldValue.arrayUnion([firebaseUser.uid]),
    });
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
      backgroundColor: LightBlue,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.maxFinite,
              height: gridSpacer * 15,
              color: LightBlue,
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: spacer.x.sm + spacer.bottom.xs,
                child: RichText(
                  text: TextSpan(
                    text: "Create Casual Group",
                    style: TileData,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Background,
                child: Center(
                  child: Padding(
                    padding: spacer.x.xs,
                    child: Column(
                      children: [
                        Padding(
                          padding: spacer.top.sm + spacer.bottom.md,
                          child: GroupIDBox(),
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
                        Padding(
                          padding: spacer.x.xl + spacer.top.lg,
                          child: Button(
                            text: "Create Casual Group",
                            function: () async {
                              _createCasualGroup();
                              groups();
                            },
                          ),
                        ),
                      ],
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
