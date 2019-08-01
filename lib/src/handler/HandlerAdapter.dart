import 'dart:async';

import 'package:Q/src/Context.dart';

abstract class HandlerAdapter {
  Future<Context> handle(Context context);
}
