import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

class NotFoundHandler implements HandlerAdapter {
  NotFoundHandler._();

  static NotFoundHandler _instance;

  static NotFoundHandler getInstance() {
    if (_instance == null) {
      _instance = NotFoundHandler._();
    }
    return _instance;
  }

  @override
  Future<Context> handle(Context ctx) async {
    ctx.status = HttpStatus.notFound;
    HttpResponse httpResponse = ctx.response.res;
    httpResponse.statusCode = ctx.status;
    await httpResponse.close();
    return ctx;
  }
}