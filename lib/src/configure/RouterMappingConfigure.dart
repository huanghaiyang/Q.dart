final String BASE_PATH = '/';
final Pattern BASE_PATH_PATTERN = RegExp('^$BASE_PATH');

abstract class RouterMappingConfigure {
  factory RouterMappingConfigure() => _RouterMappingConfigure();

  String get defaultMapping;

  static Pattern defaultMappingPattern = BASE_PATH_PATTERN;
}

class _RouterMappingConfigure implements RouterMappingConfigure {
  @override
  String get defaultMapping {
    return BASE_PATH;
  }
}
