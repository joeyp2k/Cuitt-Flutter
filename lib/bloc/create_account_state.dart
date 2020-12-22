abstract class CreateAcctState {}

class LatestPageState extends CreateAcctState {
  final int newCounterValue;

  LatestPageState({this.newCounterValue});

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [newCounterValue];
}

class DataState extends CreateAcctState {
  final int newDrawCountValue;

  DataState({
    this.newDrawCountValue,
  });

  //overide this method as base class extends equatable and pass property inside props list
  @override
  // TODO: implement props
  List<Object> get props => [newDrawCountValue];
}
