import 'package:Q/src/aware/ApplicationConfigurationResourceValidatorAware.dart';
import 'package:Q/src/resource/ApplicationConfigurationResource.dart';

class ApplicationConfigurationResourceValidator
    implements ApplicationConfigurationResourceValidatorAware<List<ApplicationConfigurationResource>, bool> {
  ApplicationConfigurationResourceValidator._();

  static ApplicationConfigurationResourceValidator _instance;

  static ApplicationConfigurationResourceValidator instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationResourceValidator._();
    }
    return _instance;
  }

  @override
  Future<bool> check(List<ApplicationConfigurationResource> resources) async {
    return true;
  }
}
