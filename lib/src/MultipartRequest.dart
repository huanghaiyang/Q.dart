import 'dart:io';

import 'package:Q/src/Request.dart';

class MultipartRequest extends Request {
  List<File> files = List();
}
