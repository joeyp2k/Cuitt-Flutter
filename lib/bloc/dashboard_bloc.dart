import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<double> hitLengthArray = [];
List<int> timestampArray = [];
var drawCountIndex = 0;
var hitTimeNow;
var hitTimeThen;
var timeUntilNext;
var decay = 0.95;
var dayNum = 1;
var drawLength;
var currentTime;
var waitPeriod;
var timeBetween;
var timeBetweenAverage;
var drawCountAverage;
double drawLengthTotal = 0;
var drawLengthTotalYest;
var drawLengthTotalAverageYest;
double drawLengthTotalAverage;
double drawLengthAverage = 0;
var drawLengthAverageYest;
var drawCount = 0;
var seshCount = 0;
var seshCountAverage;
var drawCountYest = 0;
var seshCountYest = 0;
var suggestion;

abstract class CounterBlocEvent {}

class UpdateDataEvent extends CounterBlocEvent {
  //overide this method when class extends equatable

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class IncreaseCounterEvent extends CounterBlocEvent {
//overide this method when class extends equatable

  @override
  // TODO: implement props
  List<Object> get props => [];
}

abstract class CounterBlocState {}

class LatestCounterState extends CounterBlocState {
  final int newCounterValue;

  LatestCounterState({this.newCounterValue});

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [newCounterValue];
}

class DataState extends CounterBlocState {
  final int newDrawCountValue;
  final int newSeshCountValue;
  final double newDrawLengthValue;
  final int newDrawLengthTotalValue;
  final int newAverageDrawLengthValue;
  final int newAverageDrawLengthTotalValue;
  final int newAverageWaitPeriodValue;

  DataState({
    this.newDrawCountValue,
    this.newSeshCountValue,
    this.newDrawLengthValue,
    this.newDrawLengthTotalValue,
    this.newAverageDrawLengthValue,
    this.newAverageDrawLengthTotalValue,
    this.newAverageWaitPeriodValue,
  });

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [newDrawCountValue];
}

class CounterBloc extends Bloc<CounterBlocEvent, CounterBlocState> {
  //Set Initial State of Counter Bloc by return the LatestCounterState Object with newCounterValue = 0
  @override
  // TODO: implement initialState
  CounterBloc()
      : super(DataState(
          newDrawCountValue: 0,
          newSeshCountValue: 0,
          newDrawLengthValue: 0,
          newDrawLengthTotalValue: 0,
          newAverageDrawLengthValue: 0,
          newAverageDrawLengthTotalValue: 0,
          newAverageWaitPeriodValue: 0,
        ));

  @override
  Stream<CounterBlocState> mapEventToState(CounterBlocEvent event) async* {
    // TODO: implement mapEventToState
    if (event is IncreaseCounterEvent) {
      //Fetching Current Counter Value From Current State
      int currentCounterValue = (state as LatestCounterState).newCounterValue;

      //Applying business Logic
      int newCounterValue = currentCounterValue + 1;

      //Adding new state to the Stream, yield is used to add state to the stream
      yield LatestCounterState(newCounterValue: newCounterValue);
    } else if (event is UpdateDataEvent) {
      //Fetching Current Counter Value From Current State
      int currentDrawCountValue = (state as DataState).newDrawCountValue;
      int currentSeshCountValue = (state as DataState).newSeshCountValue;
      double currentDrawLengthValue = (state as DataState).newDrawLengthValue;
      int currentDrawLengthTotalValue =
          (state as DataState).newDrawLengthTotalValue;
      int currentAverageDrawLengthValue =
          (state as DataState).newAverageDrawLengthValue;
      int currentAverageDrawLengthTotalValue =
          (state as DataState).newAverageDrawLengthTotalValue;

      //Applying business Logic
      int newDrawCountValue = drawCount;
      int newSeshCountValue = seshCount;
      double newDrawLengthValue = drawLength;
      int newDrawLengthTotalValue = drawLengthTotal.truncate();
      int newAverageDrawLengthValue = drawLengthAverage.truncate();
      int newDrawLengthTotalAverageValue = drawLengthTotalAverage.truncate();
      int newAverageWaitPeriodValue;
      print('NEW DRAW COUNT FROM BLOC: ' + newDrawLengthValue.toString());

      //Adding new state to the Stream, yield is used to add state to the stream
      yield DataState(
        newDrawCountValue: newDrawCountValue,
        newSeshCountValue: newSeshCountValue,
        newDrawLengthValue: newDrawLengthValue,
        newDrawLengthTotalValue: newDrawLengthTotalValue,
        newAverageDrawLengthValue: newAverageDrawLengthValue,
        newAverageDrawLengthTotalValue: newDrawLengthTotalAverageValue,
        newAverageWaitPeriodValue: newAverageWaitPeriodValue,
      );
    }
  }
}
