import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';

class StringHttpMessageConverter implements AbstractHttpMessageConverter {
  StringHttpMessageConverter._();

  static StringHttpMessageConverter _instance;

  static StringHttpMessageConverter instance() {
    return _instance ?? (_instance = StringHttpMessageConverter._());
  }

  @override
  Future convert([dynamic result]) async {
    return null;
  }
}
