import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';

int daynum = 1;

class DialData {
  final String type;
  final double seconds;
  final Color color;

  DialData(this.type, this.seconds, this.color);
}

double fill = 0;
double over = 0;
double unfilled = 1;

var data = [
  new DialData('Over', over, Red),
  new DialData('Fill', fill, Green),
];
