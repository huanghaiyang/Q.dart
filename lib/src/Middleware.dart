import 'package:Q/src/Context.dart';

abstract class Middleware {
  MiddlewareType type = MiddlewareType.AFTER;

  Future<Context> handle(Context ctx, Function onFinished, Function onError);
}

enum MiddlewareType { BEFORE, AFTER }
