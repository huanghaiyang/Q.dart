import 'package:Q/src/Context.dart';

abstract class Middleware {
  Future<Context> handle(Context ctx, Function onFinished, Function onError);
}
