import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cuitt/data/datasources/dial_data.dart';
import 'package:flutter/material.dart';

var loopChart = new charts.PieChart(
  loopSeries,
  defaultRenderer: new charts.ArcRendererConfig(arcWidth: 25),
  animate: true,
  animationDuration: Duration(milliseconds: 750),
);

var loopChartWidget = SizedBox(
  height: 300.0,
  child: loopChart,
);
