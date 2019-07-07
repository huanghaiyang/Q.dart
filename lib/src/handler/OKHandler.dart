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
  Future<Context> handle(Context ctx) async {
    HttpResponse httpResponse = ctx.response.res;
    httpResponse.statusCode = ctx.status;
    httpResponse.headers.contentType = ctx.router.contentType;
    httpResponse.write(ctx.response.responseEntry.convertedResult);
    await httpResponse.close();
    return ctx;
  }
}
