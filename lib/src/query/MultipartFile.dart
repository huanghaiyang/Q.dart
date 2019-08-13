import 'dart:io';

import 'package:Q/src/query/Value.dart';

abstract class MultipartFile extends Value {
  String get originName;

  set originName(String originName);

  ContentType get contentType;

  set contentType(ContentType contentType);

  int get size;

  set size(int size);

  List<int> get bytes;

  set bytes(List<int> bytes);

  Future<File> transferTo(String dest);

  factory MultipartFile({String name, String originName, ContentType contentType, int size, List<int> bytes}) =>
      _MultipartFile(name_: name, originName_: originName, contentType_: contentType, size_: size, bytes_: bytes);
}

class _MultipartFile implements MultipartFile {
  String name_;

  String originName_;

  ContentType contentType_;

  int size_;

  List<int> bytes_;

  _MultipartFile({this.name_, this.originName_, this.contentType_, this.size_, this.bytes_});

  @override
  ContentType get contentType {
    return this.contentType_;
  }

  @override
  set name(String name) {
    this.name_ = name;
  }

  @override
  set bytes(List<int> bytes) {
    this.bytes_ = bytes;
  }

  @override
  List<int> get bytes {
    return this.bytes_;
  }

  @override
  set size(int size) {
    this.size_ = size;
  }

  @override
  int get size {
    return this.size_;
  }

  @override
  String get originName {
    return this.originName_;
  }

  @override
  String get name {
    return this.name_;
  }

  @override
  set contentType(ContentType contentType) {
    this.contentType_ = contentType;
  }

  @override
  set originName(String originName) {
    this.originName_ = originName;
  }

  @override
  Future<File> transferTo(String dest) {
    File file = File(dest);
    return file.writeAsBytes(this.bytes);
  }
}
