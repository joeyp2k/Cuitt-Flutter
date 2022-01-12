var userDatabase;

class UserData {
  final int id;
  final int drawCount;
  final double drawLengthTotal;
  final double drawLengthTotalYest;
  final double drawLengthTotalAverageYest;
  final double drawLengthTotalAverage;
  final double drawLengthAverage;
  final double drawLengthAverageYest;
  final List<double> plotTotal;
  final List<DateTime> plotTime;

  UserData({
    this.id,
    this.drawCount,
    this.drawLengthTotal,
    this.drawLengthTotalAverage,
    this.drawLengthTotalAverageYest,
    this.drawLengthTotalYest,
    this.drawLengthAverageYest,
    this.drawLengthAverage,
    this.plotTotal,
    this.plotTime,
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
  final int id;
  final double plotTotal;
  final int plotTime;

  DayPlotData({
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
