import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:flutter/material.dart';

class BarChart extends StatefulWidget {
  bool update;

  @override
  BarChart(this.update);

  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
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
    monthData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
    //monthData using current month, not i
  }

  void _add() {
    graphIndex++;
    if (dayData.length <= graphIndex) {
      sec.add(drawLength);
      time.add(timeData);
      dayData.add(UsageData(time[graphIndex], sec[graphIndex]));
      monthData.add(UsageData(timeDay[graphIndex], sec[graphIndex]));
    } else {
      sec.add(drawLength);
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
      dayData[graphIndex] = UsageData(time[graphIndex], sec[graphIndex]);
      monthData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
    }
  }

  void _transmitData() {
    //TODO: IMPLEMENT TRANSMIT DATA
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      print(widget.update.toString());
      if (widget.update) {
        _timeUpdate();
        _ifNoData();
        if (timeData == time[graphIndex]) {
          _update();
        } else {
          _add();
        }
        _transmitData();
        setState(() {
          widget.update = false;
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
          return charts.ColorUtil.fromDartColor(Green);
        },
        data: dataSelection,
      ),
    ];

    var dayViewChart = new charts.TimeSeriesChart(
      overviewSeries,
      animate: true,
      animationDuration: Duration(milliseconds: 250),
      behaviors: [
        // Add the sliding viewport behavior to have the viewport center on the
        // domain that is currently selected.
        new charts.SlidingViewport(charts.SelectionModelType.action),
        // A pan and zoom behavior helps demonstrate the sliding viewport
        // behavior by allowing the data visible in the viewport to be adjusted
        // dynamically.
        new charts.PanAndZoomBehavior(),
        new charts.SelectNearest(),
        new charts.DomainHighlighter(),
      ],
      defaultRenderer: new charts.BarRendererConfig<DateTime>(),
      domainAxis: new charts.DateTimeAxisSpec(
          tickProviderSpec: charts.AutoDateTimeTickProviderSpec(),
          viewport: new charts.DateTimeExtents(
              start: viewportSelectionStart, end: viewportSelectionEnd),
          renderSpec: new charts.SmallTickRendererSpec(
              // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
                  fontSize: 12, // size in Pts.
                  color: charts.MaterialPalette.white),

              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(
                  color: charts.MaterialPalette.white))),

      /// Assign a custom style for the measure axis.
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
              new charts.BasicNumericTickProviderSpec(desiredTickCount: 4),
          renderSpec: new charts.GridlineRendererSpec(

              // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
                  fontSize: 16, // size in Pts.
                  color: charts.MaterialPalette.white),

              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(
                  color: charts.MaterialPalette.white))),
    );

    var dayViewChartWidget = Container(
      height: 200,
      child: dayViewChart,
    );
    return dayViewChartWidget;
  }
}
