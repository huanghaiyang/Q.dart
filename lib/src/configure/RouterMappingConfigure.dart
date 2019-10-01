import 'package:Q/src/configure/AbstractConfigure.dart';

final String BASE_PATH = '/';
final Pattern BASE_PATH_PATTERN = RegExp('^$BASE_PATH');

abstract class RouterMappingConfigure extends AbstractConfigure {
  factory RouterMappingConfigure() => _RouterMappingConfigure();

  String get defaultMapping;

  static Pattern defaultMappingPattern = BASE_PATH_PATTERN;
}

class _RouterMappingConfigure implements RouterMappingConfigure {
  @override
  String get defaultMapping {
    return BASE_PATH;
  }

  @override
  Future<dynamic> init() async {}
}
