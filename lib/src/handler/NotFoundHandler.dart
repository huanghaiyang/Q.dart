import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

class NotFoundHandler extends HandlerAdapter {
  @override
  Future<Context> handle(Context ctx) async {
    ctx.status = HttpStatus.notFound;
    HttpResponse httpResponse = ctx.response.res;
    httpResponse.statusCode = ctx.status;
    await httpResponse.close();
    return ctx;
  }
}
