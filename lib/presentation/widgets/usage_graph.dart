import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cuitt/bloc/dashboard_bloc.dart';
import 'package:cuitt/data/datasources/my_chart_data.dart';
import 'package:cuitt/presentation/pages/dashboard.dart';
import 'package:flutter/material.dart';

class BarChart extends StatefulWidget {
  @override
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
      timeDay.add(DateTime(timeData.year, timeData.month, timeData.day)
          .toLocal());
    }

    if (sec.isEmpty) {
      sec.add(0);
    }
  }

  void _update() {
    sec[i] += drawLength;
    dayData[i] = UsageData(time[i], sec[i]);
    weekData[i] = UsageData(timeDay[i], sec[i]);
    //monthData using current month, not i
  }

  void _add() {
    i++;
    if (dayData.length <= i) {
      sec.add(drawLength);
      time.add(timeData);
      dayData.add(UsageData(time[i], sec[i]));
      weekData.add(UsageData(timeDay[i], sec[i]));
    } else {
      sec.add(drawLength);
      time.add(timeData);
      timeDay.add(DateTime(timeData.year, timeData.month, timeData.day)
          .toLocal());
      dayData[i] = UsageData(time[i], sec[i]);
      weekData[i] = UsageData(timeDay[i], sec[i]);
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
          return charts.ColorUtil.fromDartColor(Colors.greenAccent);
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

    var overviewChartWidget = Container(
      height: 200,
      child: AbsorbPointer(absorbing: true, child: overviewChart),
    );
    return dayViewChartWidget;
  }
}
