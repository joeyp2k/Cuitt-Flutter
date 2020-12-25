import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/data/datasources/buttons.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/widgets/animated_button.dart';
import 'package:cuitt/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/presentation/widgets/text_entry_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final firestoreInstance = FirebaseFirestore.instance;
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
      body: SafeArea(
        child: Column(
          children: [
            DashboardButton(
              color: joinTile.color,
              text: joinTile.header,
              icon: Icons.link,
              iconColor: White,
              function: () {
                return null;
              },
            ),
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
                        AnimatedButton(
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
