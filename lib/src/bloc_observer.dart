import 'dart:io';

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
    if (ColorObserverLogger.kIsWeb) return trackWebCubit(bloc, event);
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
    return "$method()   $ref";
  }

  String trackWebCubit(BlocBase bloc, String event) {
    if (ColorObserverLogger.stackTracking == false) return "";

    final stack = StackTrace.current.toString().split('\n');
    List<String> output = [];
    for (final s in stack) {
      if (s.contains('src/bloc_base.dart') && s.contains('emit')) {
        int idx = stack.indexOf(s) + 1;
        String cubitMethodString = stack[idx];
        while (true) {
          List<String> result = [];
          String cache = '';
          for (int i = 0; i < cubitMethodString.length; i++) {
            final char = cubitMethodString[i];
            if (char != ' ') {
              cache += char;
            } else {
              if (cache != '') {
                result.add(cache);
              }
              cache = '';
            }
          }
          result.add(cache);
          final file = "${result[0]}:${result[1]}";
          final caller = result.last;
          output.add("$caller()   ($file)");
          idx++;
          cubitMethodString = stack[idx];
          if (cubitMethodString
              .contains('dart-sdk/lib/_internal/js_dev_runtime')) {
            break;
          }
        }
      }
    }

    return LoggerHelperFormatter.filterIfFile(output).join('\n');
  }

  /// get event add ref position
  String trackBloc(BlocBase bloc, String event) {
    if (ColorObserverLogger.stackTracking == false) return "";
    if (ColorObserverLogger.kIsWeb) return trackWebBloc(bloc, event);
    final stack = StackTrace.current.toString().split('\n');
    String targetString = stack.firstWhere(
        (element) => element.contains('Bloc.add ('),
        orElse: () => "");
    if (targetString.isEmpty) {
      targetString = stack.firstWhere(
          (element) => element.contains('.onError ('),
          orElse: () => "");
    }
    if (targetString.isEmpty) {
      return '';
    }
    final target = stack.indexOf(targetString) + 1;
    targetString = stack[target];
    final ref = regex.stringMatch(targetString);
    if (ref == null) return '';
    return targetString.replaceAll(
        ref, '() => [${bloc.runtimeType}] add Event [$event]     $ref');
  }

  String trackWebBloc(BlocBase bloc, String event) {
    if (ColorObserverLogger.stackTracking == false) return "";
    final stack = StackTrace.current.toString().split('\n');
    List<String> output = [];
    for (final s in stack) {
      if (s.contains('packages/bloc/src/bloc.dart') && s.contains('onEvent')) {
        int idx = stack.indexOf(s) + 1;
        String cubitMethodString = stack[idx];
        while (true) {
          List<String> result = [];
          String cache = '';
          for (int i = 0; i < cubitMethodString.length; i++) {
            final char = cubitMethodString[i];
            if (char != ' ') {
              cache += char;
            } else {
              if (cache != '') {
                result.add(cache);
              }
              cache = '';
            }
          }
          result.add(cache);
          final file = "${result[0]}:${result[1]}";
          final caller = result.last;
          output.add(
              "[${bloc.runtimeType}] $caller () =>  add Event [$event]  ($file)");
          idx++;
          cubitMethodString = stack[idx];
          if (cubitMethodString
              .contains('dart-sdk/lib/_internal/js_dev_runtime')) {
            break;
          }
        }
      }
    }
    return LoggerHelperFormatter.filterIfFile(output).join('\n');
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
  /// Bloc.observer = ColorBlocObserver(
  ///   stackTracking: true,
  ///   levelColors: {
  ///     Level.FINE: AnsiColor.fg(40),
  ///     Level.WARNING: AnsiColor.fg(214),
  ///     Level.SEVERE: AnsiColor.fg(196),
  ///   },
  ///   blocHightLightFilter: DefaultHighLightFilter(),
  /// );
  ///
  ///```
  ColorBlocObserver({
    required bool kIsWeb,
    bool stackTracking = true,
    AnsiColor? blocColor,
    int? methodCount = 3,
    Filter? filter,
    BlocHighLightFilter? blocHighLightFilter,
  }) {
    ColorObserverLogger.stackTracking = stackTracking;
    ColorObserverLogger.updateLevelColors(
      {
        Level.FINE: blocColor ?? AnsiColor.fg(40),
      },
    );
    ColorObserverLogger.updateMethodCounts(
      {
        Level.FINE: methodCount ?? 3,
      },
    );
    ColorObserverLogger.filter = filter ?? Filter.allPass();
    ColorObserverLogger.blocHighLightFilter = blocHighLightFilter;
    ColorObserverLogger.kIsWeb = kIsWeb;
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
    final callerLine = _blocTrackingUtils.getCallerLine(
      bloc is Cubit,
      bloc,
      event: '',
    );
    final stateLog = ErrorLog(
      bloc,
      ColorObserverLogger.stackTracking ? stackTrace : null,
      callerLine,
    );

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
