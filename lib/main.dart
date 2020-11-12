// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convert/convert.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:cuitt/presentation/pages/dashboard.dart';
import 'package:cuitt/presentation/pages/scratch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:secure_random/secure_random.dart';
import 'package:cuitt/data/datasources/dial_data.dart';
import 'package:cuitt/presentation/pages/introduction.dart';

import 'widgets.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

var secureRandom = SecureRandom();
String randID;

int currentIndex = 2;
int locationPage = 0;
int settingPage = 0;
bool sugLockValue = false;
bool limLockValue = false;
bool dataShareValue = false;

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _usernameController = TextEditingController();
final TextEditingController _verifyController = TextEditingController();
final TextEditingController _firstNameController = TextEditingController();
final TextEditingController _lastNameController = TextEditingController();
final TextEditingController _groupNameController = TextEditingController();
final TextEditingController _groupPasswordController = TextEditingController();
final TextEditingController _verifyGroupPasswordController =
    TextEditingController();
final TextEditingController _groupIDController = TextEditingController();

final snackBar = SnackBar(content: Text('Passwords do not match'));

final firestoreInstance = Firestore.instance;
var firebaseUser;

var userIDList = [];
var userNameList = [];
var groupIDList = [];
var groupNameList = [];
var groupName;
var username;
var selection;
var returnVal = 0;
var nextAction = 0;
var backButton = 0;

class AutoSugLockButton extends StatefulWidget {
  @override
  _AutoSugLockButtonState createState() => _AutoSugLockButtonState();
}

