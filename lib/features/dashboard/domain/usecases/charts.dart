import 'dart:async';

import 'package:cuitt/core/design_system/colors.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_dial_data.dart';

class UpdateChart {
  Timer timer;

  //get current time
  void _timeUpdate() {
    timeData = DateTime.now();

    viewportHour =
        DateTime(timeData.year, timeData.month, timeData.day, timeData.hour)
            .toLocal();

    //adjust viewport as first twelve entries are added to day data

    viewportDay =
        DateTime(timeData.year, timeData.month, timeData.day).toLocal();

    //adjust viewport as first seven entries are added to month data

    viewportMonth = DateTime(timeData.year, timeData.month).toLocal();

    //adjust viewport as first thirty entries are added to month data

    timeData =
        DateTime(timeData.year, timeData.month, timeData.day, timeData.hour)
            .toLocal();
  }

  //if there is no data, initialize by adding first values to time and seconds array
  void _ifNoData() {
    if (time.isEmpty) {
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
      timeMonth.add(DateTime(timeData.year, timeData.month).toLocal());
    }

    if (sec.isEmpty) {
      sec.add(0);
    }
  }

  //increment the current seconds index and update dayData and monthData
  void _update() {
    sec[graphIndex] += drawLength;
    hourData[graphIndex] = UsageData(time[graphIndex], sec[graphIndex]);
    dayData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
    monthData[graphIndex] = UsageData(timeMonth[graphIndex], sec[graphIndex]);
    //monthData using current month, not i
  }
  void _add() {
    graphIndex++;
    //add new index to seconds and time array and update dayData and monthData if condition is true
    if (hourData.length <= graphIndex) {
      sec.add(drawLength);
      time.add(timeData);
      hourData.add(UsageData(time[graphIndex], sec[graphIndex]));
      dayData.add(UsageData(timeDay[graphIndex], sec[graphIndex]));
      monthData.add(UsageData(timeMonth[graphIndex], sec[graphIndex]));
    } else {
      //otherwise add new index to seconds, time, and day array, and update dayData and monthData
      sec.add(drawLength);
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
      timeMonth.add(DateTime(timeData.year, timeData.month).toLocal());
      hourData[graphIndex] = UsageData(time[graphIndex], sec[graphIndex]);
      dayData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
      monthData[graphIndex] = UsageData(timeMonth[graphIndex], sec[graphIndex]);
    }
  }

  void updateChart() {
    _timeUpdate();
    _ifNoData();
    if (timeData == time[graphIndex]) {
      _update();
    } else {
      _add();
    }
  }

  void updateDial() {
    if (fill > drawLengthTotalAverageYest) {
      over += drawLength;
    } else {
      fill += drawLength;
    }
    data[1] = DialData("fill", fill, Green);
    data[0] = DialData("over", over, Red);
    drawLengthLast = drawLength;
    chartSet = false;
    newDraw = true;
  }
}
