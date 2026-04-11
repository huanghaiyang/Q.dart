import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/Context.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

class OKHandler implements HandlerAdapter {
  OKHandler._();

  static OKHandler _instance;

  static OKHandler instance() {
    return _instance ?? (_instance = OKHandler._());
  }

  @override
  Future<Context> handle(Context context) async {
    HttpResponse httpResponse = context.response.res;
    httpResponse.statusCode = context.response.status;
    var applicationContext = Application.getApplicationContext();
    httpResponse.headers.contentType = context?.router?.produceType != null
        ? context.router.produceType
        : applicationContext?.configuration?.httpResponseConfigure?.defaultProducedType ?? ContentType.json;
    httpResponse.headers.add('Access-Control-Allow-Origin', '*');
    httpResponse.headers.add('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    httpResponse.write(context.response.responseEntry.convertedResult);
    return context;
  }
}
