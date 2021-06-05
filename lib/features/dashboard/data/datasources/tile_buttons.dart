import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class TileButtonData {
  String header;
  IconData icon;
  Color color;

  TileButtonData(this.header, this.icon, this.color);
}

class ButtonData {
  String header;
  Color color;

  ButtonData(this.header, this.color);
}

//DashTiles
TileButtonData settingsTile = TileButtonData("Settings", Icons.settings, Red);

TileButtonData groupsTile = TileButtonData("Groups", Icons.list, Green);

TileButtonData createTile = TileButtonData("New Group", Icons.add, DarkBlue);

TileButtonData locationTile =
    TileButtonData("Location", Icons.location_on, LightBlue);

TileButtonData profileTile = TileButtonData("Account", Icons.person, DarkBlue);

TileButtonData joinTile = TileButtonData("Join Group", Icons.link, LightBlue);

TileButtonData adminTile = TileButtonData(
    "Create Administrative Group", Icons.supervisor_account, DarkBlue);

TileButtonData casualTile =
    TileButtonData("Create Casual Group", Icons.people, LightBlue);

//Action Buttons
ButtonData continueButton = ButtonData("Continue", Green);

ButtonData signInButton = ButtonData("Sign In", Green);

ButtonData createActButton = ButtonData("Create Account", Green);

ButtonData joinGroupButton = ButtonData("Join Group", Green);
