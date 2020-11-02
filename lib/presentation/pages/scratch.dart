import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cuitt/bloc/dashboard_bloc.dart';
import 'package:cuitt/data/datasources/dash_tiles.dart';
import 'package:cuitt/data/datasources/dial_data.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/widgets/button.dart';
import 'package:cuitt/presentation/widgets/dashboard_button.dart';
import 'package:cuitt/presentation/widgets/dashboard_tile_large.dart';
import 'package:cuitt/presentation/widgets/dashboard_tile_square.dart';
import 'package:cuitt/presentation/widgets/dmwy_bar.dart';
import 'package:cuitt/presentation/widgets/list_button.dart';
import 'package:cuitt/presentation/widgets/text_entry_box.dart';
import 'package:cuitt/presentation/widgets/usage_dial.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

CounterBloc _counterBlocSink;

final TextEditingController _firstNameController = TextEditingController();

class Scratch extends StatefulWidget {
  @override
  _ScratchState createState() => _ScratchState();
}

class _ScratchState extends State<Scratch> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: spacer.x.sm,
                child: TextEntryBox(
                  textController: _firstNameController,
                  text: "Email",
                  obscureText: false,
                ),
              ),
              Padding(
                padding: spacer.x.sm + spacer.y.sm,
                child: ListButton(
                  color: TransWhite,
                  text: "List Button",
                ),
              ),
              Padding(
                padding: spacer.x.sm + spacer.bottom.sm,
                child: DashboardButton(
                  color: LightBlue,
                  text: "Dashboard Button",
                  icon: Icons.person,
                  iconColor: White,
                ),
              ),
              Padding(
                padding: spacer.x.sm,
                child: Row(
                  children: [
                    DashboardTile(
                      header: drawTile.header,
                      data: drawTile.textData,
                    ),
                    Padding(
                      padding: spacer.left.sm,
                    ),
                    DashboardTile(
                      header: seshTile.header,
                      data: drawTile.textData,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: spacer.all.sm,
                child: Row(
                  children: [
                    DashboardTileLarge(
                      header: timeUntilTile.header,
                      textData: timeUntilTile.textData,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: spacer.x.xxl * 1.5,
                child: Button(
                  text: "Continue",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double padValue = 0;
bool selected = false;

class UsageData {
  final DateTime time;
  final int seconds;

  UsageData(this.time, this.seconds);
}

class ScratchBoard extends StatefulWidget {
  @override
  _ScratchBoardState createState() => _ScratchBoardState();
}

final DateTime start = DateTime.now();
DateTime viewport = DateTime.now();
DateTime timeData;
DateTime viewportVal =
    DateTime(viewport.year, viewport.month, viewport.day, viewport.hour)
        .toLocal();

//var fill = 1;
//var over = 1;
//var unfilled = 1;
var time = [];
var sec = [];
var i = 0;
var overviewData = [
  //try with n incrementing by 1 instead of 2+.  Multiple values per bar is why bars aren't loading
  UsageData(viewportVal, 0),
  UsageData(viewportVal.add(Duration(hours: 1)), 0),
  UsageData(viewportVal.add(Duration(hours: 2)), 0),
  UsageData(viewportVal.add(Duration(hours: 3)), 0),
  UsageData(viewportVal.add(Duration(hours: 4)), 0),
  UsageData(viewportVal.add(Duration(hours: 5)), 0),
  UsageData(viewportVal.add(Duration(hours: 6)), 0),
  UsageData(viewportVal.add(Duration(hours: 7)), 0),
  UsageData(viewportVal.add(Duration(hours: 8)), 0),
  UsageData(viewportVal.add(Duration(hours: 9)), 0),
  UsageData(viewportVal.add(Duration(hours: 10)), 0),
  UsageData(viewportVal.add(Duration(hours: 11)), 0),
];
int n = 1;

class _ScratchBoardState extends State<ScratchBoard> {
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
      animate: false,
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

    return MaterialApp(
      home: BlocProvider<CounterBloc>(
        create: (BuildContext context) => CounterBloc(),
        child: Scaffold(
          backgroundColor: Background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: spacer.all.xs,
                    child: Stack(
                      children: [
                        AnimatedPadding(
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.only(left: padValue),
                          child: Container(
                            height: gridSpacer * 4.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: TransWhite,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'D',
                                          style: ButtonRegular,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      padValue = 0;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'M',
                                          style: ButtonRegular,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      padValue = 0;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'W',
                                          style: ButtonRegular,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      padValue = 0;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Y',
                                          style: ButtonRegular,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      padValue = 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: TransWhite,
                            borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                          ),
                          height: gridSpacer * 4.5,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: spacer.top.xxl * 1.5,
                    child: DMWYBar(),
                  ),
                  loopChartWidget,
                  overviewChartWidget,
                ],
              ),
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: () {
                  if (timeData == null) {
                    timeData = DateTime.now();
                  }
                  timeData =
                      DateTime(timeData.year, timeData.month, timeData.day,
                          timeData.hour)
                          .toLocal();
                  print('Time Data: ' + timeData.toString());
                  if (time.isEmpty) {
                    time.add(
                        DateTime(timeData.year, timeData.month, timeData.day,
                            timeData.hour)
                            .toLocal());
                  }
                  if (sec.isEmpty) {
                    sec.add(0);
                  }
                  if (timeData == time[i]) {
                    sec[i] += 1;
                    print('Data Length: ' + overviewData.length.toString());
                    print('Current Time: ' + time[i].toString());
                    print('Sec: ' + sec[i].toString());
                    overviewData[i] = UsageData(time[i], sec[i]);
                  } else {
                    i++;
                    if (overviewData.length <= i) {
                      sec.add(1);
                      time.add(timeData);
                      print('ADD');
                      print('Current Time: ' + time[i].toString());
                      print('Sec: ' + sec[i].toString());
                      overviewData.add(UsageData(time[i], sec[i]));
                    } else {
                      sec.add(1);
                      time.add(timeData);
                      print('REPLACE');
                      print('Current Time: ' + time[i].toString());
                      print('Sec: ' + sec[i].toString());
                      overviewData[i] = UsageData(time[i], sec[i]);
                    }
                  }
                  print('Viewport Start: ' + viewportVal.toString());
                  print('Viewport Start: ' +
                      viewportVal.add(Duration(hours: 12)).toString());
                  setState(() {});
                },
                child: Text('Increment draw length for hour'),
              ),
              FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  viewportVal = DateTime(timeData.year, timeData.month,
                      timeData.day, timeData.hour)
                      .add(Duration(hours: n))
                      .toLocal();
                  timeData = timeData.add(Duration(hours: n));
                  print('Time Data: ' + timeData.toString());
                  print('Viewport Start: ' + viewportVal.toString());
                  print('Viewport End: ' +
                      viewportVal.add(Duration(hours: 12)).toString());
                },
                child: Text('Increment hour'),
              ),
              FloatingActionButton(
                backgroundColor: LightBlue,
                onPressed: () {
                  fill++;
                  setState(() {

                  });
                  counterBlocSink.add(UpdateDataEvent());
                },
                child: Text('Increment dial'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
