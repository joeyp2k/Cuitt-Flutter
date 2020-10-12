import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:flutter/material.dart';

class DialData {
  final String type;
  final int seconds;
  final charts.Color color;

  DialData(this.type, this.seconds, Color color)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

var fill = 2;
var over = 0;
var unfilled = 1;

var data = [
  new DialData('Over', over, Red),
  new DialData('Fill', fill, Green),
  new DialData('Unfilled', unfilled, TransWhite),
];

var loopSeries = [
  new charts.Series(
    id: 'Today',
    domainFn: (DialData tData, _) => tData.type,
    measureFn: (DialData tData, _) => tData.seconds,
    colorFn: (DialData tData, _) => tData.color,
    data: data,
  ),
];
