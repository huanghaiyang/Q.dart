import 'package:Q/src/ApplicationEnvironment.dart';
import 'package:Q/src/aware/ApplicationEnvironmentResolverAware.dart';
import 'package:Q/src/configure/ApplicationConfigurationNames.dart';

class ApplicationEnvironmentResolver implements ApplicationEnvironmentResolverAware<Map<String, dynamic>, ApplicationEnvironment> {
  ApplicationEnvironmentResolver._();

  static ApplicationEnvironmentResolver _instance;

  static ApplicationEnvironmentResolver instance() {
    return _instance ?? (_instance = ApplicationEnvironmentResolver._());
  }

  ApplicationEnvironment _environment;

  @override
  Future<ApplicationEnvironment> resolve(bootstrapArguments) async {
    _environment = ApplicationEnvironment(bootstrapArguments[APPLICATION_ENVIRONMENT_VARIABLE], true);
    return Future.value(_environment);
  }

  @override
  Future<ApplicationEnvironment> get() async {
    return Future.value(_environment);
  }
}
