import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class UsageData {
  final DateTime time;
  final double seconds;

  UsageData(this.time, this.seconds);
}

bool progress;

var time = [];
var timeDay = [];
List<double> sec = [];
var i = 0;
int firstRun = 1;
int n = 1;

//Chart label formatting
var dateFormat = DateFormat.j();
String tooltipFormat = 'j';
int maximumLabel = 5;

//Chart viewport selection
DateTime viewport = DateTime.now();
DateTime timeData;
DateTimeIntervalType transitionLabel = DateTimeIntervalType.hours;
DateTime viewportHour =
    DateTime(viewport.year, viewport.month, viewport.day, viewport.hour)
        .toLocal();

DateTime viewportDay =
    DateTime(viewport.year, viewport.month, viewport.day).toLocal();

DateTime viewportMonth = DateTime(viewport.year, viewport.month).toLocal();

DateTime viewportSelectionEnd = viewportHour.add(Duration(minutes: 30));
DateTime viewportSelectionStart =
    viewportHour.subtract(Duration(hours: 11, minutes: 30));

var graphIndex = 0;

//Dashboard chart timeframe selection
var dataSelection = dayData;

//Data for user overview charts
var overviewData = [];
var userOverview = [];

var dayData = [
  //data by hour
  UsageData(viewportHour, 0),
  UsageData(viewportHour.subtract(Duration(hours: 1)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 2)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 3)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 4)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 5)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 6)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 7)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 8)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 9)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 10)), 0),
  UsageData(viewportHour.subtract(Duration(hours: 11)), 0),
];

var weekData = [
  //data by day
  UsageData(viewportDay, 0),
  UsageData(viewportDay.subtract(Duration(days: 1)), 0),
  UsageData(viewportDay.subtract(Duration(days: 2)), 0),
  UsageData(viewportDay.subtract(Duration(days: 3)), 0),
  UsageData(viewportDay.subtract(Duration(days: 4)), 0),
  UsageData(viewportDay.subtract(Duration(days: 5)), 0),
  UsageData(viewportDay.subtract(Duration(days: 6)), 0),
];

var monthData = [
  //data by day
  UsageData(viewportDay, 0),
  UsageData(viewportDay.subtract(Duration(days: 1)), 0),
  UsageData(viewportDay.subtract(Duration(days: 2)), 0),
  UsageData(viewportDay.subtract(Duration(days: 3)), 0),
  UsageData(viewportDay.subtract(Duration(days: 4)), 0),
  UsageData(viewportDay.subtract(Duration(days: 5)), 0),
  UsageData(viewportDay.subtract(Duration(days: 6)), 0),
  UsageData(viewportDay.subtract(Duration(days: 7)), 0),
  UsageData(viewportDay.subtract(Duration(days: 8)), 0),
  UsageData(viewportDay.subtract(Duration(days: 9)), 0),
  UsageData(viewportDay.subtract(Duration(days: 10)), 0),
  UsageData(viewportDay.subtract(Duration(days: 11)), 0),
  UsageData(viewportDay.subtract(Duration(days: 12)), 0),
  UsageData(viewportDay.subtract(Duration(days: 13)), 0),
  UsageData(viewportDay.subtract(Duration(days: 14)), 0),
  UsageData(viewportDay.subtract(Duration(days: 15)), 0),
  UsageData(viewportDay.subtract(Duration(days: 16)), 0),
  UsageData(viewportDay.subtract(Duration(days: 17)), 0),
  UsageData(viewportDay.subtract(Duration(days: 18)), 0),
  UsageData(viewportDay.subtract(Duration(days: 19)), 0),
  UsageData(viewportDay.subtract(Duration(days: 20)), 0),
  UsageData(viewportDay.subtract(Duration(days: 21)), 0),
  UsageData(viewportDay.subtract(Duration(days: 22)), 0),
  UsageData(viewportDay.subtract(Duration(days: 23)), 0),
  UsageData(viewportDay.subtract(Duration(days: 24)), 0),
  UsageData(viewportDay.subtract(Duration(days: 25)), 0),
  UsageData(viewportDay.subtract(Duration(days: 26)), 0),
  UsageData(viewportDay.subtract(Duration(days: 27)), 0),
  UsageData(viewportDay.subtract(Duration(days: 28)), 0),
  UsageData(viewportDay.subtract(Duration(days: 29)), 0),
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