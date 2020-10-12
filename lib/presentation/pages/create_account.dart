import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/widgets/button.dart';
import 'package:cuitt/presentation/widgets/text_entry_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  final snackBar = SnackBar(content: Text('Passwords do not match'));

  final firestoreInstance = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var firebaseUser;

  bool _success;
  String _userEmail;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _verifyController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final appState = Provider.of<AppState>(context, listen: false);
    void _register() async {
      var groupList = [];
      final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      if (user != null) {
        firebaseUser = (await FirebaseAuth.instance.currentUser());
        firestoreInstance
            .collection("users")
            .document(firebaseUser.uid)
            .setData({
          "username": _usernameController.text,
          "email": _emailController.text,
          "first name": _firstNameController.text,
          "last name": _lastNameController.text,
          "groups": groupList,
        });
        _success = true;
        _userEmail = user.email;
        //appState.partnerIndex = 4;
        //appState.update();
      } else {
        _success = false;
      }
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Background,
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: spacer.x.xxl,
                        child: Column(
                          children: [
                            Padding(
                              padding: spacer.bottom.xs + spacer.top.xxl,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextEntryBox(
                                      text: "First Name",
                                      obscureText: false,
                                      textController: _firstNameController,
                                    ),
                                  ),
                                  Padding(
                                    padding: spacer.all.xxs,
                                  ),
                                  Expanded(
                                    child: TextEntryBox(
                                      text: "Last Name",
                                      obscureText: false,
                                      textController: _lastNameController,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextEntryBox(
                              text: "Username",
                              obscureText: false,
                              textController: _usernameController,
                            ),
                            Padding(
                              padding: spacer.y.xs,
                              child: TextEntryBox(
                                text: "Email",
                                obscureText: false,
                                textController: _emailController,
                              ),
                            ),
                            TextEntryBox(
                              text: "Password",
                              obscureText: true,
                              textController: _passwordController,
                            ),
                            Padding(
                              padding: spacer.y.xs,
                              child: TextEntryBox(
                                obscureText: true,
                                text: "Verify Password",
                                textController: _verifyController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: spacer.x.xxl * 1.5 + spacer.y.xs,
                  child: Button(
                    text: "Create Account",
                    function: _register,
                  ),
                ),
                Padding(
                  padding: spacer.x.xl,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: primaryList,
                          text: "Already have an account?",
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {},
                        child: Container(
                          margin: spacer.all.xs,
                          child: RichText(
                            text: TextSpan(
                              style: primaryListGreen,
                              text: "Sign in",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
