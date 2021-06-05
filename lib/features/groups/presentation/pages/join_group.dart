import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/core/routes/fade.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/presentation/pages/create_group.dart';
import 'package:cuitt/features/groups/presentation/pages/group_list.dart';
import 'package:cuitt/features/groups/presentation/widgets/action_button.dart';
import 'package:cuitt/features/groups/presentation/widgets/text_entry_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

var firebaseUser;

class JoinGroupPage extends StatefulWidget {
  @override
  _JoinGroupPageState createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final TextEditingController _groupIDController = TextEditingController();
  final TextEditingController _groupPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _success = false;

  void _joinGroup() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser);
    firestoreInstance.collection("groups").doc(_groupIDController.text).update({
      "members": FieldValue.arrayUnion([firebaseUser.uid]),
    });
    _success = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Background,
      bottomSheet: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                FadeRoute(
                  enterPage: CreateGroupPage(),
                  exitPage: JoinGroupPage(),
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
            onTap: () {
              Navigator.of(context).pushReplacement(
                FadeRoute(
                  enterPage: GroupsList(),
                  exitPage: JoinGroupPage(),
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
            onTap: () {},
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
      appBar: AppBar(
        backgroundColor: Background,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.data_usage_rounded),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                FadeRoute(
                  exitPage: JoinGroupPage(),
                  enterPage: Dashboardb(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
        title: RichText(
          text: TextSpan(style: TileHeader, text: 'Join Group'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Background,
                child: Center(
                  child: Padding(
                    padding: spacer.x.xs + spacer.top.xxl,
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: spacer.x.xxl,
                            child: Column(
                              children: [
                                TextEntryBox(
                                  text: "Group ID",
                                  obscureText: false,
                                  textController: _groupIDController,
                                ),
                                Padding(
                                  padding: spacer.top.xs,
                                  child: TextEntryBox(
                                    text: "Group Password",
                                    obscureText: true,
                                    textController: _groupPasswordController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ActionButton(
                          paddingStart: spacer.x.xxl * 1.3 + spacer.top.xl,
                          success: _success,
                          text: "Join Group",
                          function: () async {
                            _joinGroup();
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return null;
                            }));
                          },
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
