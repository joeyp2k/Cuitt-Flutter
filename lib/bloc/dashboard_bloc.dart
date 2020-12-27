import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cuitt/bloc/dashboard_event.dart';
import 'package:cuitt/bloc/dashboard_state.dart';
import 'package:cuitt/data/datasources/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:cuitt/bloc/dashboard_event.dart';
export 'package:cuitt/bloc/dashboard_state.dart';
export 'package:cuitt/data/datasources/user.dart';

DashBloc counterBlocSink;

class DashBloc extends Bloc<DashBlocEvent, DashBlocState> {
  //Set Initial State of Counter Bloc by return the LatestCounterState Object with newCounterValue = 0
  @override
  // TODO: implement initialState
  DashBloc()
      : super(DataState(
          newDrawCountValue: 0,
          newSeshCountValue: 0,
          newDrawLengthValue: 0,
          newDrawLengthTotalValue: 0,
          newAverageDrawLengthValue: 0,
          newAverageDrawLengthTotalValue: 0,
          newAverageDrawLengthTotalYestValue: 0,
          newAverageWaitPeriodValue: 0,
        ));

  @override
  Stream<DashBlocState> mapEventToState(DashBlocEvent event) async* {
    // TODO: implement mapEventToState
    if (event is NavigateToPageEvent) {
      //Fetching Current Counter Value From Current State
      int currentCounterValue = (state as LatestDashState).newCounterValue;

      //Applying business Logic
      int newCounterValue = currentCounterValue + 1;

      //Adding new state to the Stream, yield is used to add state to the stream

      yield LatestDashState(newCounterValue: newCounterValue);
    } else if (event is UpdateDataEvent) {

      //Applying business Logic

      int newDrawCountValue = drawCount;
      int newSeshCountValue = seshCount;
      double newDrawLengthValue = drawLength;
      int newDrawLengthTotalValue = drawLengthTotal.round();
      int newAverageDrawLengthValue = drawLengthAverage.round();
      int newDrawLengthTotalAverageValue = drawLengthTotalAverage.round();
      int newAverageDrawLengthTotalYestValue =
          drawLengthTotalAverageYest.round();
      int newAverageWaitPeriodValue;

      //Adding new state to the Stream, yield is used to add state to the stream

      yield DataState(
        newDrawCountValue: newDrawCountValue,
        newSeshCountValue: newSeshCountValue,
        newDrawLengthValue: newDrawLengthValue,
        newDrawLengthTotalValue: newDrawLengthTotalValue,
        newAverageDrawLengthValue: newAverageDrawLengthValue,
        newAverageDrawLengthTotalValue: newDrawLengthTotalAverageValue,
        newAverageDrawLengthTotalYestValue: newAverageDrawLengthTotalYestValue,
        newAverageWaitPeriodValue: newAverageWaitPeriodValue,
      );
    }
  }
}
