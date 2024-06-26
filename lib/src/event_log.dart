import 'package:bloc/bloc.dart';
import 'package:color_observer_logger/src/color_observer_logger.dart';
import 'package:logging/logging.dart';

/// Base implementation of [TalkerDataInterface]
/// to create Logs
class EventLog {
  EventLog(
    this.message, {
    this.exception,
    this.error,
    this.stackTrace,
    this.title = '',
    DateTime? time,
    this.level = Level.FINE,
  });

  final Level level;

  /// {@macro talker_data_message}
  final String message;

  final Exception? exception;

  final Error? error;

  final StackTrace? stackTrace;

  final String title;
}

class BlocEventLog extends EventLog {
  BlocEventLog(Bloc bloc, Object? event, String callerLine)
      : super(
          _createMessage(bloc, event, callerLine),
          title: "BLOC ${bloc.runtimeType}",
        );
  static String _createMessage(Bloc bloc, Object? event, String callerLine) {
    return bloc is Cubit
        ? '$callerLine\nEvent receive in ${bloc.runtimeType} event: $event'
        : callerLine;
  }
}

class BlocStateLog extends EventLog {
  BlocStateLog(Bloc bloc, Transition transition)
      : super(
          _createMessage(bloc, transition),
          title: "BLOC ${bloc.runtimeType}",
        );

  static String _createMessage(Bloc bloc, Transition transition) {
    return '${'TRANSITION with event ${transition.event.runtimeType}'}\n${'CURRENT state: ${transition.currentState.runtimeType}'}\n\t  ⬇\n${'NEXT    state: ${transition.nextState.runtimeType}'}';
  }
}

class CubitStateLog extends EventLog {
  CubitStateLog(BlocBase bloc, Change change, String callerLine)
      : super(
          _createMessage(bloc, change, callerLine),
          title: "BLOC CUBIT ${bloc.runtimeType}",
        );

  static String _createMessage(
      BlocBase bloc, Change change, String callerLine) {
    return '${'$callerLine\nSTATE TYPE => ${change.currentState.runtimeType}\nCURRENT state: ${change.currentState}'}\n\t  ⬇\n${'NEXT    state: ${change.nextState}'}';
  }
}

class ErrorLog extends EventLog {
  ErrorLog(BlocBase bloc, StackTrace? stackTrace, String webTrace)
      : super(
          ColorObserverLogger.kIsWeb
              ? webTrace
              : _createMessage(bloc, stackTrace),
          title: "BLOC ${bloc.runtimeType}",
          level: Level.SEVERE,
        );

  static String _createMessage(BlocBase bloc, StackTrace? stackTrace) {
    final firstStack =
        stackTrace == null ? "" : stackTrace.toString().split('\n').first;
    return 'Error in ${bloc.runtimeType}\n $firstStack';
  }
}
