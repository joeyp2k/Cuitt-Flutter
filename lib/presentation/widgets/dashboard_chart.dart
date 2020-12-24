import 'package:cuitt/data/datasources/my_chart_data.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/design_system/dimensions.dart';
import 'package:cuitt/presentation/design_system/texts.dart';
import 'package:cuitt/presentation/widgets/usage_graph.dart';
import 'package:flutter/material.dart';

double padValue = 0;

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
                              padValue = 0;
                              dataSelection = dayData;
                              viewportSelectionStart =
                                  viewportHour.subtract(Duration(hours: 11));
                              viewportSelectionEnd =
                                  viewportHour.add(Duration(hours: 1));
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
                                  style: DWMY,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              padValue = MediaQuery.of(context).size.width / 4 -
                                  gridSpacer;
                              dataSelection = weekData;
                              viewportSelectionStart =
                                  viewportDay.subtract(Duration(days: 6));
                              viewportSelectionEnd =
                                  viewportDay.add(Duration(days: 1));
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
                            setState(() {
                              padValue =
                                  (MediaQuery.of(context).size.width / 4 -
                                          gridSpacer) *
                                      2;
                              dataSelection = weekData;
                              viewportSelectionStart =
                                  viewportDay.subtract(Duration(days: 29));
                              viewportSelectionEnd =
                                  viewportDay.add(Duration(days: 1));
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
                                  style: DWMY,
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              padValue =
                                  (MediaQuery.of(context).size.width / 4 -
                                          gridSpacer) *
                                      3;
                            });
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
          Padding(
            padding: spacer.bottom.xs,
            child: BarChart(),
          ),
        ],
      ),
    );
  }
}
