import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuth {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController verifyController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  String _userEmail;

  //CreateAccount

  Future<bool> register() async {
    print("REGISTERING");
    bool _success = false;
    var groupList = [];
    try {
      final User user = (await auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      ))
          .user;
      print(user);
      if (user == null) {
        return _success;
      } else {
        firebaseUser = (await FirebaseAuth.instance.currentUser);
        firestoreInstance.collection("users").doc(firebaseUser.uid).set({
          "username": usernameController.text,
          "email": emailController.text,
          "first name": firstNameController.text,
          "last name": lastNameController.text,
          "groups": groupList,
        });
        _userEmail = user.email;
        return _success = true;
        //TODO: if device already connected, route to dashboard
      }
    } on FirebaseAuthException {
      return _success;
    }
  }

  //SignIn
  Future<bool> signInWithEmailAndPassword() async {
    bool _success = false;
    try {
      final User user = (await auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      ))
          .user;
      if (user == null) {
        return _success;
      } else {
        _userEmail = user.email;
        return _success = true;
        //TODO: if device already connected, route to dashboard
      }
    } on FirebaseAuthException {
      return _success = false;
    }
  }

  //Failed
  UserAuth();
}

UserAuth userAuth = UserAuth();
