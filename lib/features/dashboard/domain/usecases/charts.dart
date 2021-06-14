import 'dart:async';

import 'package:cuitt/features/dashboard/data/datasources/my_chart_data.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';

class UpdateChart {
  Timer timer;

  void _timeUpdate() {
    timeData = DateTime.now();

    viewportHour =
        DateTime(timeData.year, timeData.month, timeData.day, timeData.hour)
            .toLocal();
    viewportDay =
        DateTime(timeData.year, timeData.month, timeData.day).toLocal();
    viewportMonth = DateTime(timeData.year, timeData.month).toLocal();

    timeData =
        DateTime(timeData.year, timeData.month, timeData.day, timeData.hour)
            .toLocal();
  }

  void _ifNoData() {
    if (time.isEmpty) {
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
    }

    if (sec.isEmpty) {
      sec.add(0);
    }
  }

  void _update() {
    sec[graphIndex] += drawLength;
    dayData[graphIndex] = UsageData(time[graphIndex], sec[graphIndex]);
    monthData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
    //monthData using current month, not i
  }

  void _add() {
    graphIndex++;
    if (dayData.length <= graphIndex) {
      sec.add(drawLength);
      time.add(timeData);
      dayData.add(UsageData(time[graphIndex], sec[graphIndex]));
      monthData.add(UsageData(timeDay[graphIndex], sec[graphIndex]));
    } else {
      sec.add(drawLength);
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
      dayData[graphIndex] = UsageData(time[graphIndex], sec[graphIndex]);
      monthData[graphIndex] = UsageData(timeDay[graphIndex], sec[graphIndex]);
    }
  }

  void _transmitData() {
    //TODO: IMPLEMENT TRANSMIT DATA
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
}
