import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/presentation/pages/dashboard.dart';
import 'package:cuitt/features/groups/data/datasources/user_chart_data.dart';
import 'package:cuitt/features/groups/data/datasources/user_data.dart';
import 'package:flutter/material.dart';

class OverviewChart extends StatefulWidget {
  @override
  _OverviewChartState createState() => _OverviewChartState();
}

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
    sec[i] += drawLength;
    dayData[i] = UsageData(time[i], sec[i]);
    monthData[i] = UsageData(timeDay[i], sec[i]);
    //monthData using current month, not i
  }

  void _add() {
    i++;
    if (dayData.length <= i) {
      sec.add(drawLength);
      time.add(timeData);
      dayData.add(UsageData(time[i], sec[i]));
      monthData.add(UsageData(timeDay[i], sec[i]));
    } else {
      sec.add(drawLength);
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
      dayData[i] = UsageData(time[i], sec[i]);
      monthData[i] = UsageData(timeDay[i], sec[i]);
    }
  }

  void _transmitData() {
    //TODO: IMPLEMENT TRANSMIT DATA
  }

  @override
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
        _transmitData();
        setState(() {
          refresh = 0;
        });
      }
    });
  }

  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //Stop Timer
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var overviewSeries = [
      new charts.Series(
        id: 'Overview',
        domainFn: (UsageData uData, _) => uData.time,
        measureFn: (UsageData uData, _) => uData.seconds,
        colorFn: (UsageData uData, _) {
          return charts.ColorUtil.fromDartColor(White);
        },
        data: dataSelection,
      ),
    ];

    var overviewChart = new charts.TimeSeriesChart(
      overviewSeries,
      animate: true,
      animationDuration: Duration(milliseconds: 500),
      behaviors: [
        // Add the sliding viewport behavior to have the viewport center on the
        // domain that is currently selected.
        new charts.SlidingViewport(),
        new charts.LinePointHighlighter(
            showHorizontalFollowLine:
                charts.LinePointHighlighterFollowLineType.none,
            showVerticalFollowLine:
                charts.LinePointHighlighterFollowLineType.none),
        // A pan and zoom behavior helps demonstrate the sliding viewport
        // behavior by allowing the data visible in the viewport to be adjusted
        // dynamically.
      ],
      defaultRenderer: new charts.BarRendererConfig<DateTime>(),
      domainAxis: new charts.DateTimeAxisSpec(
          showAxisLine: true,
          tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
              day: new charts.TimeFormatterSpec(
                  format: 'HH', transitionFormat: 'HH')),
          viewport: new charts.DateTimeExtents(
              start: viewportHour.subtract(Duration(hours: 23)),
              end: viewportHour.add(Duration(hours: 1))),
          renderSpec: new charts.NoneRenderSpec()),

      /// Assign a custom style for the measure axis.
      primaryMeasureAxis:
          new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    );

    var overviewChartWidget = Container(
      height: 200,
      child: AbsorbPointer(absorbing: true, child: overviewChart),
    );
    return overviewChartWidget;
  }
}
