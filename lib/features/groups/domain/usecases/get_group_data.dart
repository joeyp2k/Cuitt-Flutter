import 'package:cuitt/core/design_system/colors.dart';
import 'package:cuitt/features/connect_device/data/datasources/user_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:cuitt/features/groups/data/datasources/user_chart_data.dart';
import 'package:cuitt/features/groups/data/datasources/user_dial_data.dart';
import 'package:sqflite/sqflite.dart';

class GetGroupData {
  var userNameIndex;
  List<UsageData> groupData = [];

  Future<void> _getMyGroups() async {
    //generate display layer from local data
    //update local data and display layer with remote data

    var firebaseUser = FirebaseAuth.instance.currentUser;

    var groupRefs = await firestoreInstance
        .collection("groups")
        .where("members", arrayContains: firebaseUser.uid)
        .get();

    var groups = groupRefs.docs;

    //get group ids and names
    groups.forEach((group) {
      groupIDList.add(group.id);
      groupNameList.add(group["group name"]);
    });

    //generate group plots from local user data
    for (int i = 0; i < groupIDList.length; i++) {
      Map<DateTime, double> plots = {};
      groupDraws.add(0);
      groupSeconds.add(0.0);
      groupAverage.add(0.0);
      groupAverageYest.add(0.0);
      groupPlotTime.clear();
      groupPlotTotal.clear();
      var groupMembers = await firestoreInstance
          .collection("groups")
          .doc(groupIDList[i])
          .get();
      userIDList = groupMembers["members"];

      //query for users in local data
      final db = await userDatabase;
      for (int j = 0; j < userIDList.length; j++) {
        final List<Map<String, dynamic>> queryStats = await db.query(
          'userstats',
          where: '"userid" = ?',
          whereArgs: [userIDList[j]],
        );

        final List<Map<String, dynamic>> queryHour = await db.query(
          'userhour',
          where: '"userid" = ?',
          whereArgs: [userIDList[j]],
        );

        if (queryStats.isNotEmpty) {
          //load user stats
          groupDraws[i] += queryStats[0]["count"];
          groupSeconds[i] += queryStats[0]["drawLengthTotal"];
          groupAverage[i] += queryStats[0]["drawLengthTotalAverage"];
          groupAverageYest[i] += queryStats[0]["drawLengthTotalAverageYest"];
        } else {
          //check remote storage
          var stats = await firestoreInstance
              .collection("users")
              .doc(userIDList[j])
              .get();
          if (stats.exists) {
            //update local storage with remote
            var statInsert = StatInsert(
              userid: userIDList[j],
              drawCount: stats["draws"],
              drawLengthAverage: stats["draw length average"],
              drawLengthAverageYest: stats["draw length average yesterday"],
              drawLengthTotal: stats["draw length total"],
              drawLengthTotalYest: stats["draw length total yesterday"],
              drawLengthTotalAverage: stats["draw length total average"],
              drawLengthTotalAverageYest:
                  stats["draw length total average yesterday"],
              timeBetweenAverage: stats["time between average"],
            );
            await db.insert(
              'userstats',
              statInsert.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        if (queryHour.isNotEmpty) {
          //load user data into group plot
          for (int k = 0; k < queryHour.length; k++) {
            if (plots.containsKey(
                DateTime.fromMillisecondsSinceEpoch(queryHour[k]["hour"]))) {
              plots[DateTime.fromMillisecondsSinceEpoch(
                  queryHour[k]["hour"])] += queryHour[k]["drawLength"];
            } else {
              plots[DateTime.fromMillisecondsSinceEpoch(queryHour[k]["hour"])] =
                  queryHour[k]["drawLength"];
            }
          }

          //check remote storage for more recent user data starting with current time and ending at last key in plots
          var last = plots.keys.last;

          DateTime hourCheck = DateTime.now();
          hourCheck = DateTime(
              hourCheck.year, hourCheck.month, hourCheck.day, hourCheck.hour);
          while (hourCheck != last) {
            var hourDoc = await firestoreInstance
                .collection("users")
                .doc(userIDList[j])
                .collection("Hour")
                .doc(hourCheck.toIso8601String())
                .get();
            if (hourDoc.exists) {
              if (plots.containsKey(hourDoc["time"].toDate())) {
                plots[hourDoc["time"].toDate()] += hourDoc["drawLength"];
              } else {
                plots[hourDoc["time"].toDate()] = hourDoc["drawLength"];
              }
            }
            hourCheck = hourCheck.subtract(Duration(hours: 1));
          }

          var start = plots.keys.first;
          var value = DateTime(
              viewport.year, viewport.month, viewport.day, viewport.hour);

          if (plots.keys.length < 12) {
            start = start.subtract(Duration(hours: 11));
          }
          //fill in zeros for spaces between hours
          while (value != start || plots.keys.length < 12) {
            value = value.subtract(Duration(hours: 1));
            if (!plots.containsKey(value)) {
              plots[value] = 0.0;
            }
          }
        } else {
          //check remote storage
          var hourDataRef = await firestoreInstance
              .collection("users")
              .doc(userIDList[j])
              .collection("Hour")
              .get();
          var hourData = hourDataRef.docs;
          if (hourData.isNotEmpty) {
            //update local storage with remote
            for (int k = 0; k < hourData.length; k++) {
              var hourInsert = HourInsert(
                userid: userIDList[j],
                drawLength: hourData[k]["draw length total"],
                hour: hourData[k]["time"].toUtc().millisecondsSinceEpoch,
              );

              final List<Map<String, dynamic>> query = await db.query(
                'userhour',
                where: '"userid" = ? AND "hour" = ?',
                whereArgs: [
                  hourInsert.userid,
                  hourData[k]["time"].toUtc().millisecondsSinceEpoch
                ],
              );
              if (query.isNotEmpty) {
                //update user stats
                var id = query[0]["id"];
                var total = hourInsert.drawLength + query[0]["drawLength"];
                hourInsert.drawLength = total;
                hourInsert.id = id;
              }
              await db.insert(
                'userhour',
                hourInsert.toMap(),
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
            //update display layer with newly received remote data

            final List<Map<String, dynamic>> queryHour = await db.query(
              'userhour',
              where: '"userid" = ?',
              whereArgs: [userIDList[j]],
            );

            for (int k = 0; k < queryHour.length; k++) {
              if (plots.containsKey(
                  DateTime.fromMillisecondsSinceEpoch(queryHour[k]["hour"]))) {
                plots[DateTime.fromMillisecondsSinceEpoch(
                    queryHour[k]["hour"])] += queryHour[k]["drawLength"];
              } else {
                plots[DateTime.fromMillisecondsSinceEpoch(
                    queryHour[k]["hour"])] = queryHour[k]["drawLength"];
              }
            }
          }
        }
      }

      plots.keys.forEach((element) {
        groupPlotTime.add(element);
      });
      plots.values.forEach((element) {
        groupPlotTotal.add(element);
      });

      var change = groupSeconds[i] - groupAverageYest[i];
      groupSecondsChange.add(change);
      groupChangeSymbol.add("");

      if (groupPlotTime.isNotEmpty && groupPlotTotal.isNotEmpty) {
        groupData.clear();
        for (int i = 0; i < groupPlotTime.length; i++) {
          groupData.add(UsageData(groupPlotTime[i], groupPlotTotal[i]));
        }
        groupPlots.add(groupData);
      } else {
        groupPlots.add(null);
      }
    }
  }

  Future<void> _getUsers() async {
    userNameIndex = 0;

    var groupDoc = await firestoreInstance
        .collection("groups")
        .doc(selection)
        .get()
        .then((value) {
      userIDList = value["members"];
    });
    userNameIndex = userIDList.length;
  }

  Future<void> _loadUserData() async {
    for (int i = 0; i < userNameIndex; i++) {
      //get usernames in group
      var userDoc = await firestoreInstance
          .collection("users")
          .doc(userIDList[i])
          .get()
          .then((value) {
        userNameList.add(value["username"]);
      });
    }

    //get users data from local storage
    final db = await userDatabase;
    for (int i = 0; i < userIDList.length; i++) {
      Map<DateTime, double> plots = {};
      final List<Map<String, dynamic>> queryStats = await db.query(
        'userstats',
        where: '"userid" = ?',
        whereArgs: [userIDList[i]],
      );

      final List<Map<String, dynamic>> queryHour = await db.query(
        'userhour',
        where: '"userid" = ?',
        whereArgs: [userIDList[i]],
      );

      userSeconds.add(queryStats[i]["drawLengthTotal"]);
      userDraws.add(queryStats[i]["count"]);
      userAverageYest.add(queryStats[i]["drawLengthTotalAverageYest"]);
      userAverage.add(queryStats[i]["drawLengthTotalAverage"]);
      userTimeBetweenAvg.add(queryStats[i]["timeBetweenAverage"]);

      var change = userSeconds[i] - userAverageYest[i];
      userSecondsChange.add(change);
      userChangeSymbol.add("");
      //load users data into user plots
      for (int k = 0; k < queryHour.length; k++) {
        if (plots.containsKey(
            DateTime.fromMillisecondsSinceEpoch(queryHour[k]["hour"]))) {
          plots[DateTime.fromMillisecondsSinceEpoch(queryHour[k]["hour"])] +=
              queryHour[k]["drawLength"];
        } else {
          plots[DateTime.fromMillisecondsSinceEpoch(queryHour[k]["hour"])] =
              queryHour[k]["drawLength"];
        }
      }

      var start = plots.keys.first;
      var value =
          DateTime(viewport.year, viewport.month, viewport.day, viewport.hour);

      if (plots.keys.length < 12) {
        start = start.subtract(Duration(hours: 11));
      }
      //fill in zeros for spaces between hours
      while (value != start || plots.keys.length < 12) {
        value = value.subtract(Duration(hours: 1));
        if (!plots.containsKey(value)) {
          plots[value] = 0.0;
        }
      }

      userHourPlotTime.clear();
      userHourPlotTotal.clear();
      plots.keys.forEach((element) {
        userHourPlotTime.add(element);
      });
      plots.values.forEach((element) {
        userHourPlotTotal.add(element);
      });

      List<UsageData> hourInsert = [];
      if (userHourPlotTime.isNotEmpty && userHourPlotTotal.isNotEmpty) {
        for (int i = 0; i < userHourPlotTime.length; i++) {
          hourInsert.add(UsageData(userHourPlotTime[i], userHourPlotTotal[i]));
        }
        userHourPlots.add(hourInsert);
      } else {
        userHourPlots.add(null);
      }
    }
  }

  Future<void> prepareUserDashboard() async {
    var db = await userDatabase;

    userDataSelection = userHourPlots[userSelection];

    userAvgWaitTileSecs = userTimeBetweenAvg[userSelection].round() % 60;
    userAvgWaitTileMinutes =
        (userTimeBetweenAvg[userSelection].round() / 60).truncate();
    userAvgWaitTileHours =
        (userTimeBetweenAvg[userSelection].round() / 3600).truncate();

    fill = userSeconds[userSelection];
    over = userSeconds[userSelection] - userAverageYest[userSelection];
    if (over < 0) {
      over = 0;
    }
    data = [
      DialData('Over', over, Red),
      DialData('Fill', fill, Green),
    ];

    final List<Map<String, dynamic>> queryDays = await db.query(
      'userday',
      where: '"userid" = ?',
      whereArgs: [userIDList[userSelection]],
    );

    final List<Map<String, dynamic>> queryMonths = await db.query(
      'usermonth',
      where: '"userid" = ?',
      whereArgs: [userIDList[userSelection]],
    );

    //load user data into group plot
    Map<DateTime, double> days = {};
    for (int k = 0; k < queryDays.length; k++) {
      if (days.containsKey(
          DateTime.fromMillisecondsSinceEpoch(queryDays[k]["day"]))) {
        days[DateTime.fromMillisecondsSinceEpoch(queryDays[k]["day"])] +=
            queryDays[k]["drawLength"];
      } else {
        days[DateTime.fromMillisecondsSinceEpoch(queryDays[k]["day"])] =
            queryDays[k]["drawLength"];
      }
    }

    var start = days.keys.first;
    var value = DateTime(viewport.year, viewport.month, viewport.day);
    if (days.keys.length < 30) {
      start = start.subtract(Duration(days: 29));
    }
    //fill in zeros for spaces between days
    while (value != start || days.keys.length < 30) {
      value = value.subtract(Duration(days: 1));
      if (!days.containsKey(value)) {
        days[value] = 0.0;
      }
    }
    userDayPlotTime.clear();
    userDayPlotTotal.clear();
    days.keys.forEach((element) {
      userDayPlotTime.add(element);
    });
    days.values.forEach((element) {
      userDayPlotTotal.add(element);
    });
    userDayPlots.clear();
    List<UsageData> dayInsert = [];
    if (userDayPlotTime.isNotEmpty && userDayPlotTotal.isNotEmpty) {
      for (int i = 0; i < userDayPlotTime.length; i++) {
        dayInsert.add(UsageData(userDayPlotTime[i], userDayPlotTotal[i]));
      }
      userDayPlots.add(dayInsert);
    } else {
      userDayPlots.add(null);
    }

    //load user data into group plot
    Map<DateTime, double> months = {};
    for (int k = 0; k < queryMonths.length; k++) {
      if (months.containsKey(
          DateTime.fromMillisecondsSinceEpoch(queryMonths[k]["month"]))) {
        months[DateTime.fromMillisecondsSinceEpoch(queryMonths[k]["month"])] +=
            queryMonths[k]["drawLength"];
      } else {
        months[DateTime.fromMillisecondsSinceEpoch(queryMonths[k]["month"])] =
            queryMonths[k]["drawLength"];
      }
    }

    start = months.keys.first;
    value = DateTime(viewport.year, viewport.month);
    if (months.keys.length < 12) {
      start = DateTime(start.year, start.month - 11);
    }
    //fill in zeros for spaces between hours
    while (value != start || months.keys.length < 12) {
      value = DateTime(value.year, value.month - 1);
      if (!months.containsKey(value)) {
        months[value] = 0.0;
      }
    }

    userMonthPlotTime.clear();
    userMonthPlotTotal.clear();
    months.keys.forEach((element) {
      userMonthPlotTime.add(element);
    });
    months.values.forEach((element) {
      userMonthPlotTotal.add(element);
    });
    userMonthPlots.clear();
    List<UsageData> monthInsert = [];
    if (userMonthPlotTime.isNotEmpty && userMonthPlotTotal.isNotEmpty) {
      for (int i = 0; i < userMonthPlotTime.length; i++) {
        monthInsert.add(UsageData(userMonthPlotTime[i], userMonthPlotTotal[i]));
      }
      userMonthPlots.add(monthInsert);
    } else {
      userMonthPlots.add(null);
    }
  }

  Future<void> loadUsersInGroup() async {
    //get users in group
    userNameList.clear();
    userSeconds.clear();
    userAverage.clear();
    userAverageYest.clear();
    userSecondsChange.clear();
    userChangeSymbol.clear();
    userDraws.clear();
    userHourPlotTime.clear();
    userHourPlotTotal.clear();
    userHourPlots.clear();
    userDayPlotTime.clear();
    userDayPlotTotal.clear();
    userDayPlots.clear();
    userMonthPlotTime.clear();
    userMonthPlotTotal.clear();
    userMonthPlots.clear();
    userData.clear();

    await _getUsers();
    await _loadUserData();
  }

  Future<void> groups() async {
    groupNameList.clear();
    groupSeconds.clear();
    groupSecondsYest.clear();
    groupDraws.clear();
    groupSecondsChange.clear();
    groupChangeSymbol.clear();
    groupAverage.clear();
    groupAverageYest.clear();
    groupIDList.clear();
    groupPlotTime.clear();
    groupPlotTotal.clear();
    groupPlots.clear();
    groupData.clear();

    await _getMyGroups();
  }

  GetGroupData();
}

GetGroupData getGroupData = GetGroupData();
