import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

class NotFoundHandler implements HandlerAdapter {
  NotFoundHandler._();

  static NotFoundHandler _instance;

  static NotFoundHandler instance() {
    return _instance ?? (_instance = NotFoundHandler._());
  }

  @override
  Future<Context> handle(Context context) async {
    context.response.status = HttpStatus.notFound;
    HttpResponse httpResponse = context.response.res;
    httpResponse.statusCode = context.response.status;
    await httpResponse.close();
    return context;
  }
}
