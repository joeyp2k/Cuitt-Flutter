import 'package:cuitt/bloc/dashboard_bloc.dart';
import 'package:cuitt/presentation/design_system/colors.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class ScratchBoard extends StatefulWidget {
  @override
  _ScratchBoardState createState() => _ScratchBoardState();
}

class _ScratchBoardState extends State<ScratchBoard> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
        baseColor: Color(0xFF332158),
        lightSource: LightSource.top,
        depth: 3,
        intensity: 0.5,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 6,
      ),
      home: MyHomePage(),
    );
  }
}

class AnimatedRadialChart extends StatefulWidget {
  @override
  _AnimatedRadialChartState createState() => new _AnimatedRadialChartState();
}

class _AnimatedRadialChartState extends State<AnimatedRadialChart> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
  new GlobalKey<AnimatedCircularChartState>();
  final _chartSize = const Size(350.0, 350.0);

  double usage = 50;

  void _update() {
    setState(() {
      if (drawLengthTotal == 0) {
        usage = 0;
      } else {
        usage = (drawLengthTotalAverage / drawLengthTotal) *
            100; //percentage of allowed usage for chart
      }
      List<CircularStackEntry> data = _generateChartData(usage);
      _chartKey.currentState.updateData(data);
    });
  }

  List<CircularStackEntry> _generateChartData(double usage) {
    Color dialColor = Green;

    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            usage,
            dialColor,
          )
        ],
      ),
    ];

    if (usage > 100) {
      data.add(new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            usage - 100,
            Red,
          ),
        ],
      ));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          child: new AnimatedCircularChart(
            key: _chartKey,
            size: _chartSize,
            initialChartData: _generateChartData(usage),
            chartType: CircularChartType.Radial,
            edgeStyle: SegmentEdgeStyle.round,
            percentageValues: true,
            holeRadius: 75,
          ),
        ),
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: NeumorphicFloatingActionButton(
        child: Icon(Icons.add, size: 30),
        onPressed: () {},
      ),
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NeumorphicButton(
              onPressed: () {
                print("onClick");
              },
              style: NeumorphicStyle(
                shape: NeumorphicShape.flat,
                boxShape: NeumorphicBoxShape.circle(),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                Icons.favorite_border,
                color: _iconsColor(context),
              ),
            ),
            NeumorphicButton(
                margin: EdgeInsets.only(top: 12),
                onPressed: () {
                  NeumorphicTheme
                      .of(context)
                      .themeMode =
                  NeumorphicTheme.isUsingDark(context)
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape:
                  NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Toggle Theme",
                  style: TextStyle(color: _textColor(context)),
                )),
            NeumorphicButton(
                margin: EdgeInsets.only(top: 12),
                onPressed: () {

                },
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape:
                  NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                  //border: NeumorphicBorder()
                ),
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Go to full sample",
                  style: TextStyle(color: _textColor(context)),
                )),
            NeumorphicButton(
                margin: EdgeInsets.only(top: 12),
                onPressed: () {},
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape:
                  NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                ),
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 150,
                  width: 150,
                  child: Text(
                    "Toggle Theme",
                    style: TextStyle(color: _textColor(context)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _iconsColor(BuildContext context) {
    final theme = NeumorphicTheme.of(context);
    if (theme.isUsingDark) {
      return theme.current.accentColor;
    } else {
      return null;
    }
  }

  Color _textColor(BuildContext context) {
    if (NeumorphicTheme.isUsingDark(context)) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
}
