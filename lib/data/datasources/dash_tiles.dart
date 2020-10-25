import 'package:cuitt/bloc/dashboard_bloc.dart';

class DashData {
  String header;
  String textData;

  DashData(this.header, this.textData);
}

var drawTile = DashData("Draws", "0");
var seshTile = DashData("Seshes", "0");
var avgDrawTile = DashData("Average Draw Length", "0 seconds");
var avgWaitTile = DashData("Average Wait Period", "0 hrs 0 min 0 secs");
var timeUntilTile = DashData("Time Until Next Draw", "0 hrs 0 min 0 secs");
