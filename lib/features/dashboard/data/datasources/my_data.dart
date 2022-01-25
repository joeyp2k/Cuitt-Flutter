class User {
  String id;
  String firstName;
  String lastName;
  String numSec;
  String seconds = "seconds";
  String today = "today";
  String difference;
}

List<int> countWindow = List.generate(1, (index) => 0, growable: true);
List<double> totalWindow = List.generate(1, (index) => 0.0, growable: true);
var daysPassed = 0;
var drawCountIndex = 0;
int hitTimeNow = 0;
var hitTimeThen;
int timeUntilNext = 0;
var decay = 0.95;
var dayNum = 1;
double drawLength = 0;
double drawLengthLast = 0;
var newDraw = false;
var chartSet = true;
var currentTime = 0;
int waitPeriod;
int timeBetween = 0;
var timeBetweenAverage = 0.0;
int avgWaitTileSecs = 0;
int avgWaitTileMinutes = 0;
int avgWaitTileHours = 0;
var drawCountAverage;
double drawLengthTotal = 0;
double drawLengthTotalYest = 0;
double drawLengthTotalAverageYest = 73.0;
double drawLengthTotalAverage = 0;
double drawLengthAverage = 0;
double drawLengthAverageYest = 0;
var drawCount = 0;
var drawCountYest = 0;
var suggestion;

var buffer = [];
int transmitPointer = 0;