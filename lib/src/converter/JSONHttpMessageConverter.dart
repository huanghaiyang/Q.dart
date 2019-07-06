import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';

class JSONHttpMessageConverter extends AbstractHttpMessageConverter {
  JSONHttpMessageConverter._();

  static JSONHttpMessageConverter _instance;

  static JSONHttpMessageConverter getInstance() {
    if (_instance == null) {
      _instance = JSONHttpMessageConverter._();
    }
    return _instance;
  }

  @override
  Future convert([dynamic entry]) async {}
}
