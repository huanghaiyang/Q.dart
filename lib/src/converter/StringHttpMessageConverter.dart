import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';

class StringHttpMessageConverter extends AbstractHttpMessageConverter {
  StringHttpMessageConverter._();

  static StringHttpMessageConverter _instance;

  static StringHttpMessageConverter getInstance() {
    if (_instance == null) {
      _instance = StringHttpMessageConverter._();
    }
    return _instance;
  }

  @override
  Future convert([dynamic result]) async {
    return null;
  }
}
