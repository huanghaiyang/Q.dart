import 'dart:io';

import 'package:Q/src/multipart/KnuthMorrisPrattMatcher.dart';
import 'package:Q/src/multipart/MultipartHelper.dart';

class MultipartTransformer {
  MultipartTransformer();

  KnuthMorrisPrattMatcher matcher;

  List<int> data;

  List<int> boundaryUnits;

  List<int> body;

  List<List<int>> partitions;

  List<int> needle;

  void getBoundary(HttpRequest req) {
    this.boundaryUnits = boundary(req);
  }

  Future<Map> transform(HttpRequest req, List<int> data) async {
    this.getBoundary(req);
    this.data = data;
    this.needle = concat([FIRST_BOUNDARY_PREFIX, this.boundaryUnits, CR, LF]);
    this.matcher = KnuthMorrisPrattMatcher(needle);
    this.body = this.skipUntilFirstBoundary(this.data);
    this.partitions = this.split();
    return Map();
  }

  // 跳过第一个boundary,使用KMP算法进行匹配
  List<int> skipUntilFirstBoundary(List<int> data) {
    int endIndex = this.matcher.match(data);
    if (endIndex != -1) {
      List<int> slice = List.from(data.getRange(endIndex + 1, data.length));
      return slice;
    }
    return [];
  }

  List<List<int>> split() {
    List<List<int>> partitions = List();
    List<int> data = this.body;

    while (true) {
      int endIndex = this.matcher.match(data);
      if (endIndex == -1) {
        break;
      }
      partitions
          .add(List.from(data.getRange(0, endIndex - this.needle.length)));
      data = List.from(data.getRange(endIndex + 1, data.length));
    }
    return partitions;
  }
}
