import 'package:Q/src/aware/ApplicationConfigurationLoaderAware.dart';

class ApplicationConfigurationLoader extends ApplicationConfigurationLoaderAware {
  ApplicationConfigurationLoader._();

  static ApplicationConfigurationLoader _instance;

  static ApplicationConfigurationLoader instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationLoader._();
    }
    return _instance;
  }

  @override
  Future load() async {}
}
