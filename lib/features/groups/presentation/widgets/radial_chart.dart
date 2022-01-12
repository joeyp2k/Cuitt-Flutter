import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:cuitt/features/groups/data/datasources/user_dial_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RadialChart extends StatefulWidget {
  @override
  _RadialChartState createState() => _RadialChartState();
}

class _RadialChartState extends State<RadialChart> {
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SfCircularChart(series: <CircularSeries>[
        RadialBarSeries<DialData, String>(
          dataSource: data,
          pointColorMapper: (DialData data, _) => data.color,
          xValueMapper: (DialData data, _) => data.type,
          yValueMapper: (DialData data, _) => data.seconds,
          cornerStyle: CornerStyle.bothCurve,
          innerRadius: '70%',
          radius: '100%',
          gap: '10%',
          trackColor: White,
          trackOpacity: 0.15,
          opacity: 1,
          maximumValue: userAverageYest[userSelection].toDouble(),
        ),
      ]),
    );
  }
}

/*
import 'dart:async';

import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/groups/data/datasources/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class AnimatedRadialChart extends StatefulWidget {
  @override
  _AnimatedRadialChartState createState() => new _AnimatedRadialChartState();
}

class _AnimatedRadialChartState extends State<AnimatedRadialChart> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  final _chartSize = const Size(325.0, 325.0);

  Timer timer;

  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        List<CircularStackEntry> data = _generateChartData(usage);
        _chartKey.currentState.updateData(data);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  List<CircularStackEntry> _generateChartData(double usage) {
    Color dialColor = Green;

    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            usage,
            dialColor,
          )
        ],
      ),
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            overUsage,
            Red,
          )
        ],
      ),
    ];

    if (usage > 100) {
      overUsage = usage - 100;
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
            initialChartData: _generateChartData(usage),
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
