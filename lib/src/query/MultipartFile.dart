import 'dart:io';

import 'package:Q/src/query/Value.dart';

class MultipartFile extends Value {
  String originName;

  ContentType contentType;

  int size;

  List<int> bytes;

  MultipartFile({String name, this.originName, this.contentType, this.size, this.bytes}) : super(name);
}