class _AutoSugLockButtonState extends State<AutoSugLockButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: RichText(
              text: TextSpan(
                text: 'Automatic Suggestion Locking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            value: sugLockValue,
            selected: sugLockValue,
            activeColor: Colors.greenAccent,
            onChanged: (bool) {
              setState(() {
                sugLockValue = !sugLockValue;
              });
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: RichText(
              text: TextSpan(
                text:
                    'Automatically cut the voltage when Cuitt suggests a stop interval',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AutoLimLockButton extends StatefulWidget {
  @override
  _AutoLimLockButtonState createState() => _AutoLimLockButtonState();
}

class _AutoLimLockButtonState extends State<AutoLimLockButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: RichText(
              text: TextSpan(
                text: 'Automatic Limit Locking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            value: limLockValue,
            selected: limLockValue,
            activeColor: Colors.greenAccent,
            onChanged: (bool) {
              setState(() {
                limLockValue = !limLockValue;
              });
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: RichText(
              text: TextSpan(
                text:
                    'Automatically cut the voltage when Cuitt detects you are exceeding the suggested draw length',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataShareButton extends StatefulWidget {
  @override
  _DataShareButtonState createState() => _DataShareButtonState();
}

class _DataShareButtonState extends State<DataShareButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: RichText(
              text: TextSpan(
                text: 'Data Sharing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            value: dataShareValue,
            selected: dataShareValue,
            activeColor: Colors.greenAccent,
            onChanged: (bool) {
              setState(() {
                dataShareValue = !dataShareValue;
              });
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: RichText(
              text: TextSpan(
                text:
                    'Share your usage statistics to help improve Cuitt.  Your location data will not be shared.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GaugeChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GaugeChart(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory GaugeChart.withSampleData() {
    return new GaugeChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        // Configure the width of the pie slices to 30px. The remaining space in
        // the chart will be left as a hole in the center. Adjust the start
        // angle and the arc length of the pie so it resembles a gauge.
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 30, startAngle: 4 / 5 * pi, arcLength: 7 / 5 * pi));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> _createSampleData() {
    final data = [
      new GaugeSegment('Low', 75),
      new GaugeSegment('Acceptable', 100),
      new GaugeSegment('High', 50),
    ];

    return [
      new charts.Series<GaugeSegment, String>(
        id: 'Segments',
        colorFn: (GaugeSegment segment, _) {
          switch (segment.segment) {
            case "Low":
              {
                return charts.ColorUtil.fromDartColor(Colors.redAccent);
              }
              break;
            case "Acceptable":
              {
                return charts.ColorUtil.fromDartColor(Colors.greenAccent);
              }
              break;
            case "High":
              {
                return charts.ColorUtil.fromDartColor(Colors.white12);
              }
              break;
            default:
              {
                return charts.ColorUtil.fromDartColor(Colors.white60);
              }
          }
        },
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        data: data,
      )
    ];
  }
}

class GaugeSegment {
  final String segment;
  final int size;

  GaugeSegment(this.segment, this.size);
}

class GaugeChartYest extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  GaugeChartYest(this.seriesList, {this.animate});

  /// Creates a [PieChart] with sample data and no transition.
  factory GaugeChartYest.withSampleData() {
    return new GaugeChartYest(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        // Configure the width of the pie slices to 30px. The remaining space in
        // the chart will be left as a hole in the center. Adjust the start
        // angle and the arc length of the pie so it resembles a gauge.
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 20, startAngle: 4 / 5 * pi, arcLength: 7 / 5 * pi));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegmentYest, String>> _createSampleData() {
    final data = [
      new GaugeSegmentYest('Low', 75),
      new GaugeSegmentYest('Acceptable', 100),
      new GaugeSegmentYest('High', 50),
    ];

    return [
      new charts.Series<GaugeSegmentYest, String>(
        id: 'Segments',
        colorFn: (GaugeSegmentYest segment, _) {
          switch (segment.segment) {
            case "Low":
              {
                return charts.ColorUtil.fromDartColor(Colors.redAccent);
              }
              break;
            case "Acceptable":
              {
                return charts.ColorUtil.fromDartColor(Colors.greenAccent);
              }
              break;
            case "High":
              {
                return charts.ColorUtil.fromDartColor(Colors.white12);
              }
              break;
            default:
              {
                return charts.ColorUtil.fromDartColor(Colors.white60);
              }
          }
        },
        domainFn: (GaugeSegmentYest segment, _) => segment.segment,
        measureFn: (GaugeSegmentYest segment, _) => segment.size,
        data: data,
      )
    ];
  }
}

class GaugeSegmentYest {
  final String segment;
  final int size;

  GaugeSegmentYest(this.segment, this.size);
}

class SparkBar extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SparkBar(this.seriesList, {this.animate});

  factory SparkBar.withSampleData() {
    return new SparkBar(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,

      /// Assign a custom style for the measure axis.
      ///
      /// The NoneRenderSpec only draws an axis line (and even that can be hidden
      /// with showAxisLine=false).
      primaryMeasureAxis:
          new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),

      /// This is an OrdinalAxisSpec to match up with BarChart's default
      /// ordinal domain axis (use NumericAxisSpec or DateTimeAxisSpec for
      /// other charts).
      domainAxis: new charts.OrdinalAxisSpec(
          // Make sure that we draw the domain axis line.
          showAxisLine: true,
          // But don't draw anything else.
          renderSpec: new charts.NoneRenderSpec()),

      // With a spark chart we likely don't want large chart margins.
      // 1px is the smallest we can make each margin.
      layoutConfig: new charts.LayoutConfig(
          leftMarginSpec: new charts.MarginSpec.fixedPixel(0),
          topMarginSpec: new charts.MarginSpec.fixedPixel(0),
          rightMarginSpec: new charts.MarginSpec.fixedPixel(0),
          bottomMarginSpec: new charts.MarginSpec.fixedPixel(0)),
    );
  }

  /// Create series list with single series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final globalSalesData = [
      new OrdinalSales('2007', 3100),
      new OrdinalSales('2008', 3500),
      new OrdinalSales('2009', 5000),
      new OrdinalSales('2010', 2500),
      new OrdinalSales('2011', 3200),
      new OrdinalSales('2012', 4500),
      new OrdinalSales('2013', 4400),
      new OrdinalSales('2014', 5000),
      new OrdinalSales('2015', 5000),
      new OrdinalSales('2016', 4500),
      new OrdinalSales('2017', 4300),
      new OrdinalSales('2018', 3100),
      new OrdinalSales('2019', 3500),
      new OrdinalSales('2020', 5000),
      new OrdinalSales('2021', 2500),
      new OrdinalSales('2022', 3200),
      new OrdinalSales('2023', 4500),
      new OrdinalSales('2024', 4400),
      new OrdinalSales('2025', 5000),
      new OrdinalSales('2026', 5000),
      new OrdinalSales('2027', 4500),
      new OrdinalSales('2028', 4300),
      new OrdinalSales('2029', 5000),
      new OrdinalSales('2030', 4500),
      new OrdinalSales('2031', 4300),
      new OrdinalSales('2032', 3100),
      new OrdinalSales('2033', 3500),
      new OrdinalSales('2034', 5000),
      new OrdinalSales('2035', 2500),
      new OrdinalSales('2036', 3200),
      new OrdinalSales('2037', 4500),
      new OrdinalSales('2038', 4400),
      new OrdinalSales('2039', 5000),
      new OrdinalSales('2040', 5000),
      new OrdinalSales('2041', 4500),
      new OrdinalSales('2042', 4300),
      new OrdinalSales('2043', 3100),
      new OrdinalSales('2044', 3500),
      new OrdinalSales('2045', 5000),
      new OrdinalSales('2046', 2500),
      new OrdinalSales('2047', 3200),
      new OrdinalSales('2048', 4500),
      new OrdinalSales('2049', 4400),
      new OrdinalSales('2050', 5000),
      new OrdinalSales('2051', 5000),
      new OrdinalSales('2052', 4500),
      new OrdinalSales('2053', 4300),
      new OrdinalSales('2054', 5000),
      new OrdinalSales('2055', 4500),
      new OrdinalSales('2056', 4300),
      new OrdinalSales('2057', 5000),
      new OrdinalSales('2058', 4500),
      new OrdinalSales('2059', 4300),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Global Revenue',
        colorFn: (OrdinalSales segment, _) {
          return charts.ColorUtil.fromDartColor(Colors.greenAccent);
        },
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: globalSalesData,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}

class DashPage extends StatefulWidget {
  @override
  _DashPageState createState() => _DashPageState();
}

class _DashPageState extends State<DashPage> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Consumer<AppState>(builder: (context, appState, child) {
      return dash[appState.dashIndex];
    });
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Container(
      margin: EdgeInsets.only(bottom: 35),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              Consumer<AppState>(
                builder: (context, appState, child) {
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 400,
                        width: 400,
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                height: 310,
                                width: 310,
                                child: GaugeChartYest.withSampleData(),
                              ),
                            ),
                            GaugeChart.withSampleData(),
                            Container(
                              height: 375,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'TODAY\'S TOTAL',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: drawLengthTotal.toString() +
                                            's' +
                                            ' (+100.0)',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 28,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: 'DAILY AVERAGE',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text:
                                            drawLengthTotalAverage.toString() +
                                                's' +
                                                ' (+100.0)',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 330),
                        child: InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'SESHES',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: seshCount.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'DRAWS',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: drawCount.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'SUGGESTION',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: suggestion.toString() + 's',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'TIME UNTIL NEXT DRAW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: timeUntilNext.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'DRAW LENGTH',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text: drawLength.toString() + 's',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'AVERAGE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              text:
                                                  drawLengthAverage.toString() +
                                                      's',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(20, 15, 20, 2),
                                  height: 60,
                                  width: 350,
                                  child: SparkBar.withSampleData(),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            appState.dashIndex = 1;
                            appState.update();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PartnerPage extends StatefulWidget {
  @override
  _PartnerPageState createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueGrey[900],
          title: Consumer<AppState>(
            builder: (context, appState, child) {
              return Text(partnerBarText[appState.partnerIndex]);
            },
          ),
          actions: [
            Consumer<AppState>(builder: (context, appState, child) {
              if (appState.actionIndex == 0) {
                return Center();
              } else {
                return IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    switch (appState.partnerIndex) {
                      case 5:
                        {
                          appState.partnerIndex = 4;
                          appState.actionIndex = 0;
                        }
                        break;
                      case 6:
                        {
                          appState.partnerIndex = 5;
                          appState.actionIndex = 1;
                        }
                        break;
                      case 7:
                        {
                          appState.partnerIndex = 5;
                          appState.actionIndex = 1;
                        }
                        break;
                      case 8:
                        {
                          appState.partnerIndex = 4;
                          appState.actionIndex = 0;
                        }
                        break;
                      case 9:
                        {
                          appState.partnerIndex = 4;
                          appState.actionIndex = 0;
                        }
                        break;
                      case 10:
                        {
                          appState.partnerIndex = 4;
                          appState.actionIndex = 0;
                        }
                        break;
                      case 11:
                        {
                          appState.partnerIndex = 10;
                          appState.actionIndex = 1;
                        }
                        break;
                      case 12:
                        {
                          appState.partnerIndex = 11;
                          appState.actionIndex = 1;
                        }
                        break;
                      case 13:
                        {
                          appState.partnerIndex = 12;
                          appState.actionIndex = 1;
                        }
                        break;
                      default:
                        {
                          appState.actionIndex = 0;
                        }
                    }
                    appState.update();
                  },
                );
              }
            }),
          ],
        ),
        Consumer<AppState>(
          builder: (context, appState, child) {
            return partnerPage[appState.partnerIndex];
          },
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.blueGrey[900],
          automaticallyImplyLeading: false,
          actions: [
            Consumer<AppState>(
              builder: (context, appState, child) {
                if (appState.actionIndex == 0) {
                  return Center();
                } else {
                  return IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      appState.settingsIndex = 0;
                      appState.actionIndex = 0;
                      appState.update();
                    },
                  );
                }
              },
            ),
          ],
          title: Consumer<AppState>(
            builder: (context, appState, child) {
              return Text(settingBarText[appState.settingBarIndex]);
            },
          ),
        ),
        Consumer<AppState>(
          builder: (context, appState, child) {
            return settingsPage[appState.settingsIndex];
          },
        ),
      ],
    );
  }
}

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  GoogleMapController _controller;

  Widget build(BuildContext context) {
    if (locationPage == 0) {
      return Container(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.greenAccent,
              title: Text('Location'),
            ),
            Container(
              margin: EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.gps_fixed,
                    size: 100,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'This data will only be visible to you and will never be shared.',
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            text:
                                'Your Cuitt\'s location will update while it is connected to your device.  ',
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Material(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.greenAccent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      onTap: (() {
                        setState(() {
                          locationPage = 1;
                        });
                      }),
                      child: Container(
                        height: 40,
                        width: 170,
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Continue',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (locationPage == 1) {
      return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(22, 88),
          zoom: 12,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      );
    }
  }
}

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blueGrey[900],
            title: Text('Information'),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        'Cuitt will provide suggestions after the first two weeks of activating the device.  ',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 40),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Status Button',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Hold the status button for five seconds to start pairing.  The suggestion light will alternate flashing red and blue.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'If the status button is red upon pressing, a draw is not advisable.  If it is blue, a draw can be taken.  ',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Suggestion Light',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'If the suggestion light turns blue while taking a draw, you should stop within two seconds in order to maintain progress toward reducing your usage.  '
                              'The suggestion light will turn red if you continue taking your draw past this two second window.  ',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsHome extends StatefulWidget {
  @override
  _SettingsHomeState createState() => _SettingsHomeState();
}

class _SettingsHomeState extends State<SettingsHome>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ExpansionTile(
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
              ),
              title: Container(
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: Colors.white,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: RichText(
                        text: TextSpan(
                          text: 'Data Sharing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                DataShareButton(),
              ],
            ),
            ExpansionTile(
              trailing: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
              ),
              title: Container(
                height: 45,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Auto Locking',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              children: [
                AutoLimLockButton(),
                AutoSugLockButton(),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                appState.settingsIndex = 1;
                appState.actionIndex = 1;
                appState.update();
              },
              child: Container(
                height: 60,
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: RichText(
                              text: TextSpan(
                                text: 'Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                appState.settingsIndex = 2;
                appState.actionIndex = 1;
                appState.update();
              },
              child: Container(
                height: 60,
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.white,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: RichText(
                              text: TextSpan(
                                text: 'About',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'InfoBox',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'InfoBox',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PartnerIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Center(
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text:
                            'Keep Accountable With The Help of Someone You Trust',
                        style: TextStyle(
                          letterSpacing: 0,
                          fontSize: 25,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.smartphone,
                        size: 40,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.compare_arrows,
                        size: 35,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.cloud_queue,
                        size: 60,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.compare_arrows,
                        size: 35,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.smartphone,
                        size: 40,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.fromLTRB(20, 0, 20, 40),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Partner Mode allows you to share your usage statistics with an accountability buddy or group of your choice.  ',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '• You do not need to own a Cuitt enabled device in order to view another user\'s stats.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '• Location data will never be shared with your partner(s).',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Create a Cuitt account or login to get started.',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    onTap: (() {
                      appState.partnerIndex = 1;
                      appState.update();
                    }),
                    child: Container(
                      height: 40,
                      width: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Continue',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PartnerAcctNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(150),
          child: Icon(Icons.clear),
        ),
        Container(
          margin: EdgeInsets.all(20),
          child: Material(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              onTap: (() {
                appState.partnerIndex = 3;
                appState.update();
              }),
              child: Container(
                height: 40,
                width: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Material(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              onTap: (() {
                appState.partnerIndex = 2;
                appState.update();
              }),
              child: Container(
                height: 40,
                width: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Register',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _success;
  String _userEmail;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    void _signInWithEmailAndPassword() async {
      final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      if (user != null) {
        _success = true;
        _userEmail = user.email;
        appState.partnerIndex = 4;
        appState.update();
      } else {
        _success = false;
      }
    }

    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Material(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            onTap: (() {
                              if (_formKey.currentState.validate()) {
                                _signInWithEmailAndPassword();
                              }
                            }),
                            child: Container(
                              height: 40,
                              width: 170,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              appState.partnerIndex = 2;
              appState.update();
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
              child: RichText(
                text: TextSpan(
                  text: 'Create Account',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateAcctPage extends StatefulWidget {
  @override
  _CreateAcctPageState createState() => _CreateAcctPageState();
}

class _CreateAcctPageState extends State<CreateAcctPage> {
  bool _success;
  String _userEmail;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    void _register() async {
      var groupList = [];
      final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      if (user != null) {
        firebaseUser = (await FirebaseAuth.instance.currentUser());
        firestoreInstance
            .collection("users")
            .document(firebaseUser.uid)
            .setData({
          "username": _usernameController.text,
          "email": _emailController.text,
          "first name": _firstNameController.text,
          "last name": _lastNameController.text,
          "groups": groupList,
        });
        _success = true;
        _userEmail = user.email;
        appState.partnerIndex = 4;
        appState.update();
      } else {
        _success = false;
      }
    }

    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'First Name',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 145,
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    style: TextStyle(
                                      color: Colors.white70,
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Last Name',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 145,
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    style: TextStyle(
                                      color: Colors.white70,
                                    ),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Username',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Verify Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _verifyController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Material(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          child: InkWell(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            onTap: (() {
                              if (_formKey.currentState.validate()) {
                                if (_passwordController.text !=
                                    _verifyController.text) {
                                  Scaffold.of(context).showSnackBar(snackBar);
                                } else {
                                  _register();
                                }
                              }
                            }),
                            child: Container(
                              height: 40,
                              width: 170,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Create Account',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              appState.partnerIndex = 3;
              appState.update();
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
              child: RichText(
                text: TextSpan(
                  text: 'Login',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PartnerHome extends StatefulWidget {
  @override
  _PartnerHomeState createState() => _PartnerHomeState();
}

class _PartnerHomeState extends State<PartnerHome> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Center(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(15),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              onTap: () {
                //appState.partnerIndex = 5;
                //appState.actionIndex = 1;
                //appState.update();
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: Colors.white,
                          size: 50,
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        text: TextSpan(
                          text: 'Create a group to invite others to.',
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              onTap: () {
                //appState.partnerIndex = 8;
                //appState.actionIndex = 1;
                //appState.update();
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 50,
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        text: TextSpan(
                          text: 'Join a preexisting group.',
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(15),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              onTap: () {
                //appState.actionIndex = 1;
                //appState.groups();
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.list,
                          color: Colors.white,
                          size: 50,
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        text: TextSpan(
                          text: 'View groups you are signed into.',
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupCreate extends StatefulWidget {
  @override
  _GroupCreateState createState() => _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.all(15),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              onTap: () {
                randID = secureRandom.nextString(
                    length: 5,
                    charset:
                        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
                appState.partnerIndex = 6;
                appState.actionIndex = 1;
                appState.update();
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: RichText(
                        text: TextSpan(
                          text: 'Administrative',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.smartphone,
                          color: Colors.white,
                          size: 50,
                        ),
                        Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 35,
                        ),
                        Icon(
                          Icons.smartphone,
                          color: Colors.white,
                          size: 50,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 35,
                        ),
                        Icon(
                          Icons.smartphone,
                          color: Colors.white,
                          size: 50,
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        text: TextSpan(
                          text: 'Users cannot see group administrators\' data.',
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              onTap: () {
                randID = secureRandom.nextString(
                    length: 5,
                    charset:
                        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
                appState.partnerIndex = 7;
                appState.actionIndex = 1;
                appState.update();
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: RichText(
                        text: TextSpan(
                          text: 'Casual',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.smartphone,
                          color: Colors.white,
                          size: 50,
                        ),
                        Icon(
                          Icons.compare_arrows,
                          color: Colors.white,
                          size: 35,
                        ),
                        Icon(
                          Icons.smartphone,
                          color: Colors.white,
                          size: 50,
                        ),
                        Icon(
                          Icons.compare_arrows,
                          color: Colors.white,
                          size: 35,
                        ),
                        Icon(
                          Icons.smartphone,
                          color: Colors.white,
                          size: 50,
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        text: TextSpan(
                          text:
                              'Each user\'s data is visible to the rest of the group',
                          style: TextStyle(
                            height: 1.4,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupAdminCreate extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  void _createAdminGroup() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser());
    firestoreInstance.collection("groups").document(randID).setData({
      "administrative group": true,
      "group name": _groupNameController.text,
      "group password": _groupPasswordController.text,
      "admins": FieldValue.arrayUnion([firebaseUser.uid]),
      "members": FieldValue.arrayUnion([firebaseUser.uid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                color: Colors.white),
            margin: EdgeInsets.symmetric(vertical: 20),
            padding: EdgeInsets.all(20),
            child: RichText(
              text: TextSpan(
                text: 'Group ID: ' + randID,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 39.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Group Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _groupNameController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Group Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _groupPasswordController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Verify Group Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _verifyGroupPasswordController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Material(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      onTap: (() {
                        if (_groupPasswordController.text !=
                            _verifyGroupPasswordController.text) {
                          Scaffold.of(context).showSnackBar(snackBar);
                        } else if (_formKey.currentState.validate()) {
                          _createAdminGroup();
                          appState.groups();
                        }
                      }),
                      child: Container(
                        height: 40,
                        width: 270,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Create Administrative Group',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GroupCasualCreate extends StatelessWidget {
  @override
  final _formKey = GlobalKey<FormState>();

  void _createCasualGroup() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser());
    firestoreInstance.collection("groups").document(randID).setData({
      "administrative group": false,
      "group name": _groupNameController.text,
      "group password": _groupPasswordController.text,
      "admins": firebaseUser.uid,
      "members": FieldValue.arrayUnion([firebaseUser.uid]),
    });
  }

  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                color: Colors.white),
            margin: EdgeInsets.symmetric(vertical: 20),
            padding: EdgeInsets.all(20),
            child: RichText(
              text: TextSpan(
                text: 'Group ID: ' + randID,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 39.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Group Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _groupNameController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Group Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _groupPasswordController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Verify Group Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _verifyGroupPasswordController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Material(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      onTap: (() {
                        if (_groupPasswordController.text !=
                            _verifyGroupPasswordController.text) {
                          Scaffold.of(context).showSnackBar(snackBar);
                        } else if (_formKey.currentState.validate()) {
                          _createCasualGroup();
                          appState.groups();
                        }
                      }),
                      child: Container(
                        height: 40,
                        width: 270,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Create Casual Group',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GroupJoin extends StatefulWidget {
  @override
  _GroupJoinState createState() => _GroupJoinState();
}

class _GroupJoinState extends State<GroupJoin> {
  @override
  final _formKey = GlobalKey<FormState>();

  void _joinGroup() async {
    firebaseUser = (await FirebaseAuth.instance.currentUser());
    firestoreInstance
        .collection("groups")
        .document(_groupIDController.text)
        .updateData({
      "members": FieldValue.arrayUnion([firebaseUser.uid]),
    });
  }

  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Group ID',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _groupIDController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Group Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: _groupPasswordController,
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Material(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      onTap: (() {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _joinGroup();
                            appState.partnerIndex = 9;
                            appState.update();
                          });
                        }
                      }),
                      child: Container(
                        height: 40,
                        width: 270,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Join Group',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GroupEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 225, 20, 0),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.warning,
                size: 40,
                color: Colors.white,
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                        'You are not a member of any groups.  Create or join one to get started!',
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GroupsList extends StatefulWidget {
  @override
  _GroupsListState createState() => _GroupsListState();
}

class _GroupsListState extends State<GroupsList> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemCount: groupNameList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              onTap: () {
                selection = '${groupIDList[index]}';
                groupName = '${groupNameList[index]}';
                partnerBarText[11] = groupName;
                appState.actionIndex = 1;
                appState.groupSelection();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                height: 50,
                child: Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: '${groupNameList[index]}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10),
          itemCount: userNameList.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                onTap: () {
                  appState.partnerIndex = 12;
                  username = '${userNameList[index]}';
                  partnerBarText[12] = username;
                  partnerBarText[13] = username;
                  appState.actionIndex = 1;
                  appState.update();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  height: 100,
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '${userNameList[index]}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SimpleBarChart.withSampleData() {
    return new SimpleBarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      domainAxis: new charts.OrdinalAxisSpec(
          renderSpec: new charts.SmallTickRendererSpec(

              // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
                  fontSize: 14, // size in Pts.
                  color: charts.MaterialPalette.white),

              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(
                  color: charts.MaterialPalette.white))),

      /// Assign a custom style for the measure axis.
      primaryMeasureAxis: new charts.NumericAxisSpec(
          renderSpec: new charts.GridlineRendererSpec(

              // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
                  fontSize: 16, // size in Pts.
                  color: charts.MaterialPalette.white),

              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(
                  color: charts.ColorUtil.fromDartColor(Colors.white70)))),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = [
      new OrdinalSales('2014', 5),
      new OrdinalSales('2015', 25),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 75),
      new OrdinalSales('2018', 5),
      new OrdinalSales('2019', 25),
      new OrdinalSales('2020', 100),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.greenAccent),
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

class UserData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = [
      new DialData('Over', over, Colors.red),
      new DialData('Fill', fill, Colors.green),
      new DialData('Unfilled', unfilled, Colors.grey),
    ];

    var series = [
      new charts.Series(
        id: 'Today',
        domainFn: (DialData tData, _) => tData.type,
        measureFn: (DialData tData, _) => tData.seconds,
        colorFn: (DialData tData, _) => tData.color,
        data: data,
      ),
    ];

    var chart = new charts.PieChart(
      series,
      defaultRenderer: new charts.ArcRendererConfig(arcWidth: 25),
      animate: true,
    );

    var chartWidget = SizedBox(
      height: 300.0,
      child: chart,
    );
    final appState = Provider.of<AppState>(context, listen: false);
    return Container(
      margin: EdgeInsets.only(bottom: 35),
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 400,
                  width: 400,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: 310,
                          width: 310,
                          child: GaugeChartYest.withSampleData(),
                        ),
                      ),
                      chartWidget,
                      Container(
                        height: 375,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'TODAY\'S TOTAL',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: '000.0s' + ' (+100.0)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: 'DAILY AVERAGE',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: '000.0s' + ' (+100.0)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 330),
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'SESHES',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '00',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'DRAWS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '00',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'SUGGESTION',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '000.0s',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'TIME UNTIL NEXT DRAW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '00:00:00',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'DRAW LENGTH',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '000.0s',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'AVERAGE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '000.0s',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 15, 20, 2),
                            height: 60,
                            width: 350,
                            child: SparkBar.withSampleData(),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      appState.partnerIndex = 13;
                      appState.update();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserExpandedData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            height: 35,
            width: 350,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: RichText(
                            text: TextSpan(
                              text: 'D',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: RichText(
                            text: TextSpan(
                              text: 'W',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: RichText(
                            text: TextSpan(
                              text: 'M',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: RichText(
                            text: TextSpan(
                              text: 'Y',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 35,
                      width: 350 / 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 350,
            margin: EdgeInsets.only(bottom: 3),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      child: RichText(
                        text: TextSpan(
                          text: 'TOTAL',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 5),
                        child: RichText(
                          text: TextSpan(
                            text: '000.0',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: RichText(
                          text: TextSpan(
                            text: 'seconds',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      child: RichText(
                        text: TextSpan(
                          text: 'Today',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            height: 200,
            width: 350,
            child: SimpleBarChart.withSampleData(),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 35),
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'SESHES',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: seshCount.toString() + '(+00)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'DRAWS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: '00 (+00)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'DRAW LENGTH AVERAGE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: '000.0s (+000.0s)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'WAIT PERIOD AVERAGE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: timeBetweenAverage.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandedDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Container(
      margin: EdgeInsets.only(bottom: 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blueGrey[900],
            title: Text('Summary'),
            actions: [
              BackButton(onPressed: () {
                appState.dashIndex = 0;
                appState.update();
              }),
            ],
          ),
          Consumer<AppState>(builder: (context, appState, child) {
            return Column(
              children: [
                Container(
                  height: 20,
                  width: 20,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  height: 35,
                  width: 350,
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'D',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'W',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'M',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Y',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            height: 35,
                            width: 350 / 4,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 350,
                  margin: EdgeInsets.only(bottom: 3),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            child: RichText(
                              text: TextSpan(
                                text: 'TOTAL',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: RichText(
                                text: TextSpan(
                                  text: drawLengthTotal.toString(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: RichText(
                                text: TextSpan(
                                  text: 'seconds',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            child: RichText(
                              text: TextSpan(
                                text: 'Today',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  height: 200,
                  width: 350,
                  child: SimpleBarChart.withSampleData(),
                ),
                Container(
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'SESHES',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '00 (+00)',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'DRAWS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '00 (+00)',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'DRAW LENGTH AVERAGE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '000.0s (+000.0s)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'WAIT PERIOD AVERAGE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '00:00:00 (+ 00:00:00)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {},
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class UserDayData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            height: 50,
            width: 150,
          ),
        ),
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      height: 50,
                      width: 150,
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'XX/XX/XX',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 400,
                    width: 400,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            height: 310,
                            width: 310,
                            child: GaugeChartYest.withSampleData(),
                          ),
                        ),
                        Container(
                          height: 375,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Today\'s Total',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '00.0s' + ' (+100.0)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Daily Average',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '00.0s' + ' (+100.0)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 340, 20, 20),
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Seshes',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: seshCount.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Draws',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: drawCount.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                              child: Column(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: 'Draw Length Average',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: drawLengthAverage.toString() + 's',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 60,
                              width: 300,
                              child: SparkBar.withSampleData(),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DayDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            height: 50,
            width: 150,
          ),
        ),
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      height: 50,
                      width: 150,
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'XX/XX/XX',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 400,
                    width: 400,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            height: 310,
                            width: 310,
                            child: GaugeChartYest.withSampleData(),
                          ),
                        ),
                        Container(
                          height: 375,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: 'Today\'s Total',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '00.0s' + ' (+100.0)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: 'Daily Average',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '00.0s' + ' (+100.0)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 340, 20, 20),
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Seshes',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '00',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Draws',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: '00',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                              child: Column(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: 'Draw Length Average',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: '00.0s',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 60,
                              width: 300,
                              child: SparkBar.withSampleData(),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PartnerExclusive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey[900],
        title: Consumer<AppState>(
          builder: (context, appState, child) {
            return Text(partnerBarText[appState.partnerIndex]);
          },
        ),
        actions: [
          Consumer<AppState>(builder: (context, appState, child) {
            if (appState.actionIndex == 0) {
              return Center();
            } else {
              return IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  switch (appState.partnerIndex) {
                    case 5:
                      {
                        appState.partnerIndex = 4;
                        appState.actionIndex = 0;
                      }
                      break;
                    case 6:
                      {
                        appState.partnerIndex = 5;
                        appState.actionIndex = 1;
                      }
                      break;
                    case 7:
                      {
                        appState.partnerIndex = 5;
                        appState.actionIndex = 1;
                      }
                      break;
                    case 8:
                      {
                        appState.partnerIndex = 4;
                        appState.actionIndex = 0;
                      }
                      break;
                    case 9:
                      {
                        appState.partnerIndex = 4;
                        appState.actionIndex = 0;
                      }
                      break;
                    case 10:
                      {
                        appState.partnerIndex = 4;
                        appState.actionIndex = 0;
                      }
                      break;
                    case 11:
                      {
                        appState.partnerIndex = 10;
                        appState.actionIndex = 1;
                      }
                      break;
                    case 12:
                      {
                        appState.partnerIndex = 11;
                        appState.actionIndex = 1;
                      }
                      break;
                    case 13:
                      {
                        appState.partnerIndex = 12;
                        appState.actionIndex = 1;
                      }
                      break;
                    default:
                      {
                        appState.actionIndex = 0;
                      }
                  }
                  appState.update();
                },
              );
            }
          }),
        ],
      ),
      body: partnerPage[appState.partnerIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Icons.settings,
          color: Colors.white,
        ),
        backgroundColor: Colors.greenAccent,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.white12,
        notchMargin: 2.0,
      ),
    );
  }
}

List<Widget> dash = [
  Dashboard(),
  ExpandedDashboard(),
  DayDashboard(),
];

List<Widget> pages = [
  SettingsPage(),
  PartnerPage(),
  DashPage(),
  LocationPage(),
  InfoPage(),
];

List<Widget> settingsPage = [
  SettingsHome(),
  AccountSettings(),
  About(),
];

List<Widget> partnerPage = [
  PartnerIntro(),
  PartnerAcctNav(),
  CreateAcctPage(),
  LoginPage(),
  PartnerHome(),
  GroupCreate(),
  GroupAdminCreate(),
  GroupCasualCreate(),
  GroupJoin(),
  GroupEmpty(),
  GroupsList(),
  UserList(),
  UserData(),
  UserExpandedData(),
];

List<String> settingBarText = [
  'Settings',
  'Account',
  'About',
];

List<String> partnerBarText = [
  'Partner Mode',
  'Partner Mode',
  'Register',
  'Login',
  'Cuitt',
  'Create Group',
  'Create Administrative Group',
  'Create Casual Group',
  'Join Group',
  'Groups',
  'Groups',
  '',
  '',
  '',
];

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Color _locIconColor = Colors.white;
  Color _setIconColor = Colors.white;
  Color _partIconColor = Colors.white;
  Color _infoIconColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: MaterialApp(
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.blueGrey[900],
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _locIconColor = Colors.white;
                _setIconColor = Colors.white;
                _partIconColor = Colors.white;
                _infoIconColor = Colors.white;
                currentIndex = 2;
              });
            },
            child: Icon(
              Icons.timeline,
              color: Colors.white,
            ),
            backgroundColor: Colors.greenAccent,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            color: Colors.white12,
            notchMargin: 2.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 17),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        _infoIconColor = Colors.greenAccent;
                        _locIconColor = Colors.white;
                        _setIconColor = Colors.white;
                        _partIconColor = Colors.white;
                        currentIndex = 4;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      height: 50,
                      width: 55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _infoIconColor,
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Info',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        _infoIconColor = Colors.white;
                        _locIconColor = Colors.greenAccent;
                        _setIconColor = Colors.white;
                        _partIconColor = Colors.white;
                        currentIndex = 3;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 35),
                      padding: EdgeInsets.symmetric(vertical: 4),
                      height: 50,
                      width: 55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            color: _locIconColor,
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        _infoIconColor = Colors.white;
                        _locIconColor = Colors.white;
                        _setIconColor = Colors.white;
                        _partIconColor = Colors.greenAccent;
                        currentIndex = 1;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 35),
                      padding: EdgeInsets.symmetric(vertical: 4),
                      height: 50,
                      width: 55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.people,
                            color: _partIconColor,
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Partner',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        _infoIconColor = Colors.white;
                        _locIconColor = Colors.white;
                        _setIconColor = Colors.greenAccent;
                        _partIconColor = Colors.white;
                        currentIndex = 0;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      height: 50,
                      width: 55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.settings,
                            color: _setIconColor,
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: pages[currentIndex],
        ),
      ),
    );
  }
}

class AppState with ChangeNotifier {
  List<int> value;
  int settingBarIndex = 0;
  int partnerBarIndex = 0;
  int settingsIndex = 0;
  int partnerIndex = 0;
  int dashIndex = 0;
  int actionIndex = 0;

  void update() {
    notifyListeners();
  }

  void groups() async {
    int arrayindex = 0;
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    var value = await firestoreInstance
        .collection("groups")
        .where("members", arrayContains: firebaseUser.uid)
        .getDocuments();

    groupNameList.clear();
    groupIDList.clear();
    value.documents.forEach((element) {
      groupNameList.insert(arrayindex, element.data["group name"]);
      groupIDList.insert(arrayindex, element.documentID);
      arrayindex++;
    });
    if (groupNameList.isEmpty) {
      partnerIndex = 9;
      notifyListeners();
    } else {
      partnerIndex = 10;
      notifyListeners();
    }
  }

  void groupSelection() async {
    var usernameindex = 0;
    var value = await firestoreInstance
        .collection("groups")
        .document(selection) //selection = group name and should be group ID
        .get()
        .then((value) => userIDList = value.data["members"]);
    usernameindex = userIDList.length;
    userNameList.clear();
    for (int i = 0; i < usernameindex; i++) {
      value = await firestoreInstance
          .collection("users")
          .document(userIDList[i])
          .get()
          .then((value) {
        userNameList.insert(i, value.data["username"]);
      });
    }
    partnerIndex = 11;
    notifyListeners();
  }
}

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: MaterialApp(
        color: Colors.lightBlue,
        home: StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.on) {
                return FindDevicesScreen();
              }
              return BluetoothOffScreen(state: state);
            }),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Splash Screen'),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text('Find Your Cuitt'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  d.discoverServices();
                                  return RaisedButton(
                                    child: Text('OPEN'),
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DeviceScreen(device: d))),
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map(
                        (r) => ScanResultTile(
                            result: r,
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                r.device.connect();
                                return DeviceScreen(device: r.device);
                              }));
                            }),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 55,
            margin: EdgeInsets.only(right: 10),
            child: FloatingActionButton.extended(
              heroTag: 'btn1',
              backgroundColor: Colors.greenAccent,
              label: Text('Partner'),
              onPressed: () {},
            ),
          ),
          StreamBuilder<bool>(
            stream: FlutterBlue.instance.isScanning,
            initialData: false,
            builder: (c, snapshot) {
              if (snapshot.data) {
                return FloatingActionButton(
                  heroTag: 'btn2',
                  child: Icon(Icons.stop),
                  onPressed: () => FlutterBlue.instance.stopScan(),
                  backgroundColor: Colors.red,
                );
              } else {
                return FloatingActionButton(
                    heroTag: 'btn2',
                    child: Icon(Icons.search),
                    backgroundColor: Colors.greenAccent,
                    onPressed: () => FlutterBlue.instance
                        .startScan(timeout: Duration(seconds: 4)));
              }
            },
          ),
        ],
      ),
    );
  }
}

List<double> hitLengthArray = [];
List<int> timestampArray = [];
var drawCountIndex = 0;
var hitTimeNow;
var hitTimeThen;
var timeUntilNext;
var decay = 0.95;
var dayNum = 1;
var drawLength;
var currentTime;
var waitPeriod;
var timeBetween;
var timeBetweenAverage;
var drawCountAverage;
double drawLengthTotal = 0;
var drawLengthTotalYest;
double drawLengthTotalAverage;
double drawLengthAverage = 0;
var drawLengthAverageYest;
var drawCount = 0;
var seshCount = 0;
var seshCountAverage;
var drawCountYest = 0;
var seshCountYest = 0;
var suggestion;

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    Color _locIconColor = Colors.white;
    Color _setIconColor = Colors.white;
    Color _partIconColor = Colors.white;
    Color _infoIconColor = Colors.white;
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _locIconColor = Colors.white;
          _setIconColor = Colors.white;
          _partIconColor = Colors.white;
          _infoIconColor = Colors.white;
          currentIndex = 2;
          appState.update();
        },
        child: Icon(
          Icons.timeline,
          color: Colors.white,
        ),
        backgroundColor: Colors.greenAccent,
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.white12,
        notchMargin: 2.0,
        child: Consumer<AppState>(builder: (context, appState, child) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _infoIconColor = Colors.greenAccent;
                    _locIconColor = Colors.white;
                    _setIconColor = Colors.white;
                    _partIconColor = Colors.white;
                    currentIndex = 4;
                    appState.update();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    height: 50,
                    width: 55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _infoIconColor,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Info',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _infoIconColor = Colors.white;
                    _locIconColor = Colors.greenAccent;
                    _setIconColor = Colors.white;
                    _partIconColor = Colors.white;
                    currentIndex = 3;
                    appState.update();
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 35),
                    padding: EdgeInsets.symmetric(vertical: 4),
                    height: 50,
                    width: 55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          color: _locIconColor,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Location',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _infoIconColor = Colors.white;
                    _locIconColor = Colors.white;
                    _setIconColor = Colors.white;
                    _partIconColor = Colors.greenAccent;
                    currentIndex = 1;
                    appState.update();
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 35),
                    padding: EdgeInsets.symmetric(vertical: 4),
                    height: 50,
                    width: 55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.people,
                          color: _partIconColor,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Partner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _infoIconColor = Colors.white;
                    _locIconColor = Colors.white;
                    _setIconColor = Colors.greenAccent;
                    _partIconColor = Colors.white;
                    currentIndex = 0;
                    appState.update();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    height: 50,
                    width: 55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.settings,
                          color: _setIconColor,
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                print('Snapshot data is empty?: ' +
                    snapshot.data.isEmpty.toString());
                void readChar() async {
                  await snapshot.data
                      .elementAt(2)
                      .characteristics
                      .elementAt(0)
                      .setNotifyValue(true);
                  snapshot.data
                      .elementAt(2)
                      .characteristics
                      .elementAt(0)
                      .value
                      .listen((value) {
                    currentTime = int.parse(
                        hex.encode(value.sublist(0, 4)).toString(),
                        radix: 16);
                    drawLength = int.parse(
                            hex.encode(value.sublist(4, 6)).toString(),
                            radix: 16) /
                        1000;
                    drawCount = int.parse(
                        hex.encode(value.sublist(6, 8)).toString(),
                        radix: 16);
                    seshCount = int.parse(
                        hex.encode(value.sublist(8, 10)).toString(),
                        radix: 16);
                    drawLengthTotal += drawLength;
                    drawLengthTotal.toStringAsPrecision(1);
                    drawLengthAverage = drawLengthTotal / drawCount;
                    drawLengthAverage.toStringAsPrecision(1);
                    drawLengthTotalAverage = drawLengthTotal /
                        dayNum; //CHANGE TO CALCULATION ARRAY FOR DLT BY DAY
                    drawCountAverage = drawCount /
                        dayNum; //CHANGE TO CALCULATION ARRAY FOR DCT BY DAY
                    seshCountAverage = seshCount /
                        dayNum; //CHANGE TO CALCULATION ARRAY FOR DCT BY DAY
                    suggestion =
                        drawLengthTotalAverage / drawCountAverage * decay;
                    hitTimeThen = hitTimeNow;
                    hitTimeNow = currentTime;
                    waitPeriod = 16 / seshCountAverage * 60 * 60;
                    timeBetween = hitTimeNow - hitTimeThen;
                    timeUntilNext = waitPeriod - timeBetween;
                    hitLengthArray.add(drawLength);
                    timestampArray.add(currentTime);
                    /*
                    for (drawCountIndex; drawCountIndex > 0; drawCountIndex--) {
                      hitLengthArray.insert(drawCountIndex, drawLength);
                      timestampArray.insert(drawCountIndex, currentTime);
                    }
                    */
                    drawCountIndex++;
                    fill = drawLengthTotal;
                    over = drawLengthTotal - drawLengthTotalAverage;
                    if (over < 0) {
                      over = 0;
                    }
                    //unfilled = drawLengthTotalAverage - drawLengthTotal;
                    appState.update();
                  });
                  print('readChar');
                }

                if (snapshot.data.isEmpty) {
                  drawLength = 0;
                  timeBetween = 0;
                  timeBetweenAverage = 0;
                  drawLengthTotal = 0;
                  drawLengthTotalAverage = 0;
                  drawLengthAverage = 0;
                  //appState.update();
                  return SplashScreen(); //first run only displays SplashScreen because snapshot.data is empty and remains empty
                } else {
                  readChar();
                  return Consumer<AppState>(
                      builder: (context, appState, child) {
                    return pages[currentIndex];
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(BlueDash());

abstract class CounterBlocEvent {}

class UpdateDataEvent extends CounterBlocEvent {
  //overide this method when class extends equatable

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class IncreaseCounterEvent extends CounterBlocEvent {
//overide this method when class extends equatable

  @override
  // TODO: implement props
  List<Object> get props => [];
}

abstract class CounterBlocState {}

class LatestCounterState extends CounterBlocState {
  final int newCounterValue;

  LatestCounterState({this.newCounterValue});

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [newCounterValue];
}

class DataState extends CounterBlocState {
  final int newDrawCountValue;
  final int newSeshCountValue;
  final double newDrawLengthValue;
  final int newDrawLengthTotalValue;
  final int newAverageDrawLengthValue;
  final int newAverageDrawLengthTotalValue;

  DataState(
      {this.newDrawCountValue,
      this.newSeshCountValue,
      this.newDrawLengthValue,
      this.newDrawLengthTotalValue,
      this.newAverageDrawLengthValue,
      this.newAverageDrawLengthTotalValue});

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [newDrawCountValue];
}

class CounterBloc extends Bloc<CounterBlocEvent, CounterBlocState> {
  //Set Initial State of Counter Bloc by return the LatestCounterState Object with newCounterValue = 0
  @override
  // TODO: implement initialState
  CounterBloc() : super(DataState(
    newDrawCountValue: 0,
    newSeshCountValue: 0,
    newDrawLengthValue: 0,
    newDrawLengthTotalValue: 0,
    newAverageDrawLengthValue: 0,
    newAverageDrawLengthTotalValue: 0,
  ));

  @override
  Stream<CounterBlocState> mapEventToState(CounterBlocEvent event) async* {
    // TODO: implement mapEventToState
    if (event is IncreaseCounterEvent) {
      //Fetching Current Counter Value From Current State
      int currentCounterValue = (state as LatestCounterState).newCounterValue;

      //Applying business Logic
      int newCounterValue = currentCounterValue + 1;

      //Adding new state to the Stream, yield is used to add state to the stream
      yield LatestCounterState(newCounterValue: newCounterValue);
    } else if (event is UpdateDataEvent) {
      //Fetching Current Counter Value From Current State
      int currentDrawCountValue = (state as DataState).newDrawCountValue;
      int currentSeshCountValue = (state as DataState).newSeshCountValue;
      double currentDrawLengthValue = (state as DataState).newDrawLengthValue;
      int currentDrawLengthTotalValue = (state as DataState)
          .newDrawLengthTotalValue;
      int currentAverageDrawLengthValue = (state as DataState)
          .newAverageDrawLengthValue;
      int currentAverageDrawLengthTotalValue = (state as DataState)
          .newAverageDrawLengthTotalValue;

      //Applying business Logic
      int newDrawCountValue = drawCount;
      int newSeshCountValue = seshCount;
      double newDrawLengthValue = drawLength;
      int newDrawLengthTotalValue = drawLengthTotal.truncate();
      int newAverageDrawLengthValue = drawLengthAverage.truncate();
      int newDrawLengthTotalAverageValue = drawLengthTotalAverage.truncate();
      print('NEW DRAW COUNT FROM BLOC: ' + newDrawLengthValue.toString());

      //Adding new state to the Stream, yield is used to add state to the stream
      yield DataState(
        newDrawCountValue: newDrawCountValue,
        newSeshCountValue: newSeshCountValue,
        newDrawLengthValue: newDrawLengthValue,
        newDrawLengthTotalValue: newDrawLengthTotalValue,
        newAverageDrawLengthValue: newAverageDrawLengthValue,
        newAverageDrawLengthTotalValue: newDrawLengthTotalAverageValue,
      );
    }
  }
}
/*
class CounterScreen extends StatefulWidget {
  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  //Used to add events in to Bloc
  CounterBloc _counterBlocSink;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    //Close the Stream Sink when the widget is disposed
    _counterBlocSink?.close();
  }

  @override
  Widget build(BuildContext context) {
    //Initializing Bloc Sink by using BlocProvider
    _counterBlocSink = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Counter App"),
        ),
        body: Container(
            width: double.infinity,
            child: BlocBuilder<CounterBloc, CounterBlocState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        "You have clicked ${(state as LatestCounterState).newCounterValue} Times"),
                    SizedBox(
                      height: 16,
                    ),
                    FlatButton(
                      child: Text("Increase Counter"),
                      onPressed: () {
                        //Send Decrease Counter EVent to the Bloc
                        _counterBlocSink.add(IncreaseCounterEvent());
                      },
                      color: Colors.redAccent,
                      textColor: Colors.white,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    FlatButton(
                      child: Text("Decrease Counter"),
                      onPressed: () {
                        //Send Decrease Counter EVent to the Bloc
                        _counterBlocSink.add(UpdateDataEvent());
                      },
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                  ],
                );
              },
            )));
  }
}/
class BlocTest extends StatefulWidget {
  @override
  _BlocTestState createState() => _BlocTestState();
}

class _BlocTestState extends State<BlocTest> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<CounterBloc>(
        create: (context) => CounterBloc(),
        child: Scaffold(
          backgroundColor: Background,
          body: CounterScreen(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CounterBloc _counterBlocSink;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    //Close the Stream Sink when the widget is disposed
    _counterBlocSink?.close();
  }

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothCharacteristic _ledChar;
  var _myService = "00001523-1212-efde-1523-785feabcd123";
  var _myChar = "00001524-1212-efde-1523-785feabcd123";
  var _readval;
  var _lastval;

  bool _getLEDChar(List<BluetoothService> services) {
    print('Getting Characteristic...');
    for (BluetoothService s in services) {
      if (s.uuid.toString() == _myService) {
        var characteristics = s.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == _myChar) {
            print('SAVED CHARACTERISTIC');
            _ledChar = c;
            _listener();
            return true;
          }
        }
      }
    }
    return false;
  }

  void _connectDevice(BluetoothDevice device) async {
    await print('Connecting...');
    flutterBlue.stopScan();
    try {
      await device.connect();
    } catch (e) {
      if (e.code != 'already_connected') {
        throw e;
      }
    } finally {
      List<BluetoothService> services = await device.discoverServices();
      _getLEDChar(services);
    }
  }

  //READ VALUE B DOES NOT RUN, LISTENER ONLY RUNS UNTIL READ VALUE A.
  //DATA IN CALCULATIONS CALLS UPON NULL VALUES
  //IF CALCULATIONS FUNCTION IS REMOVED THEN READ VALUE A AND B RUN
  //IF AWAIT USED FOR CALCULATIONS AND PRINT STATEMENTS THEN
  void _listener() {
    _ledChar.setNotifyValue(true);
    _ledChar.value.listen((event) async {
      if (_ledChar == null) {
        print('READ VALUE IS NULL');
      } else {
        _readval = await _ledChar.read();
        if (_readval.toString() == _lastval.toString()) {
          print('READ VALUE A = ' + _readval.toString());
          print('DRAW COUNT = ' + drawCount.toString());
          print('SESH COUNT = ' + seshCount.toString());
          print('CURRENT TIME = ' + currentTime.toString());
          print('DRAW LENGTH = ' + drawLength.toString());
          print(
              'DRAW LENGTH TOTAL = ' + drawLengthTotal.toStringAsPrecision(1));
        } else {
          print('READ VALUE A = ' + _readval.toString());
          currentTime = int.parse(
              hex.encode(_readval.sublist(0, 4)).toString(),
              radix: 16);
          drawLength = int.parse(
              hex.encode(_readval.sublist(4, 6)).toString(),
              radix: 16) /
              1000;
          drawCount = int.parse(
              hex.encode(_readval.sublist(6, 8)).toString(),
              radix: 16);
          seshCount = int.parse(
              hex.encode(_readval.sublist(8, 10)).toString(),
              radix: 16);
          drawLengthTotal += drawLength;
          drawLengthAverage = drawLengthTotal / drawCount;

          drawLengthTotalAverage = drawLengthTotal /
              dayNum; //CHANGE TO CALCULATION ARRAY FOR DLT BY DAY
          drawCountAverage = drawCount /
              dayNum; //CHANGE TO CALCULATION ARRAY FOR DCT BY DAY
          seshCountAverage = seshCount /
              dayNum; //CHANGE TO CALCULATION ARRAY FOR DCT BY DAY
          suggestion =
              drawLengthTotalAverage / drawCountAverage * decay;
          if (hitTimeNow == null) {
            hitTimeNow = currentTime;
          } else {
            hitTimeThen = hitTimeNow;
            hitTimeNow = currentTime;
          }
          waitPeriod = 16 / seshCountAverage * 60 * 60;
          timeBetween = hitTimeNow - hitTimeThen;
          timeUntilNext = waitPeriod - timeBetween;
          hitLengthArray.add(drawLength);
          timestampArray.add(currentTime);
          /*
          for (drawCountIndex; drawCountIndex > 0; drawCountIndex--) {
            hitLengthArray[drawCountIndex] = drawLength;
            timestampArray[drawCountIndex] = currentTime;
          }
           */
          drawCountIndex++;
          fill = drawLengthTotal.truncate();
          over = drawLengthTotal.truncate() - drawLengthTotalAverage.truncate();
          _counterBlocSink.add(UpdateDataEvent());
          print('DRAW COUNT = ' + drawCount.toString());
          print('SESH COUNT = ' + seshCount.toString());
          print('CURRENT TIME = ' + currentTime.toString());
          print('DRAW LENGTH = ' + drawLength.toString());
          print('DRAW LENGTH TOTAL = ' + drawLengthTotal.truncate().toString());
          _lastval = _readval;
        }
      }
    });
  }

  void _onread() async {
    _readval = await _ledChar.read();
    print('READ VALUE = ' + _readval.toString());
  }

  void _scanForDevice() {
    print('Scanning...');
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.name == "Cuitt") {
          _connectDevice(result.device);
        }
      }
    });

    flutterBlue.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          width: double.infinity,
          child: BlocBuilder<CounterBloc, CounterBlocState>(
              builder: (context, state) {
            _counterBlocSink = BlocProvider.of<CounterBloc>(context);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      "Draws: ${(state as DataState).newDrawCountValue}"),
                  FloatingActionButton(
                    onPressed: () {
                      _ledChar.write([0xff, 0xff, 0xff, 0x10]);
                    },
                    tooltip: 'Increment',
                    child: Icon(Icons.add_circle),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      _onread();
                    },
                    tooltip: 'Listen',
                    child: Icon(Icons.add_circle),
                  ),
                ],
              ),
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _scanForDevice,
          tooltip: 'Increment',
          child: Icon(Icons.bluetooth_searching),
        ),
      ),
    );
  }
}
*/

class BlueDash extends StatefulWidget {
  @override
  _BlueDashState createState() => _BlueDashState();
}

class _BlueDashState extends State<BlueDash> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: introPages,
    );
  }
}

/*
class Cuitt extends StatefulWidget {
  @override
  _CuittState createState() => _CuittState();
}

class _CuittState extends State<Cuitt> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ConnectDevice(),
    );
  }
}
*/
//the static Method that can convert from unix timestamp to DateTime: DateTime.fromMillisecondsSinceEpoch(unixstamp);
//DS3231Time + 946684800 = UnixTime
//int unixTime;
//current_time + 946684800 = UnixTime
//hitTime = DateTime.fromMillisecondsSinceEpoch(UnixTime);
//overviewData.add(OData(hitTime,draw_length));
//convert graph domain to DateTime
//current viewport is DateTime now
//domain part of data is DateTime
