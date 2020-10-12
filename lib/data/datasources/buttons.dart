import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:flutter/material.dart';

class ButtonData {
  String header;
  IconData icon;
  Color color;

  ButtonData(this.header, this.icon, this.color);
}

var settingsTile = ButtonData("Settings", Icons.settings, Green);
var groupsTile = ButtonData("Groups", Icons.list, Green);
var createTile = ButtonData("New Group", Icons.add, LightBlue);
var joinTile = ButtonData("Join Group", Icons.link, LightBlue);
var adminTile = ButtonData("Create Administrative Group", Icons.add, DarkBlue);
var casualTile = ButtonData("Create Casual Group", Icons.add, DarkBlue);
var continueButton = ButtonData("Continue", null, Green);
var signInButton = ButtonData("Sign In", null, Green);
var createActButton = ButtonData("Create Account", null, Green);
var joinGroupButton = ButtonData("Join Group", null, Green);
