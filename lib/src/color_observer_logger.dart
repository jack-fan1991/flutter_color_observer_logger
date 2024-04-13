import 'dart:io';
import 'package:color_observer_logger/color_observer_logger.dart';
import 'package:color_observer_logger/src/bloc_hight_light_filter.dart';
import 'package:color_observer_logger/src/event_log.dart';
import 'package:flutter/foundation.dart';

import 'dart:developer' as developer;

import 'package:logging/logging.dart';

import 'ansi_color.dart';

final loggerHelperFormatter = LoggerHelperFormatter();

class ColorObserverLogger {
  static const verticalLine = ' │ ';
  static const head =
      '┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────';
  static const tail =
      '└──────────────────────────────────────────────────────────────────────────────────────────────────────────────';
  static bool _logStack = true;
  static bool get stackTracking => _logStack;
  static Filter filter = Filter.allPass();
  static BlocHightLightFilter? blocHightLightFilter;
  static bool kIsWeb = false;
  static set stackTracking(bool value) {
    // if (kIsWeb && value == true) {
    //   developer.log(AnsiColor.fg(196)(
    //       "ColorObserverLogger.logStack tracking is not supported on web platform"));
    //   return;
    // }
    _logStack = value;
  }

  static final defaultLevelColors = {
    Level.FINE: AnsiColor.fg(40),
    Level.WARNING: AnsiColor.fg(214),
    Level.SEVERE: AnsiColor.fg(196),
  };

  static final Map<Level, int> defaultMethodCounts = {
    Level.SEVERE: 8,
    Level.FINE: 3,
  };

  static void updateMethodCounts(Map<Level, int>? methodCounts) {
    if (methodCounts == null) return;
    for (final element in methodCounts.entries) {
      defaultMethodCounts[element.key] = element.value;
    }
  }

  static void updateLevelColors(Map<Level, AnsiColor>? levelColors) {
    if (levelColors == null) return;
    for (final element in levelColors.entries) {
      defaultLevelColors[element.key] = element.value;
    }
  }

  static bool canLog(EventLog eventLog) {
    if (eventLog.level < Logger.root.level) return false;
    if (filter.name.isEmpty) {
      return true;
    } else if (filter is ShowWhenFilter) {
      return filter.name.any((element) => (eventLog.title.contains(element)));
    } else if (filter is HideWhenFilter) {
      return !filter.name.any((element) => (eventLog.title.contains(element)));
    } else {
      return true;
    }
  }

  static List<String> filterMsgCountByLevel(Level level, List<String> msg) {
    final maxLine = defaultMethodCounts[level] ?? 1;
    final dartFile = msg
        .where((element) => element.contains('.dart'))
        .take(maxLine)
        .toList();
    final blocInfo =
        msg.where((element) => !element.contains('.dart')).toSet().toList();
    return [...dartFile, ...blocInfo];
  }

  static output(EventLog eventLog) {
    if (!canLog(eventLog)) return;
    // methodCount = methodCounts[level];
    AnsiColor color = defaultLevelColors[eventLog.level] ?? AnsiColor.none();

    if (eventLog.message.isEmpty) return;
    List<String> msg =
        LoggerHelperFormatter.formatWithPrefix(eventLog, eventLog.message);
    msg = LoggerHelperFormatter.filterIfFile(msg);
    msg = filterMsgCountByLevel(eventLog.level, msg);
    if (ColorObserverLogger.blocHightLightFilter?.filter(eventLog.message) ??
        false) {
      for (var i = 0; i < msg.length; i++) {
        final hightLightColor = AnsiColor.fg(214);

        final hightLight =
            ColorObserverLogger.blocHightLightFilter?.filter(msg[i]) ?? false;
        if (hightLight) {
          msg[i] = hightLightColor(
              "${msg[i]}    <==== ❗Something contains HightLight❗  ");
        }
      }
    }
    if (eventLog.level >= Level.ALL) {
      msg = [head, ...msg, tail];
    }
    for (var s in msg) {
      if (kIsWeb) {
        print('  ${color(s)}');
      } else if (Platform.isIOS) {
        developer.log('  ${color(s)}');
      } else {
        print('  ${color(s)}');
      }
    }
  }
}

