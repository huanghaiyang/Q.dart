import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

class OKHandler implements HandlerAdapter {
  OKHandler._();

  static OKHandler _instance;

  static OKHandler getInstance() {
    if (_instance == null) {
      _instance = OKHandler._();
    }
    return _instance;
  }

  @override
  Future<Context> handle(Context context) async {
    HttpResponse httpResponse = context.response.res;
    httpResponse.statusCode = context.response.status;
    httpResponse.headers.contentType = context.router.produceType;
    httpResponse.write(context.response.responseEntry.convertedResult);
    return context;
  }
}
