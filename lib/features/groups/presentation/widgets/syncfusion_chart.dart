import 'dart:async';

import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/data/datasources/user_chart_data.dart';
import 'package:cuitt/features/groups/data/datasources/user_data.dart';
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
    sec[i] += drawLength;
    dayData[i] = UsageData(time[i], sec[i]);
    weekData[i] = UsageData(timeDay[i], sec[i]);
    monthData[i] = UsageData(timeDay[i], sec[i]);
    //monthData using current month, not i
  }

  void _add() {
    i++;
    if (dayData.length <= i) {
      sec.add(drawLength);
      time.add(timeData);
      dayData.add(UsageData(time[i], sec[i]));
      weekData.add(UsageData(timeDay[i], sec[i]));
      monthData.add(UsageData(timeDay[i], sec[i]));
    } else {
      sec.add(drawLength);
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
      dayData[i] = UsageData(time[i], sec[i]);
      weekData[i] = UsageData(timeDay[i], sec[i]);
      monthData[i] = UsageData(timeDay[i], sec[i]);
    }
  }

  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (refresh == 1) {
        _timeUpdate();
        _ifNoData();
        if (timeData == time[i]) {
          _update();
        } else {
          _add();
        }
        setState(() {
          refresh = 0;
        });
      }
    });
  }

  void dispose() {
    // TODO: implement dispose
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
