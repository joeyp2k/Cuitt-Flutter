import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cuitt/features/dashboard/data/datasources/my_data.dart';
import 'package:cuitt/features/dashboard/domain/usecases/charts.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:cuitt/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

DashBloc counterBlocSink;

class DashBloc extends Bloc<DashBlocEvent, DashBlocState> {
  UpdateChart updateChart = UpdateChart();

  //Set Initial State of Counter Bloc by return the LatestCounterState Object with newCounterValue = 0
  @override
  // TODO: implement initialState
  DashBloc()
      : super(DataState(
          newDrawCountValue: 0,
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
    if (event is OpenDrawerEvent) {
      yield DrawerOpen();
    } else if (event is CloseDrawerEvent) {
      yield DrawerClosed();
    } else if (event is DashReEntryEvent) {
      int newDrawCountValue = drawCount;
      double newDrawLengthValue = drawLength;
      int newDrawLengthTotalValue = drawLengthTotal.round();
      int newAverageDrawLengthValue = drawLengthAverage.round();
      int newDrawLengthTotalAverageValue = drawLengthTotalAverage.round();
      int newAverageDrawLengthTotalYestValue =
          drawLengthTotalAverageYest.round();
      int newAverageWaitPeriodValue;
      yield DataState(
        newDrawCountValue: newDrawCountValue,
        newDrawLengthValue: newDrawLengthValue,
        newDrawLengthTotalValue: newDrawLengthTotalValue,
        newAverageDrawLengthValue: newAverageDrawLengthValue,
        newAverageDrawLengthTotalValue: newDrawLengthTotalAverageValue,
        newAverageDrawLengthTotalYestValue: newAverageDrawLengthTotalYestValue,
        newAverageWaitPeriodValue: newAverageWaitPeriodValue,
      );
    } else if (event is UpdateDataEvent) {
      //Applying business Logic

      int newDrawCountValue = drawCount;
      double newDrawLengthValue = drawLength;
      int newDrawLengthTotalValue = drawLengthTotal.round();
      int newAverageDrawLengthValue = drawLengthAverage.round();
      int newDrawLengthTotalAverageValue = drawLengthTotalAverage.round();
      int newAverageDrawLengthTotalYestValue =
          drawLengthTotalAverageYest.round();
      int newAverageWaitPeriodValue;
      updateChart.updateChart(); //dashboard chart
      updateChart.updateDial();
      print("UPDATE DATA EVENT");

      //Adding new state to the Stream, yield is used to add state to the stream

      yield DataState(
        newDrawCountValue: newDrawCountValue,
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
