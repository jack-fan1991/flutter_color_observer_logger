import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestCubit extends Cubit<int> {
  TestCubit(super.initialState);
  update() => emit(state + 1);
  error() => throw Exception("Error");
}