class LoggerHelperFormatter {
  static const verticalLine = ' │ ';
  static List<String> skipFileName = [
    "ColorObserverLogger",
    "ColorBlocObserver",
    "logger_helper",
    "package:bloc",
    "stream.dart",
    "zone.dart",
    "async_cast.dart",
    "stream_impl.dart",
    "dart:async",
    "flutter_bloc",
    "abstract_exception.dart",
    "base_bloc_widget.dart",
    "package:flutter/src/widgets/framework.dart",
    "package:flutter/src/scheduler/binding.dart",
    "dart:ui",
    "LoggerHelperFormatter",
    "ColorLoggerFormatter",
    "package:logging",
    "package:color_logger",
    "dart:ui",
    "dart-sdk/lib/_internal/js_dev_runtime",
    "packages/color_observer_logger",
    "packages/flutter/src",
    "lib/_engine/engine/"
  ];

  /// Matches a stacktrace line as generated on Android/iOS devices.
  /// For example:
  /// #1      Logger.log (package:logger/src/logger.dart:115:29)
  static final _deviceStackTraceRegex =
      RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');

  static String cleanTrackInfo(String stackInfo) {
    return stackInfo.replaceFirst(RegExp(r'^#\d+\s+'), '# ');
  }

  late DateTime _startTime;

  final int methodCount;
  final int errorMethodCount;
  final bool colors;
  final bool printEmojis;
  final bool printTime;
  final String title;

  LoggerHelperFormatter({
    this.title = "",
    this.methodCount = 5,
    this.errorMethodCount = 8,
    this.colors = true,
    this.printEmojis = true,
    this.printTime = true,
  }) {
    _startTime = DateTime.now();
  }

  static String getTime() {
    String _threeDigits(int n) {
      if (n >= 100) return '$n';
      if (n >= 10) return '0$n';
      return '00$n';
    }

    String _twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    var now = DateTime.now();
    String formattedDate =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    var h = _twoDigits(now.hour);
    var min = _twoDigits(now.minute);
    var sec = _twoDigits(now.second);
    var ms = _threeDigits(now.millisecond);
    // var timeSinceStart = now.difference(_startTime).toString();
    // return '$h:$min:$sec.$ms (+$timeSinceStart)';
    return '$formattedDate $h:$min:$sec.$ms';
  }

  List<String> format(EventLog eventLog, {int? methodCount}) {
    // methodCount = methodCounts[level];
    String? stackTraceStr;
    if (ColorObserverLogger.stackTracking) {
      stackTraceStr = formatStackTrace(
        StackTrace.current,
        methodCount ??
            ColorObserverLogger.defaultMethodCounts[eventLog.level] ??
            3,
      );
    }

    List<String> list = formatWithPrefix(
      eventLog,
      stackTraceStr,
    );
    return list;
  }

  static List<String> formatWithPrefix(
    EventLog eventLog,
    String? msgList,
  ) {
    List<String> buffer = [];
    List<String> lines = [];
    final time = getTime();
    buffer.add(
      '│ [${eventLog.title}]$verticalLine${eventLog.level.name}$verticalLine$time',
    );
    final msg = eventLog.message.split('\n').map(
          (e) =>
              '│ [${eventLog.title}]$verticalLine${eventLog.level.name}$verticalLine$e',
        );

    if (msgList != null) {
      lines = msgList.split('\n');
      for (var line in lines) {
        buffer.add(
            "│ [${eventLog.title}]$verticalLine${eventLog.level.name}$verticalLine$line");
      }
    }
    final result = [...buffer.toList(), ...msg];

    return result;
  }

  String? formatStackTrace(StackTrace stackTrace, int? methodCount) {
    var lines = stackTrace.toString().split('\n');
    var formatted = <String>[];
    var count = 0;
    for (var line in lines) {
      if (_discardDeviceStacktraceLine(line) ||
          skipFileIfNeed(line) ||
          line.contains("<asynchronous suspension>") ||
          line == "") {
        continue;
      }
      formatted.add('#$count   ${line.replaceFirst(RegExp(r'#\d+\s+'), '')}');
      count++;
      if (count >= methodCount!) {
        if (methodCount == 0) {
          formatted.clear();
        }
        break;
      }
    }

    if (formatted.isEmpty) {
      return null;
    } else {
      return formatted.join('\n');
    }
  }

  bool _discardDeviceStacktraceLine(String line) {
    var match = _deviceStackTraceRegex.matchAsPrefix(line);
    if (match == null) {
      return false;
    }
    return match.group(2)!.startsWith('package:logger');
  }

  static bool skipFileIfNeed(String line) {
    for (final skipFile in skipFileName) {
      if (line.contains(skipFile)) {
        return true;
      }
    }
    return false;
  }

  static List<String> filterIfFile(List<String> message) {
    return message.where((msg) => !skipFileIfNeed(msg)).toList();
  }
}
