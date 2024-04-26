import 'package:color_observer_logger/color_observer_logger.dart';

class BlocHightLightFilter {
  final bool colorOnly;
  final AnsiColor? color;
  final Function(String message)? onFilter;
  BlocHightLightFilter({this.onFilter, this.colorOnly = false, this.color});
  bool filter(String message) {
    return onFilter?.call(message) ?? false;
  }
}

class DefaultHighLightFilter extends BlocHightLightFilter {
  DefaultHighLightFilter({
    bool colorOnly = true,
    AnsiColor? color,
  }) : super(
          colorOnly: colorOnly,
          color: color,
        );
  @override
  bool filter(String message) {
    return message.toLowerCase().contains('error') ||
        message.toLowerCase().contains('fail') ||
        message.toLowerCase().contains('exception');
  }
}
