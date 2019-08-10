import 'dart:convert';
import 'dart:io';

import 'package:Q/src/helpers/QueryHelper.dart';
import 'package:Q/src/multipart/KnuthMorrisPrattMatcher.dart';
import 'package:Q/src/multipart/MultipartValueMap.dart';
import 'package:Q/src/query/CommonValue.dart';
import 'package:Q/src/query/MultipartFile.dart';
import 'package:Q/src/query/Value.dart';
import 'package:Q/src/utils/ListUtil.dart';

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

Future<MultipartValueMap> transform(HttpRequest req, List<int> data) async {
  List<int> boundaryUnits = boundary(req);
  List<int> needle = concat([FIRST_BOUNDARY_PREFIX, boundaryUnits, CR, LF]);
  KnuthMorrisPrattMatcher matcher = KnuthMorrisPrattMatcher(needle);
  List<int> body = skipUntilFirstBoundary(data, matcher);
  List<List<int>> partitions = split(body, needle, matcher);
  MultipartValueMap result = mapResult(partitions);
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
      KnuthMorrisPrattMatcher endMatcher = KnuthMorrisPrattMatcher(matcher.delimiter.sublist(0, matcher.delimiter.length - 2));
      endIndex = endMatcher.match(data);
      if (endIndex == -1) {
        break;
      }
    }
    partitions.add(List.from(data.getRange(0, endIndex - needle.length)));
    data = List.from(data.getRange(endIndex + 1, data.length));
  }
  return partitions;
}

Map getProps(String info) {
  Map namedMap = Map();
  info.split(RegExp("; ")).forEach((str) {
    List<String> kv = str.split(RegExp("="));
    namedMap[kv[0]] = QueryHelper.fixQueryKey(kv[1].substring(1, kv[1].length - 1));
  });
  namedMap = QueryHelper.fixData(namedMap);
  return namedMap;
}

MultipartValueMap mapResult(List<List<int>> partitions) {
  Map<String, List<Value>> result = Map();

  KnuthMorrisPrattMatcher knuthMorrisPrattMatcher = KnuthMorrisPrattMatcher(concat(DELIMITER));
  partitions.forEach((List<int> partition) {
    Value value;
    int splitIndex = knuthMorrisPrattMatcher.match(partition);
    String info = String.fromCharCodes(partition.getRange(0, splitIndex - knuthMorrisPrattMatcher.delimiter.length + 1));
    int contentTypeIndex = info.indexOf(RegExp(CONTENT_TYPE));
    List<int> contentBytes = partition.sublist(splitIndex + 1, partition.length - 1);
    if (contentTypeIndex != -1) {
      MultipartFile namedValue = MultipartFile();
      namedValue.contentType = ContentType.parse(info.substring(contentTypeIndex + CONTENT_TYPE.length));
      info = info.substring(CONTENT_DISPOSITION.length, contentTypeIndex).replaceAll(RegExp(HEADER_SEPARATOR), '');
      namedValue.bytes = contentBytes;
      namedValue.size = contentBytes.length;
      Map props = getProps(info);
      namedValue.name = props['name'];
      namedValue.originName = props['filename'];
      value = namedValue;
    } else {
      info = info.substring(CONTENT_DISPOSITION.length);
      CommonValue namedValue = CommonValue();
      namedValue.value = utf8.decode(contentBytes);
      Map props = getProps(info);
      namedValue.name = props['name'];
      value = namedValue;
    }
    if (!result.containsKey(value.name)) {
      result[value.name] = List();
    }
    result[value.name].add(value);
  });
  return MultipartValueMap.from(result);
}
