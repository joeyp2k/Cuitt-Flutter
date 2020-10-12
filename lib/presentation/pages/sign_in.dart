import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/widgets/button.dart';
import 'package:cuitt/presentation/widgets/text_entry_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  final snackBar = SnackBar(content: Text('Passwords do not match'));

  final firestoreInstance = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var firebaseUser;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  bool _success;
  String _userEmail;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //final appState = Provider.of<AppState>(context, listen: false);
    void _signInWithEmailAndPassword() async {
      final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      if (user != null) {
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
                Padding(
                  padding: spacer.x.xxl + spacer.top.xxl,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextEntryBox(
                          text: "Email",
                          obscureText: false,
                          textController: _emailController,
                        ),
                        Padding(
                          padding: spacer.top.xs,
                          child: TextEntryBox(
                            text: "Password",
                            obscureText: true,
                            textController: _passwordController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: spacer.x.xxl * 1.5 + spacer.y.xs,
                  child: Button(
                    text: "Sign In",
                    function: _signInWithEmailAndPassword,
                  ),
                ),
                Padding(
                  padding: spacer.x.md,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: primaryList,
                          text: "Don't have an account?",
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
                              text: "Create Account",
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
