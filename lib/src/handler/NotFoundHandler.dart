import 'dart:io';

import 'package:Q/src/Context.dart';
import 'package:Q/src/handler/HandlerAdapter.dart';

class NotFoundHandler extends HandlerAdapter {
  @override
  Future<Context> handle(Context ctx) async {
    ctx.status = HttpStatus.notFound;
    ctx.response.res.statusCode = ctx.status;
    return ctx;
  }
}
