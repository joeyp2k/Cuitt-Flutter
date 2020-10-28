import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class UsageData {
  final DateTime time;
  final int seconds;

  UsageData(this.time, this.seconds);
}

var time = [];
var sec = [];
var i = 0;

DateTime viewport = DateTime.now();
DateTime timeData;
DateTime viewportVal =
    DateTime(viewport.year, viewport.month, viewport.day, viewport.hour)
        .toLocal();

var overviewData = [
  //try with n incrementing by 1 instead of 2+.  Multiple y values per bar is why bars aren't loading
  UsageData(viewportVal, 0),
  UsageData(viewportVal.add(Duration(hours: 1)), 0),
  UsageData(viewportVal.add(Duration(hours: 2)), 0),
  UsageData(viewportVal.add(Duration(hours: 3)), 0),
  UsageData(viewportVal.add(Duration(hours: 4)), 0),
  UsageData(viewportVal.add(Duration(hours: 5)), 0),
  UsageData(viewportVal.add(Duration(hours: 6)), 0),
  UsageData(viewportVal.add(Duration(hours: 7)), 0),
  UsageData(viewportVal.add(Duration(hours: 8)), 0),
  UsageData(viewportVal.add(Duration(hours: 9)), 0),
  UsageData(viewportVal.add(Duration(hours: 10)), 0),
  UsageData(viewportVal.add(Duration(hours: 11)), 0),
];

var overviewSeries = [
  new charts.Series(
    id: 'Overview',
    domainFn: (UsageData uData, _) => uData.time,
    measureFn: (UsageData uData, _) => uData.seconds,
    // ignore: top_level_function_literal_block
    colorFn: (UsageData uData, _) {
      return charts.ColorUtil.fromDartColor(Colors.greenAccent);
    },
    data: overviewData,
  ),
];
