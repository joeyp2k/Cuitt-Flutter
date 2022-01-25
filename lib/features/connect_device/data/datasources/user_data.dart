var userDatabase;

class UserData {
  int id;
  final String userid;
  final int drawCount;
  final double drawLengthTotal;
  final double drawLengthTotalYest;
  final double drawLengthTotalAverageYest;
  final double drawLengthTotalAverage;
  final double drawLengthAverage;
  final double drawLengthAverageYest;

  UserData({
    this.id,
    this.userid,
    this.drawCount,
    this.drawLengthTotal,
    this.drawLengthTotalAverage,
    this.drawLengthTotalAverageYest,
    this.drawLengthTotalYest,
    this.drawLengthAverageYest,
    this.drawLengthAverage,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drawCount': drawCount,
      'drawLengthTotal': drawLengthTotal,
      'drawLengthTotalAverage': drawLengthTotalAverage,
      'drawLengthTotalAverageYest': drawLengthTotalAverageYest,
      'drawLengthTotalYest': drawLengthTotalYest,
      'drawLengthAverageYest': drawLengthAverageYest,
      'drawLengthAverage': drawLengthAverage,
    };
  }
}

class DayPlotData {
  int id;
  final String userid;
  final double plotTotal;
  final int plotTime;

  DayPlotData({
    this.id,
    this.userid,
    this.plotTotal,
    this.plotTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "plotTotal": plotTotal,
      "plotTime": plotTime,
    };
  }
}

class MonthPlotData {
  final int id;
  final double plotTotal;
  final int plotTime;

  MonthPlotData({
    this.id,
    this.plotTotal,
    this.plotTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "plotTotal": plotTotal,
      "plotTime": plotTime,
    };
  }
}

/////////////

class StatInsert {
  int id;
  final String userid;
  final int drawCount;
  final double drawLengthTotal;
  final double drawLengthTotalYest;
  final double drawLengthTotalAverageYest;
  final double drawLengthTotalAverage;
  final double drawLengthAverage;
  final double drawLengthAverageYest;
  final double timeBetweenAverage;

  StatInsert({
    this.id,
    this.userid,
    this.drawCount,
    this.drawLengthTotal,
    this.drawLengthTotalAverage,
    this.drawLengthTotalAverageYest,
    this.drawLengthTotalYest,
    this.drawLengthAverageYest,
    this.drawLengthAverage,
    this.timeBetweenAverage,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'count': drawCount,
      'userid': userid,
      'drawLengthTotal': drawLengthTotal,
      'drawLengthTotalAverage': drawLengthTotalAverage,
      'drawLengthTotalAverageYest': drawLengthTotalAverageYest,
      'drawLengthTotalYest': drawLengthTotalYest,
      'drawLengthAverageYest': drawLengthAverageYest,
      'drawLengthAverage': drawLengthAverage,
      'timeBetweenAverage': timeBetweenAverage,
    };
  }
}

class HourInsert {
  int id;
  final String userid;
  double drawLength;
  final int hour;

  HourInsert({
    this.id,
    this.userid,
    this.drawLength,
    this.hour,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      'userid': userid,
      "drawLength": drawLength,
      "hour": hour,
    };
  }
}

class DayInsert {
  int id;
  final String userid;
  double drawLength;
  final int day;

  DayInsert({
    this.id,
    this.userid,
    this.drawLength,
    this.day,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      'userid': userid,
      "drawLength": drawLength,
      "day": day,
    };
  }
}

class MonthInsert {
  int id;
  final String userid;
  double drawLength;
  final int month;

  MonthInsert({
    this.id,
    this.userid,
    this.drawLength,
    this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      'userid': userid,
      "drawLength": drawLength,
      "month": month,
    };
  }
}