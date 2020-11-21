final DateTime start = DateTime.now();
DateTime viewport = DateTime.now();
DateTime timeData;
DateTime viewportVal =
    DateTime(viewport.year, viewport.month, viewport.day, viewport.hour)
        .toLocal();

var time = [];
List<double> sec = [];
var i = 0;
int firstRun = 1;
int n = 1;

class UsageData {
  final DateTime time;
  final double seconds;

  UsageData(this.time, this.seconds);
}

var overviewData = [
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
