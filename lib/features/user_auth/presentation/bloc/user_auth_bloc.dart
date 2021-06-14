import 'package:cuitt/features/user_auth/domain/usecases/user_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'user_auth_event.dart';
import 'user_auth_state.dart';

UserAuthBloc userAuthBlocSink;

class UserAuthBloc extends Bloc<UserAuthEvent, UserAuthState> {
  //Set Initial State of Counter Bloc by return the LatestCounterState Object with newCounterValue = 0
  @override
  // TODO: implement initialState
  UserAuthBloc() : super(CreateAccountState());

  @override
  Stream<UserAuthState> mapEventToState(UserAuthEvent event) async* {
    // TODO: implement mapEventToState
    if (event is CreateAccountEvent) {
      yield LoadingState();
      final bool failOrNavigate = await userAuth.register();
      if (failOrNavigate) {
        yield NavigationState(
          navigate: failOrNavigate,
        );
      } else {
        yield CreateAccountState();
      }
    } else if (event is NavSignInEvent) {
      print("navsignin");
      yield SignInState();
    } else if (event is NavCreateEvent) {
      print("navcreateaccount");
      yield CreateAccountState();
    } else if (event is SignInEvent) {
      yield LoadingState();

      final bool failOrNavigate = await userAuth.signInWithEmailAndPassword();
      if (failOrNavigate) {
        yield NavigationState(
          navigate: failOrNavigate,
        );
      } else {
        yield SignInState();
      }
    }
  }
}
