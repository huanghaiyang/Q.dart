import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

class OKHandler implements HandlerAdapter {
  OKHandler._();

  static OKHandler _instance;

  static OKHandler instance() {
    if (_instance == null) {
      _instance = OKHandler._();
    }
    return _instance;
  }

  @override
  Future<Context> handle(Context context) async {
    HttpResponse httpResponse = context.response.res;
    httpResponse.statusCode = context.response.status;
    httpResponse.headers.contentType = context?.router?.produceType != null
        ? context.router.produceType
        : Application.getApplicationContext().configuration.httpResponseConfigure.defaultProducedType;
    httpResponse.write(context.response.responseEntry.convertedResult);
    return context;
  }
}
