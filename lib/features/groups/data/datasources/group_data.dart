import 'user_chart_data.dart';

var userList = [];
var userIDList = [];
var userNameList = [];
var userSeconds = [];
var userSecondsYest = [];
var userSecondsChange = [];
var userChangeSymbol = [];
var userDraws = [];
var userAverage = [];
var userAverageYest = [];
var userTimeBetweenAvg = [];
var userHourPlotTime = [];
var userHourPlotTotal = [];
var userDayPlotTime = [];
var userDayPlotTotal = [];
var userMonthPlotTime = [];
var userMonthPlotTotal = [];
var userHourPlots = [];
var userDayPlots = [];
var userMonthPlots = [];
var username;
var userSelection;
var userDataSelection;
int userAvgWaitTileSecs = 0;
int userAvgWaitTileMinutes = 0;
int userAvgWaitTileHours = 0;
List<UsageData> userData = [];
//TODO FIX GROUP DATA AND PLOTS
var groupPlots = [];
List<String> groupIDList = [];
var groupNameList = [];
var groupSeconds = [];
var groupSecondsYest = [];
var groupSecondsChange = [];
var groupChangeSymbol = [];
var groupAverage = [];
var groupAverageYest = [];
var groupDraws = [];
var groupPlotTime = [];
var groupPlotTotal = [];

var groupName;

var selection;
