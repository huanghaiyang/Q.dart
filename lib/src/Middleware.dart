import 'package:Q/src/Context.dart';

class Middleware {
  Future<Context> handle(Context ctx) async {
    // 处理context
    return ctx;
  }
}
