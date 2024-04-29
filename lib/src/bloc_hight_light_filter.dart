import 'package:color_observer_logger/color_observer_logger.dart';

class BlocHighLightFilter {
  final bool colorOnly;
  final AnsiColor? color;
  final Function(String message)? onFilter;
  BlocHighLightFilter({this.onFilter, this.colorOnly = false, this.color});
  bool filter(String message) {
    return onFilter?.call(message) ?? false;
  }
}

class DefaultHighLightFilter extends BlocHighLightFilter {
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
