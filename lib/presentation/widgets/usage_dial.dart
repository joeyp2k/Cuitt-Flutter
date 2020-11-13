import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cuitt/data/datasources/dial_data.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/bloc/dashboard_bloc.dart';

class DialChart extends StatefulWidget {
  @override
  _DialChartState createState() => _DialChartState();
}

class _DialChartState extends State<DialChart> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      print('Draw Length Total: ' + drawLengthTotal.toString());
      //if it is the first day recorded, start with no fill and full unfilled
      if (daynum == 1) {
        //increase fill
        fill = drawLengthTotal;
        if (fill > 0) {
          over = 0;
          unfilled = 0;
        } else {
          over = 0;
          unfilled = 1;
        } //if today's total is larger or equal to yesterday's average
      } else if (drawLengthTotal >= drawLengthTotalAverageYest) {
        //stop increasing fill
        //if today's total is larger than yesterday's average, start increasing over
        if (drawLengthTotal > drawLengthTotalAverageYest) {
          over = drawLengthTotal - drawLengthTotalAverageYest;
        }
      } else {
        //increase fill
        over = 0;
        fill = drawLengthTotal;
        //if yesterday's average is larger than today's total, unfilled = 0.  Otherwise, start decreasing over.
        if (drawLengthTotalAverageYest <= drawLengthTotal) {
          unfilled = 0;
        } else {
          unfilled = drawLengthTotalAverageYest.round() - drawLengthTotal;
        }
      }

      print('Fill: ' + fill.toString());
      print('Unfilled: ' + unfilled.toString());
      print('Over: ' + over.toString());
      setState(() {
        data = [
          DialData('Over', over, Red),
          DialData('Fill', fill, Green),
          DialData('Unfilled', unfilled, TransWhite),
        ];
      });
    });
  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //Stop Timer
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var loopSeries = [
      new charts.Series(
        id: 'Today',
        domainFn: (DialData tData, _) => tData.type,
        measureFn: (DialData tData, _) => tData.seconds,
        colorFn: (DialData tData, _) => tData.color,
        data: data,
      ),
    ];

    var loopChart = new charts.PieChart(
      loopSeries,
      defaultRenderer: new charts.ArcRendererConfig(arcWidth: 25),
      animate: false,
      behaviors: [],
      animationDuration: Duration(milliseconds: 750),
    );

    var loopChartWidget = SizedBox(
      height: 300.0,
      child: loopChart,
    );
    return loopChartWidget;
  }
}
