import 'dart:async';

import 'package:Q/src/Context.dart';

abstract class HandlerAdapter {
  Future<dynamic> handle(Context ctx);
}
