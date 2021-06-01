import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class ButtonData {
  String header;
  Color color;

  ButtonData(this.header, this.color);
}

ButtonData joinGroupButton = ButtonData("Join Group", Green);

ButtonData createAdminButton = ButtonData("Join Group", Green);

ButtonData createCasualButton = ButtonData("Join Group", Green);
