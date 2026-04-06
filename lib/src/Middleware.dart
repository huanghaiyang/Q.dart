import 'package:Q/src/Context.dart';

abstract class Middleware {
  MiddlewareType type = MiddlewareType.AFTER;
  int priority = 0; // 优先级，值越大优先级越高
  String name;
  String group;

  Future<Context> handle(Context context, Function onFinished, Function onError);
}

enum MiddlewareType { BEFORE, AFTER }
