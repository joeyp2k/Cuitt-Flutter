import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class UsageData {
  final DateTime time;
  final double seconds;

  UsageData(this.time, this.seconds);
}

var time = [];
var timeDay = [];
List<double> sec = [];
var i = 0;
int firstRun = 1;
int n = 1;

var dateFormat = DateFormat.j();

DateTime viewport = DateTime.now();
DateTime timeData;
DateTimeIntervalType transitionLabel = DateTimeIntervalType.hours;
DateTime viewportHour =
    DateTime(viewport.year, viewport.month, viewport.day, viewport.hour)
        .toLocal();

DateTime viewportDay =
    DateTime(viewport.year, viewport.month, viewport.day).toLocal();

DateTime viewportMonth = DateTime(viewport.year, viewport.month).toLocal();

DateTime viewportSelectionStart = viewportHour;
DateTime viewportSelectionEnd = viewportHour.add(Duration(hours: 11));

var dataSelection = dayData;

var dayData = [
  UsageData(viewportHour, 0),
  UsageData(viewportHour.add(Duration(hours: 1)), 0),
  UsageData(viewportHour.add(Duration(hours: 2)), 0),
  UsageData(viewportHour.add(Duration(hours: 3)), 0),
  UsageData(viewportHour.add(Duration(hours: 4)), 0),
  UsageData(viewportHour.add(Duration(hours: 5)), 0),
  UsageData(viewportHour.add(Duration(hours: 6)), 0),
  UsageData(viewportHour.add(Duration(hours: 7)), 0),
  UsageData(viewportHour.add(Duration(hours: 8)), 0),
  UsageData(viewportHour.add(Duration(hours: 9)), 0),
  UsageData(viewportHour.add(Duration(hours: 10)), 0),
  UsageData(viewportHour.add(Duration(hours: 11)), 0),
];

//TODO: Implement data and switching viewport

var weekData = [
  //data by day
  UsageData(viewportDay, 0),
  UsageData(viewportDay.add(Duration(days: 1)), 0),
  UsageData(viewportDay.add(Duration(days: 2)), 0),
  UsageData(viewportDay.add(Duration(days: 3)), 0),
  UsageData(viewportDay.add(Duration(days: 4)), 0),
  UsageData(viewportDay.add(Duration(days: 5)), 0),
  UsageData(viewportDay.add(Duration(days: 6)), 0),
  UsageData(viewportDay.add(Duration(days: 7)), 0),
  UsageData(viewportDay.add(Duration(days: 8)), 0),
  UsageData(viewportDay.add(Duration(days: 9)), 0),
  UsageData(viewportDay.add(Duration(days: 10)), 0),
  UsageData(viewportDay.add(Duration(days: 11)), 0),
];

var yearData = [
  //data by month
  UsageData(DateTime(viewport.year, 1), 0),
  UsageData(DateTime(viewport.year, 2), 0),
  UsageData(DateTime(viewport.year, 3), 0),
  UsageData(DateTime(viewport.year, 4), 0),
  UsageData(DateTime(viewport.year, 5), 0),
  UsageData(DateTime(viewport.year, 6), 0),
  UsageData(DateTime(viewport.year, 7), 0),
  UsageData(DateTime(viewport.year, 8), 0),
  UsageData(DateTime(viewport.year, 9), 0),
  UsageData(DateTime(viewport.year, 10), 0),
  UsageData(DateTime(viewport.year, 11), 0),
  UsageData(DateTime(viewport.year, 12), 0),
];