import 'package:Q/src/Configuration.dart';

class ApplicationContext {
  ApplicationContext._();

  static ApplicationContext _instance;

  static ApplicationContext getInstance() {
    if (_instance == null) {
      _instance = ApplicationContext._();
    }
    return _instance;
  }

  Configuration configuration = Configuration.getInstance();
}
