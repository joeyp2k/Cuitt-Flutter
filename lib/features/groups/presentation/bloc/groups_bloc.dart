import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cuitt/features/groups/domain/usecases/write_group_data.dart';
import 'package:cuitt/features/groups/presentation/bloc/groups_event.dart';
import 'package:cuitt/features/groups/presentation/bloc/groups_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:cuitt/features/groups/presentation/bloc/groups_event.dart';
export 'package:cuitt/features/groups/presentation/bloc/groups_state.dart';

GroupBloc groupBlocSink;

class GroupBloc extends Bloc<GroupsEvent, GroupsState> {
  //Set Initial State of Counter Bloc by return the LatestCounterState Object with newCounterValue = 0
  @override
  // TODO: implement initialState
  GroupBloc()
      : super(LatestPageState(
          complete: false,
        ));

  @override
  Stream<GroupsState> mapEventToState(GroupsEvent event) async* {
    // TODO: implement mapEventToState
    if (event is CreateAdminEvent) {
      yield LoadingState();
      final failureOrNavigate = await writeGroupData.createAdminGroup();
      if (failureOrNavigate) {
        yield Success();
      } else {
        yield Fail();
      }
    } else if (event is CreateCasualEvent) {
      yield LoadingState();
      final failureOrNavigate = await writeGroupData.createCasualGroup();
      if (failureOrNavigate) {
        yield Success();
      } else {
        yield Fail();
      }
    } else if (event is JoinEvent) {
      yield LoadingState();
      final failureOrNavigate = await writeGroupData.joinGroup();
      if (failureOrNavigate) {
        yield Success();
      } else {
        yield Fail();
      }
    } else if (event is LeaveEvent) {
      //Fetching Current Counter Value From Current State
      bool newCounterValue = (state as LatestPageState).complete;
      //Applying business Logic

      //Adding new state to the Stream, yield is used to add state to the stream

      yield LatestPageState(
        complete: newCounterValue,
      );
    }
  }
}
