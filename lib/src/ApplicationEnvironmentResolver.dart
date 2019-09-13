import 'package:Q/src/ApplicationEnvironment.dart';
import 'package:Q/src/aware/ApplicationEnvironmentResolverAware.dart';

class ApplicationEnvironmentResolver implements ApplicationEnvironmentResolverAware<ApplicationEnvironment> {
  ApplicationEnvironmentResolver._();

  static ApplicationEnvironmentResolver _instance;

  static ApplicationEnvironmentResolver getInstance() {
    if (_instance == null) {
      _instance = ApplicationEnvironmentResolver._();
    }
    return _instance;
  }

  Future<ApplicationEnvironment> resolve() async {}
}
