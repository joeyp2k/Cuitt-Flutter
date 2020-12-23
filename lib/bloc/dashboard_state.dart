abstract class DashBlocState {}

class LatestDashState extends DashBlocState {
  final int newCounterValue;

  LatestDashState({this.newCounterValue});

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [newCounterValue];
}

class DataState extends DashBlocState {
  final int newDrawCountValue;
  final int newSeshCountValue;
  final double newDrawLengthValue;
  final int newDrawLengthTotalValue;
  final int newAverageDrawLengthValue;
  final int newAverageDrawLengthTotalValue;
  final int newAverageDrawLengthTotalYestValue;
  final int newAverageWaitPeriodValue;

  DataState({
    this.newDrawCountValue,
    this.newSeshCountValue,
    this.newDrawLengthValue,
    this.newDrawLengthTotalValue,
    this.newAverageDrawLengthValue,
    this.newAverageDrawLengthTotalValue,
    this.newAverageDrawLengthTotalYestValue,
    this.newAverageWaitPeriodValue,
  });

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [newDrawCountValue];
}
