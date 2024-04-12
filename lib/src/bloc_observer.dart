import 'package:color_observer_logger/src/ansi_color.dart';
import 'package:color_observer_logger/src/bloc_hight_light_filter.dart';
import 'package:color_observer_logger/src/color_observer_logger.dart';
import 'package:color_observer_logger/src/event_log.dart';
import 'package:bloc/bloc.dart';
import 'package:color_observer_logger/src/logger_filter.dart';
import 'package:logging/logging.dart';

BlocTrackingUtils _blocTrackingUtils = BlocTrackingUtils();

String cleanTrackInfo(String stackInfo) {
  return stackInfo.replaceFirst(RegExp(r'^#\d+\s+'), '# ');
}

class BlocTrackingUtils {
  /// r'\([^\)]+\)' 會匹配一個括號包含的字串，
  /// 其中 [^)]+ 會匹配任意一個非右括號的字元
  final RegExp regex = RegExp(r'\([^\)]+\)');

  String trackCubit(BlocBase bloc, String event) {
    if (ColorObserverLogger.stackTracking == false) return "";

    final cubit = bloc.runtimeType.toString();
    final stack = StackTrace.current.toString().split('\n');
    String cubitMethodString = '';
    String refString = '';
    for (final s in stack) {
      if (s.contains(cubit)) {
        cubitMethodString = s;
      }
      if (cubitMethodString.isNotEmpty &&
          !s.contains(cubit) &&
          !s.contains('BlocBase.emit (')) {
        refString =
            s.contains('<asynchronous suspension>') ? cubitMethodString : s;
        break;
      }
    }
    final ref = regex.stringMatch(refString);
    final method = cubitMethodString.split('(').first;
    if (ref == null) return '';
    return "$method   $ref";
  }

  /// get event add ref position
  String trackBloc(BlocBase bloc, String event) {
    if (ColorObserverLogger.stackTracking == false) return "";
    final stack = StackTrace.current.toString().split('\n');
    final target = stack.indexOf(
            stack.firstWhere((element) => element.contains('Bloc.add ('))) +
        1;
    final targetString = stack[target];
    final ref = regex.stringMatch(targetString);
    if (ref == null) return '';
    return targetString.replaceAll(
        ref, '() => [${bloc.runtimeType}] add Event [$event]     $ref');
  }

  String getCallerLine(bool isCubit, BlocBase bloc, {String event = ""}) {
    final line = isCubit ? trackCubit(bloc, event) : trackBloc(bloc, event);
    return cleanTrackInfo(line);
  }
}

mixin HideWhenBlocObserverAttachMixin {
  // ignore: unnecessary_type_check
  bool skipObserver(BlocBase bloc) => bloc is HideWhenBlocObserverAttachMixin;
}

class ColorBlocObserver extends BlocObserver
    with HideWhenBlocObserverAttachMixin {
  /// Use with [HideWhenBlocObserverAttachMixin] on Bloc to skip when bloc observer attach
  ///
  ///```dart
  ///   AnsiColor.showColor();
  ///   final Map<Level, AnsiColor> levelColors = {
  ///     Level.FINE: AnsiColor.fg(75),
  ///     Level.WARNING: AnsiColor.fg(214),
  ///     Level.SEVERE: AnsiColor.fg(196),
  ///    };
  ///
  ///   final Map<Level, int> methodCounts = {
  ///     Level.SEVERE: 8,
  ///     Level.FINE: 2,
  ///    };
  ///
  ///
  ///```
  ColorBlocObserver({
    bool stackTracking = true,
    Map<Level, AnsiColor>? levelColors,
    Map<Level, int>? methodCounts,
    Filter? filter,
    BlocHightLightFilter? blocHightLightFilter,
  }) {
    ColorObserverLogger.stackTracking = stackTracking;
    ColorObserverLogger.updateLevelColors(levelColors);
    ColorObserverLogger.updateMethodCounts(methodCounts);
    ColorObserverLogger.filter = filter ?? Filter.allPass();
    ColorObserverLogger.blocHightLightFilter = blocHightLightFilter;
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (skipObserver(bloc)) return;
    final callerLine = _blocTrackingUtils.getCallerLine(
      bloc is Cubit,
      bloc,
      event: event.runtimeType.toString(),
    );
    final eventLog = BlocEventLog(bloc, event, callerLine);
    ColorObserverLogger.output(eventLog);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (skipObserver(bloc)) return;
    if (bloc is Cubit) {
      final callerLine = _blocTrackingUtils.getCallerLine(true, bloc);
      final cubitStateLog = CubitStateLog(bloc, change, callerLine);
      ColorObserverLogger.output(cubitStateLog);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (skipObserver(bloc)) return;
    final stateLog = BlocStateLog(bloc, transition);
    ColorObserverLogger.output(stateLog);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    final stateLog =
        ErrorLog(bloc, ColorObserverLogger.stackTracking ? stackTrace : null);

    ColorObserverLogger.output(stateLog);

    // Talker? talker = LoggerHelper.isActivate ? LoggerHelper.talker : null;
    // talker?.handle(error, stackTrace, '🚨 [BLOC] Error in ${bloc.runtimeType}');
  }
}

// mixin OwlBlocObserverMixin<Event, State> on Bloc<Event, State> {
//   Talker? talker = LoggerHelper.isActivate ? LoggerHelper.talker : null;

//   @override
//   void onTransition(Transition transition) {
//     super.onTransition(transition as Transition<Event, State>);
//     Talker? talker = LoggerHelper.isActivate ? LoggerHelper.talker : null;
//     talker?.logTyped(BlocStateLog(this, transition));
//   }

//   @override
//   void onError(Object error, StackTrace stackTrace) {
//     super.onError(error, stackTrace);
//     Talker? talker = LoggerHelper.isActivate ? LoggerHelper.talker : null;
//     talker?.handle(error, stackTrace, '🚨 [BLOC] Error in $runtimeType');
//   }
// }

// mixin OwlCubitObserverMixin<State> on BlocBase<State> {
//   @override
//   void onChange(Change change) {
//     super.onChange(change as Change<State>);
//     final callerLine = _blocTrackingUtils.getCallerLine(true, this);
//     Talker? talker = LoggerHelper.isActivate ? LoggerHelper.talker : null;
//     talker?.logTyped(CubitStateLog(this, change, callerLine));
//   }

//   @override
//   void onError(Object error, StackTrace stackTrace) {
//     super.onError(error, stackTrace);
//     Talker? talker = LoggerHelper.isActivate ? LoggerHelper.talker : null;
//     talker?.handle(error, stackTrace, '🚨 [BLOC] Error in $runtimeType');
//   }
// }
