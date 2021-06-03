/*
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class RadialChartBack extends StatelessWidget {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  final _chartSize = const Size(325.0, 325.0);
  final fill = 200.0;

  List<CircularStackEntry> _generateChartData(double fill) {
    Color dialColor = TransGreen;

    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            fill,
            dialColor,
          )
        ],
      ),
    ];

    if (fill > 100) {
      data.add(new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            fill - 100,
            TransRed,
          ),
        ],
      ));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          child: new AnimatedCircularChart(
            key: _chartKey,
            size: _chartSize,
            duration: Duration(seconds: 0),
            initialChartData: _generateChartData(fill),
            chartType: CircularChartType.Radial,
            edgeStyle: SegmentEdgeStyle.round,
            percentageValues: true,
            holeRadius: 75,
          ),
        ),
      ],
    );
  }
}
*/
