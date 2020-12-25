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

class CreateAdminPage extends StatefulWidget {
  @override
  _CreateAdminPageState createState() => _CreateAdminPageState();
}

class _CreateAdminPageState extends State<CreateAdminPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupPasswordController =
      TextEditingController();
  final TextEditingController _verifyGroupPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _success = false;

  void _createAdminGroup() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser);
    firestoreInstance.collection("groups").doc(randID).set({
      "administrative group": true,
      "group name": _groupNameController.text,
      "group password": _groupPasswordController.text,
      "admins": FieldValue.arrayUnion([firebaseUser.uid]),
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
              color: adminTile.color,
              text: adminTile.header,
              icon: adminTile.icon,
              iconColor: White,
              function: () {
                return null;
              },
            ),
            GroupIDBox(
              color: LightBlue,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
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
                        paddingStart: spacer.x.sm + spacer.top.xxs,
                        success: _success,
                        text: "Create Administrative Group",
                        function: () async {
                          _createAdminGroup();
                          groups();
                        },
                      ),
                    ],
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
