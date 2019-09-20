import 'package:Q/src/ApplicationBootstrapArgsResolver.dart';
import 'package:Q/src/ApplicationEnvironment.dart';
import 'package:Q/src/aware/ApplicationEnvironmentResolverAware.dart';
import 'package:Q/src/command/ApplicationConfigurationContants.dart';

class ApplicationEnvironmentResolver implements ApplicationEnvironmentResolverAware<ApplicationEnvironment> {
  ApplicationEnvironmentResolver._();

  static ApplicationEnvironmentResolver _instance;

  static ApplicationEnvironmentResolver instance() {
    if (_instance == null) {
      _instance = ApplicationEnvironmentResolver._();
    }
    return _instance;
  }

  ApplicationEnvironment _environment;

  @override
  Future<ApplicationEnvironment> resolve() async {
    _environment = ApplicationEnvironment(await ApplicationBootstrapArgsResolver.instance().get(APPLICATION_ENVIRONMENT_VARIABLE));
    return _environment;
  }

  @override
  Future<ApplicationEnvironment> get() async {
    if (_environment != null) {
      return Future.value(_environment);
    } else {
      return this.resolve();
    }
  }
}
