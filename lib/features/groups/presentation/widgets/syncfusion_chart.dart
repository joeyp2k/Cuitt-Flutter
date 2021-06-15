import 'dart:async';

import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/groups/data/datasources/user_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OverviewChart extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables

  List<UsageData> plots;

  OverviewChart({
    Key key,
    this.plots,
  }) : super(key: key);

  @override
  _OverviewChartState createState() => _OverviewChartState();
}

int refresh = 0;
DateTime viewport = DateTime.now();
DateTime viewportVal =
    DateTime(viewport.year, viewport.month, viewport.day, viewport.hour);
DateTimeIntervalType labelInterval = DateTimeIntervalType.hours;

class _OverviewChartState extends State<OverviewChart> {
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
  }

  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (refresh == 1) {
        _timeUpdate();
        _ifNoData();
        if (timeData == time[graphIndex]) {
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
        dataSource: widget.plots,
        xValueMapper: (UsageData usage, _) => usage.time,
        yValueMapper: (UsageData usage, _) => usage.seconds,
// Enable data label
        dataLabelSettings: DataLabelSettings(isVisible: false),
        pointColorMapper: (UsageData data, _) => DarkBlue,
      ),
    ];
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      primaryXAxis: DateTimeAxis(
        //axisLine: AxisLine(width: 0),
        isVisible: false,
        visibleMinimum: viewportSelectionStart,
        visibleMaximum: viewportSelectionEnd,
        majorGridLines: MajorGridLines(width: 0),
        dateFormat: dateFormat,
      ),
      // Enable tooltip
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: false,
      ),
      primaryYAxis: NumericAxis(
        //axisLine: AxisLine(width: 0),
        isVisible: false,
        anchorRangeToVisiblePoints: false,
      ),
      series: overviewData,
    );
  }
}