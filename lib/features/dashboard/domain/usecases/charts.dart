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
    sec[i] += drawLength;
    dayData[i] = UsageData(time[i], sec[i]);
    monthData[i] = UsageData(timeDay[i], sec[i]);
    //monthData using current month, not i
  }

  void _add() {
    i++;
    if (dayData.length <= i) {
      sec.add(drawLength);
      time.add(timeData);
      dayData.add(UsageData(time[i], sec[i]));
      monthData.add(UsageData(timeDay[i], sec[i]));
    } else {
      sec.add(drawLength);
      time.add(timeData);
      timeDay
          .add(DateTime(timeData.year, timeData.month, timeData.day).toLocal());
      dayData[i] = UsageData(time[i], sec[i]);
      monthData[i] = UsageData(timeDay[i], sec[i]);
    }
  }

  void _transmitData() {
    //TODO: IMPLEMENT TRANSMIT DATA
  }

  void updateChart() {
    _timeUpdate();
    _ifNoData();
    if (timeData == time[i]) {
      _update();
    } else {
      _add();
    }
  }
}
