import 'package:cuitt/features/dashboard/data/datasources/cloud.dart';
import 'package:cuitt/features/groups/data/datasources/group_data.dart';
import 'package:cuitt/features/groups/data/datasources/user_chart_data.dart';

class GetGroupData {
  var value;

  List<UsageData> groupData = [];

  Future<void> _getGroupsWithUser() async {
    var firebaseUser = FirebaseAuth.instance.currentUser;

    value = await firestoreInstance
        .collection("groups")
        .where("members", arrayContains: firebaseUser.uid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        groupIDList.add(element.id);
        groupNameList.add(element["group name"]);
        groupPlotTime = element["plot time"];
        groupPlotTotal = element["plot total"];

        if (groupPlotTime.isNotEmpty && groupPlotTotal.isNotEmpty) {
          groupData.clear();
          for (int i = 0; i < groupPlotTime.length; i++) {
            groupData.add(UsageData(
                groupPlotTime[i].toDate(), groupPlotTotal[i].toDouble()));
          }
          groupPlots.add(groupData);
        } else {
          groupPlots.add(null);
        }
      });
    });
    //fill plots with 12 entries for charts
    //TODO fill from right to left
    // for (int i = 0; i < groupPlots.length; i++) {
    //   if(groupPlots[i] != null){
    //     if (groupPlots[i].length == 12) {
    //       var lastTime = groupPlots[i].last.time;
    //       int adder = 0;
    //       for (int a = groupPlots[i].length; a < 12; a++) {
    //         adder++;
    //         print("ADDER: " + adder.toString());
    //         groupPlots[i].add(UsageData(lastTime.add(Duration(hours: adder)), 1));
    //         print(lastTime.toString());
    //       }
    //     }
    //   }
    // }
  }

  void _groupDataCalculations() {
    double sum = 0;
    int sumi = 0;

    userSeconds.forEach((element) {
      sum += element;
    });
    groupSeconds.add(sum);
    sum = 0;

    userAverage.forEach((element) {
      sum += element;
    });
    groupAverage.add(sum);
    sum = 0;

    userAverageYest.forEach((element) {
      sum += element;
    });
    groupAverageYest.add(sum);
    sum = 0;

    double change;
    for (int i = 0; i < groupAverageYest.length; i++) {
      change = groupSeconds[i] - groupAverageYest[i];
      if (change > 0) {
        groupChangeSymbol.add("+");
      } else {
        groupChangeSymbol.add("");
      }
      groupSecondsChange.add(change);
    }

    userDraws.forEach((element) {
      sumi += element;
    });
    groupDraws.add(sumi);
    sumi = 0;
  }

  Future<void> _loadGroupUsers() async {
    for (int i = 0; i < groupIDList.length; i++) {
      print(groupIDList[i].toString());
      value = await firestoreInstance
          .collection("groups")
          .doc(groupIDList[i])
          .get();
      print(value.data());
      userIDList = value["members"];
      print("Users: " + userIDList.toString());
      await _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    for (int i = 0; i < userIDList.length; i++) {
      print(userIDList[i].toString());
      value = await firestoreInstance
          .collection("users")
          .doc(userIDList[i])
          .collection("data")
          .doc("stats")
          .get()
          .then((value) {
        if (value.data() != null) {
          userSeconds.clear();
          userAverage.clear();
          userAverageYest.clear();
          userSecondsChange.clear();
          userDraws.clear();

          userSeconds.add(value["draw length total"]);
          userDraws.add(value["draws"]);
          userAverageYest.add(value["draw length average yesterday"]);
          userAverage.add(value["draw length average"]);

          _groupDataCalculations();
        }
      });
    }
  }

  Future<void> groups() async {
    print("CLEAR GROUP DATA");
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

    await _getGroupsWithUser();
    await _loadGroupUsers();
  }

  GetGroupData();
}

GetGroupData getGroupData = GetGroupData();
