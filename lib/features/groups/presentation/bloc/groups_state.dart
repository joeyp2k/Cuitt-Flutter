abstract class GroupsState {}

class LatestPageState extends GroupsState {
  final bool complete;

  LatestPageState({this.complete});

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [complete];
}

class LoadingState extends GroupsState {
  final bool complete;

  LoadingState({this.complete});

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [complete];
}

class Fail extends GroupsState {
  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Success extends GroupsState {
  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GroupList extends GroupsState {
  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class UserList extends GroupsState {
  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class User extends GroupsState {
  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [];
}
