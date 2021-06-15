import 'dart:async';

import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  _MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

DateTime viewport = DateTime.now();
DateTime viewportVal =
    DateTime(viewport.year, viewport.month, viewport.day, viewport.hour);
DateTimeIntervalType labelInterval = DateTimeIntervalType.hours;

class _MyHomePageState extends State<_MyHomePage> {
  double drawLengthLast = 0.0;
  Timer timer;

  void _timeUpdate() {
    timeData = DateTime.now();

    viewportHour =
        DateTime(timeData.year, timeData.month, timeData.day, timeData.hour)
            .toLocal();
    viewportDay =
        DateTime(timeData.year, timeData.month, timeData.day).toLocal();
    viewportMonth = DateTime(timeData.year, timeData.month).toLocal();

    timeData =
        DateTime(timeData.year, timeData.month, timeData.day, timeData.hour)
            .toLocal();
  }

  void _ifNoData() {
    if (time.isEmpty) {
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
    }

    if (sec.isEmpty) {
      sec.add(0);
    }
  }

  void _update() {
    sec[graphIndex] += drawLength;
    dayData[graphIndex] = UsageData(time[graphIndex], sec[graphIndex]);
    weekData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
    monthData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
    //monthData using current month, not i
  }

  void _add() {
    graphIndex++;
    if (dayData.length <= graphIndex) {
      sec.add(drawLength);
      time.add(timeData);
      dayData.add(UsageData(time[graphIndex], sec[graphIndex]));
      weekData.add(UsageData(timeDay[graphIndex], sec[graphIndex]));
      monthData.add(UsageData(timeDay[graphIndex], sec[graphIndex]));
    } else {
      sec.add(drawLength);
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
      dayData[graphIndex] = UsageData(time[graphIndex], sec[graphIndex]);
      weekData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
      monthData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
    }
    drawLengthLast = drawLength;
  }

  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (drawLength != drawLengthLast) {
        setState(() {});
      }
    });
  }

  void dispose() {
    // TODO: implement dispose
    print("DISPOSING CHART TIMER");
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var overviewData = <ChartSeries<UsageData, DateTime>>[
      ColumnSeries<UsageData, DateTime>(
        dataSource: dataSelection,
        xValueMapper: (UsageData usage, _) => usage.time,
        yValueMapper: (UsageData usage, _) => usage.seconds,
// Enable data label
        dataLabelSettings: DataLabelSettings(isVisible: false),
        pointColorMapper: (UsageData data, _) => Green,
      ),
    ];
    return SfCartesianChart(
      enableAxisAnimation: true,
      primaryXAxis: DateTimeAxis(
        labelStyle: TextStyle(
          color: White,
        ),
        maximumLabels: 5,
        //plotOffset: 20,
        visibleMinimum: viewportSelectionStart,
        visibleMaximum: viewportSelectionEnd,
        majorGridLines: MajorGridLines(width: 0),
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
        dateFormat: dateFormat,
      ),
      // Enable tooltip
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
      ),
      tooltipBehavior: TooltipBehavior(
        opacity: 0,
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          return Container(
              padding: spacer.all.xxs,
              decoration: BoxDecoration(
                color: TransWhite,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: (DateFormat("j").format(data.time).toString()),
                        style: TextStyle(fontSize: 14, color: White),
                      ),
                      textScaleFactor: 1.0,
                    ),
                    RichText(
                      text: TextSpan(
                        text: (data.seconds.toStringAsFixed(1) + 's'),
                        style: TextStyle(fontSize: 14, color: White),
                      ),
                      textScaleFactor: 1.0,
                    ),
                  ]));
        },
      ),
      primaryYAxis: NumericAxis(
        maximumLabels: 3,
        labelStyle: TextStyle(
          color: White,
        ),
        anchorRangeToVisiblePoints: false,
      ),
      series: overviewData,
    );
  }
}
