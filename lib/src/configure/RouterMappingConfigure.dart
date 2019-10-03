import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/configure/AbstractConfigure.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';

abstract class RouterMappingConfigure extends AbstractConfigure {
  factory RouterMappingConfigure() => _RouterMappingConfigure();

  String get defaultMapping;
}

class _RouterMappingConfigure implements RouterMappingConfigure {
  String defaultMapping_;

  @override
  String get defaultMapping {
    return defaultMapping_;
  }

  @override
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration) async {
    defaultMapping_ = applicationConfiguration.get(APPLICATION_ROUTER_DEFAULT_MAPPING);
  }
}
