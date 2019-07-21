import 'dart:io';

class Configuration {
  Configuration._();

  static Configuration _instance;

  static Configuration getInstance() {
    if (_instance == null) {
      _instance = Configuration._();
    }
    return _instance;
  }

  List<ContentType> unSupportedContentTypes = List();
}
