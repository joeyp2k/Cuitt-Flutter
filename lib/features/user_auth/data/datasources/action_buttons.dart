import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class ButtonData {
  String header;
  Color color;

  ButtonData(this.header, this.color);
}

ButtonData signInButton = ButtonData("Sign In", Green);

ButtonData createActButton = ButtonData("Create Account", Green);
