import 'package:Q/src/ApplicationEnvironment.dart';
import 'package:Q/src/aware/ApplicationEnvironmentResolverAware.dart';

class ApplicationEnvironmentResolver implements ApplicationEnvironmentResolverAware<ApplicationEnvironment> {
  ApplicationEnvironmentResolver._();

  static ApplicationEnvironmentResolver _instance;

  static ApplicationEnvironmentResolver instance() {
    if (_instance == null) {
      _instance = ApplicationEnvironmentResolver._();
    }
    return _instance;
  }

  @override
  Future<ApplicationEnvironment> resolve() {}
}
