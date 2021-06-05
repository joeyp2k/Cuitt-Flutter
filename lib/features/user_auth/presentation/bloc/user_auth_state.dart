abstract class UserAuthState {}

class IntroductionState extends UserAuthState {
  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class CreateAccountState extends UserAuthState {
  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SignInState extends UserAuthState {
  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoadingState extends UserAuthState {
  bool processing;

  LoadingState({this.processing});

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [processing];
}

class NavigationState extends UserAuthState {
  bool navigate;

  NavigationState({this.navigate});

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [navigate];
}
