import 'package:cuitt/bloc/create_account_event.dart';
import 'package:cuitt/bloc/create_account_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAcctBloc extends Bloc<CreateAcctEvent, CreateAcctState> {
  //Set Initial State of Counter Bloc by return the LatestCounterState Object with newCounterValue = 0
  @override
  // TODO: implement initialState
  CreateAcctBloc()
      : super(DataState(
          newDrawCountValue: 0,
        ));

  @override
  Stream<CreateAcctState> mapEventToState(CreateAcctEvent event) async* {
    // TODO: implement mapEventToState
    if (event is NavigateToPageEvent) {
      //Fetching Current Counter Value From Current State
      int currentCounterValue = (state as LatestPageState).newCounterValue;

      //Applying business Logic
      int newCounterValue = currentCounterValue + 1;

      //Adding new state to the Stream, yield is used to add state to the stream
      yield LatestPageState(newCounterValue: newCounterValue);
    } else if (event is UpdateEvent) {
      //Applying business Logic

      //Adding new state to the Stream, yield is used to add state to the stream

      yield DataState();
    }
  }
}
