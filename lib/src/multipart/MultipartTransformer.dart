import 'dart:io';

import 'package:Q/src/multipart/KnuthMorrisPrattMatcher.dart';

List<int> CR = '\r'.codeUnits;

List<int> LF = '\n'.codeUnits;

List<int> HYPHEN = '-'.codeUnits;

List<int> FIRST_BOUNDARY_PREFIX = List()..addAll(HYPHEN)..addAll(HYPHEN);

List<List<int>> DELIMITER = [CR, LF, CR, LF];

String HEADER_SEPARATOR = "\r\n";

String CONTENT_DISPOSITION = 'Content-Disposition: form-data; ';

String CONTENT_TYPE = 'Content-Type: ';

String NAME_KEY = 'name';

// 从请求头的请求类型中读取boundary
List<int> boundary(HttpRequest req) {
  ContentType contentType = req.headers.contentType;
  if (contentType != null) {
    String boundary = contentType.parameters['boundary'];
    if (boundary != null) {
      return boundary.codeUnits;
    }
  }
  return null;
}

// 数据组合
List<int> concat(List<List<int>> byteArrays) {
  int length = 0;
  for (List<int> byteArray in byteArrays) {
    length += byteArray.length;
  }
  List<int> result = List(length);
  length = 0;
  for (List<int> byteArray in byteArrays) {
    result.setRange(length, length + byteArray.length, byteArray);
    length += byteArray.length;
  }
  return result;
}

Future<Map<String, List<Map>>> transform(HttpRequest req, List<int> data) async {
  List<int> boundaryUnits = boundary(req);
  List<int> needle = concat([FIRST_BOUNDARY_PREFIX, boundaryUnits, CR, LF]);
  KnuthMorrisPrattMatcher matcher = KnuthMorrisPrattMatcher(needle);
  List<int> body = skipUntilFirstBoundary(data, matcher);
  List<List<int>> partitions = split(body, needle, matcher);
  Map<String, List<Map>> result = mapResult(partitions);
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
    List<int> contentBytes = partition.sublist(splitIndex + 1, partition.length - 1);
    if (contentTypeIndex != -1) {
      props['contentType'] = info.substring(contentTypeIndex + CONTENT_TYPE.length);
      info = info.substring(CONTENT_DISPOSITION.length, contentTypeIndex).replaceAll(RegExp(HEADER_SEPARATOR), '');
      props['content'] = contentBytes;
    } else {
      info = info.substring(CONTENT_DISPOSITION.length);
      props['content'] = String.fromCharCodes(contentBytes);
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
  return result;
}
