import 'package:cuitt/core/design_system/design_system.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/presentation/widgets/syncfusion_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

double padValue = 0;
int selection = 0;

class DashboardChart extends StatefulWidget {
  @override
  _DashboardChartState createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: spacer.y.xs,
            child: Stack(
              children: [
                AnimatedPadding(
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.only(left: padValue),
                  child: Container(
                    decoration: BoxDecoration(
                      color: TransWhite,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    height: gridSpacer * 4,
                    width: MediaQuery.of(context).size.width / 4 - gridSpacer,
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'D',
                                  style: DWMY,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              tooltipFormat = 'j';
                              dateFormat = DateFormat.j();
                              labelInterval = DateTimeIntervalType.hours;
                              padValue = 0;
                              selection = 0;
                              dataSelection = hourData;
                              viewportSelectionEnd =
                                  viewportHour.add(Duration(minutes: 30));
                              viewportSelectionStart = viewportHour
                                  .subtract(Duration(hours: 11, minutes: 30));
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
                                  style: DWMY,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            tooltipFormat = 'EEEE';
                            dateFormat = DateFormat.EEEE();
                            labelInterval = DateTimeIntervalType.days;
                            padValue = MediaQuery.of(context).size.width / 4 -
                                gridSpacer;
                            selection = 1;
                            dataSelection = dayData;
                            viewportSelectionEnd =
                                viewportDay.add(Duration(hours: 12));
                            viewportSelectionStart = viewportDay
                                .subtract(Duration(days: 6, hours: 12));
                            setState(() {});
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
                                  style: DWMY,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            tooltipFormat = 'Md';
                            dateFormat = DateFormat.Md();
                            labelInterval = DateTimeIntervalType.days;
                            padValue = (MediaQuery.of(context).size.width / 4 -
                                    gridSpacer) *
                                2;
                            selection = 2;
                            dataSelection = dayData;
                            viewportSelectionEnd =
                                viewportDay.add(Duration(hours: 12));
                            viewportSelectionStart = viewportDay
                                .subtract(Duration(days: 29, hours: 12));
                            setState(() {});
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
                                  style: DWMY,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            tooltipFormat = 'MMM';
                            dateFormat = DateFormat.MMM();
                            labelInterval = DateTimeIntervalType.months;
                            padValue = (MediaQuery.of(context).size.width / 4 -
                                    gridSpacer) *
                                3;
                            selection = 3;
                            dataSelection = monthData;
                            viewportSelectionEnd = DateTime(
                                    viewportMonth.year, viewportMonth.month)
                                .add(Duration(days: 14));
                            viewportSelectionStart = DateTime(
                                viewportMonth.year, viewportMonth.month - 11);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: TransWhite,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  height: gridSpacer * 4,
                ),
              ],
            ),
          ),
          SizedBox(
              height: gridSpacer * 30,
              child: Builder(
                builder: (BuildContext context) {
                  if (selection == 0) {
                    return ChartApp();
                  } else if (selection == 1) {
                    return WeekChart();
                  } else if (selection == 2) {
                    return MonthChart();
                  } else {
                    return YearChart();
                  }
                },
              )),
        ],
      ),
    );
  }
}
