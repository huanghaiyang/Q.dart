import 'dart:convert';
import 'dart:core';

import 'package:Q/src/converter/AbstractHttpMessageConverter.dart';

class JSONHttpMessageConverter implements AbstractHttpMessageConverter {
  JSONHttpMessageConverter._();

  static JSONHttpMessageConverter _instance;

  static JSONHttpMessageConverter instance() {
    return _instance ?? (_instance = JSONHttpMessageConverter._());
  }

  @override
  Future convert([dynamic entry]) async {
    return jsonEncode(entry);
  }
}
