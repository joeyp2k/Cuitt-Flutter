import 'package:cuitt/data/datasources/dial_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DialCubit extends Cubit<List<DialData>> {
  DialCubit() : super(data);

  void changeState() {
    emit(data);
  }
}
