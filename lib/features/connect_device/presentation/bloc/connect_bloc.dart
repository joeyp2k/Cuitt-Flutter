import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cuitt/features/connect_device/domain/usecases/connect_device.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_event.dart';
import 'package:cuitt/features/connect_device/presentation/bloc/connect_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

ConnectBloc connectBlocSink;
ConnectBLE connectBLE = ConnectBLE();

class ConnectBloc extends Bloc<ConnectEvent, ConnectState> {
  //Set Initial State of Counter Bloc by return the LatestCounterState Object with newCounterValue = 0
  @override
  // TODO: implement initialState
  ConnectBloc() : super(Idle());

  @override
  Stream<ConnectState> mapEventToState(ConnectEvent event) async* {
    // TODO: implement mapEventToState
    if (event is Connect) {
      yield Loading();
      connectBLE.scanForDevice();
    } else if (event is Disconnect) {
      yield Idle();
    } else if (event is Pair) {
      await connectBLE.initializeUserData();
      yield Success();
    } else if (event is Failed) {
      yield Fail();
    }
  }
}
