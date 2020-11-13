import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/widgets/button.dart';
import 'package:cuitt/presentation/widgets/text_entry_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
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

  void _joinGroup() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser);
    firestoreInstance.collection("groups").doc(_groupIDController.text).update({
      "members": FieldValue.arrayUnion([firebaseUser.uid]),
    });
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
                    text: "Join Group",
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
                        Padding(
                          padding: spacer.x.xxl * 1.3 + spacer.top.xl,
                          child: Button(
                            text: "Join Group",
                            function: () async {
                              _joinGroup();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return null;
                              }));
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
