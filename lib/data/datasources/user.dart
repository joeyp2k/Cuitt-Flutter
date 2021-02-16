class User {
  String id;
  String firstName;
  String lastName;
  String numSec;
  String seconds = "seconds";
  String today = "today";
  String difference;
}

List<double> hitLengthArray = [];
List<int> timestampArray = [];
var drawCountIndex = 0;
int hitTimeNow = 0;
var hitTimeThen;
int timeUntilNext = 0;
var decay = 0.95;
var dayNum = 1;
double drawLength = 0;
var currentTime = 0;
int waitPeriod;
int timeBetween = 0;
var timeBetweenAverage = 0.0;
var drawCountAverage;
double drawLengthTotal = 0;
double drawLengthTotalYest = 0;
double drawLengthTotalAverageYest = 73.0;
double drawLengthTotalAverage = 0;
double drawLengthAverage = 0;
double drawLengthAverageYest = 0;
var drawCount = 0;
var seshCount = 0;
var seshCountAverage;
var drawCountYest = 0;
var seshCountYest = 0;
var suggestion;
double usage = 0;
double overUsage = 0;

int transmitPointer = 0;

bool sugLockValue = false;
bool limLockValue = false;
bool dataShareValue = false;

var userList = [];
var userIDList = [];
var userNameList = [];
var groupIDList = [];
var groupNameList = [];
var groupName;
var username;
var selection;
