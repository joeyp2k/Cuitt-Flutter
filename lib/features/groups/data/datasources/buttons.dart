import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

class TileButtonData {
  String header;
  IconData icon;
  Color color;

  TileButtonData(this.header, this.icon, this.color);
}

TileButtonData locationTile =
    TileButtonData("Location", Icons.location_on, LightBlue);

TileButtonData profileTile = TileButtonData("Account", Icons.person, DarkBlue);

TileButtonData dashTile =
    TileButtonData("Dashboard", Icons.data_usage_rounded, null);

TileButtonData joinTile = TileButtonData("Join Group", Icons.link, LightBlue);

TileButtonData settingsTile = TileButtonData("Settings", Icons.settings, Red);

TileButtonData adminTile = TileButtonData(
    "Create Administrative Group", Icons.supervisor_account, DarkBlue);

TileButtonData casualTile =
    TileButtonData("Create Casual Group", Icons.people, LightBlue);

TileButtonData groupsTile = TileButtonData("Groups", Icons.list, Green);
