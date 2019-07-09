import 'dart:io';

import 'package:Q/src/Request.dart';

abstract class AbstractResolver {
  Future<Request> resolve(HttpRequest req);

  Future<bool> isMe(HttpRequest req);
}
