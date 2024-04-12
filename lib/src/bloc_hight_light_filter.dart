class BlocHightLightFilter {
  final Function(String message)? onFilter;
  BlocHightLightFilter({this.onFilter});
  bool filter(String message) {
    return onFilter?.call(message) ?? false;
  }
}

class DefaultHighLightFilter extends BlocHightLightFilter {
  @override
  bool filter(String message) {
    return message.toLowerCase().contains('error') ||
        message.toLowerCase().contains('fail') ||
        message.toLowerCase().contains('exception');
  }
}
