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

  KnuthMorrisPrattMatcher dispositionMatcher;

  Map<String, List<Map>> result;

  Future<Map<String, List<Map>>> transform(HttpRequest req, List<int> data) async {
    this.boundaryUnits = boundary(req);
    this.data = data;
    this.needle = concat([FIRST_BOUNDARY_PREFIX, this.boundaryUnits, CR, LF]);
    this.matcher = KnuthMorrisPrattMatcher(needle);
    this.body = this.skipUntilFirstBoundary(this.data, this.matcher);
    this.partitions = this.split(this.body, this.needle, this.matcher);
    this.result = this.mapResult(this.partitions);
    return result;
  }

  // 跳过第一个boundary,使用KMP算法进行匹配
  List<int> skipUntilFirstBoundary(List<int> data, KnuthMorrisPrattMatcher matcher) {
    int endIndex = matcher.match(data);
    if (endIndex != -1) {
      List<int> slice = List.from(data.getRange(endIndex + 1, data.length));
      return slice;
    }
    return [];
  }

  List<List<int>> split(List<int> data, List<int> needle, KnuthMorrisPrattMatcher matcher) {
    List<List<int>> partitions = List();

    while (true) {
      int endIndex = matcher.match(data);
      if (endIndex == -1) {
        break;
      }
      partitions.add(List.from(data.getRange(0, endIndex - needle.length)));
      data = List.from(data.getRange(endIndex + 1, data.length));
    }
    return partitions;
  }

  Map<String, List<Map>> mapResult(List<List<int>> partitions) {
    Map<String, List<Map>> result = Map();

    KnuthMorrisPrattMatcher knuthMorrisPrattMatcher = KnuthMorrisPrattMatcher(concat(DELIMITER));
    partitions.forEach((List<int> partition) {
      Map props = Map();
      int splitIndex = knuthMorrisPrattMatcher.match(partition);
      String info = String.fromCharCodes(partition.getRange(0, splitIndex - knuthMorrisPrattMatcher.delimiter.length + 1));
      int contentTypeIndex = info.indexOf(RegExp(CONTENT_TYPE));
      if (contentTypeIndex != -1) {
        props['contentType'] = info.substring(contentTypeIndex + CONTENT_TYPE.length);
        info = info.substring(CONTENT_DISPOSITION.length, contentTypeIndex).replaceAll(RegExp(HEADER_SEPARATOR), '');
        props['result'] = partition.sublist(splitIndex + 1, partition.length - 1);
      } else {
        info = info.substring(CONTENT_DISPOSITION.length);
        props['result'] = String.fromCharCodes(partition.sublist(splitIndex + 1, partition.length - 1));
      }
      info.split(RegExp("; ")).forEach((str) {
        List<String> kv = str.split(RegExp("="));
        props[kv[0]] = kv[1].substring(1, kv[1].length - 1);
      });
      if (props.containsKey(NAME_KEY)) {
        String name = props[NAME_KEY];
        if (!result.containsKey(name)) {
          result[name] = List();
        }
        props.remove(NAME_KEY);
        result[name].add(props);
      }
    });
    print(result);
    return result;
  }
}
