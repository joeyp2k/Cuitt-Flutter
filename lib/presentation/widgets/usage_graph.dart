import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cuitt/data/datasources/my_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:cuitt/bloc/dashboard_bloc.dart';
import 'dart:async';

class BarChart extends StatefulWidget {
  @override
  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      timeData = DateTime.now();

      viewportVal =
          DateTime(timeData.year, timeData.month, timeData.day, timeData.hour)
              .toLocal();

      timeData =
          DateTime(timeData.year, timeData.month, timeData.day, timeData.hour)
              .toLocal();

      print('Time Data: ' + timeData.toString());

      if (time.isEmpty) {
        time.add(
            DateTime(timeData.year, timeData.month, timeData.day, timeData.hour)
                .toLocal());
      }

      if (sec.isEmpty) {
        sec.add(0);
      }

      if (timeData == time[i]) {
        sec[i] += drawLength;
        print('Data Length: ' + overviewData.length.toString());
        print('Current Time: ' + time[i].toString());
        print('Sec: ' + sec[i].toString());
        overviewData[i] = UsageData(time[i], sec[i]);
      } else {
        i++;
        if (overviewData.length <= i) {
          sec.add(drawLength);
          time.add(timeData);
          print('ADD');
          print('Current Time: ' + time[i].toString());
          print('Sec: ' + sec[i].toString());
          overviewData.add(UsageData(time[i], sec[i]));
        } else {
          sec.add(drawLength);
          time.add(timeData);
          print('REPLACE');
          print('Current Time: ' + time[i].toString());
          print('Sec: ' + sec[i].toString());
          overviewData[i] = UsageData(time[i], sec[i]);
        }
      }
      setState(() {});
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
    var overviewSeries = [
      new charts.Series(
        id: 'Overview',
        domainFn: (UsageData uData, _) => uData.time,
        measureFn: (UsageData uData, _) => uData.seconds,
        colorFn: (UsageData uData, _) {
          return charts.ColorUtil.fromDartColor(Colors.greenAccent);
        },
        data: overviewData,
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
              start: viewportVal.subtract(Duration(hours: 23)),
              end: viewportVal.add(Duration(hours: 1))),
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
          tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
              day: new charts.TimeFormatterSpec(
                  format: 'HH', transitionFormat: 'HH')),
          viewport: new charts.DateTimeExtents(
              start: viewportVal.subtract(Duration(hours: 11)),
              end: viewportVal.add(Duration(hours: 1))),
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
                  fontSize: 18, // size in Pts.
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
