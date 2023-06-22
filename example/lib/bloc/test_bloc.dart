import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlocEvent {}

abstract class BlocState {
  const BlocState();
}

class TestLoginBloc extends Bloc<BlocEvent, BlocState> {
  TestLoginBloc() : super(FailedState()) {
    on<Success>((event, emit) => emit(SuccessState()));
    on<Failed>((event, emit) => emit(FailedState()));
    on<Error>((event, emit) => throw Exception("Error"));
  }
}

class Success extends BlocEvent {}

class Failed extends BlocEvent {}

class Error extends BlocEvent {}

class SuccessState extends BlocState {}

class FailedState extends BlocState {}
