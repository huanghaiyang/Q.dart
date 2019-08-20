import 'dart:convert';
import 'dart:io';

import 'package:Q/src/helpers/QueryHelper.dart';
import 'package:Q/src/multipart/KnuthMorrisPrattMatcher.dart';
import 'package:Q/src/multipart/MultipartValueMap.dart';
import 'package:Q/src/multipart/RequestPart.dart';
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

Future<MultipartValueMap> transform(HttpRequest req, List<int> data, {
  bool fixNameSuffixIfArray = true
}) async {
  List<int> boundaryUnits = boundary(req);
  List<int> needle = concat([FIRST_BOUNDARY_PREFIX, boundaryUnits]);
  KnuthMorrisPrattMatcher matcher = KnuthMorrisPrattMatcher(needle);
  List<int> body = skipUntilFirstBoundary(data, matcher);
  List<RequestPart> requestParts = split(body, needle, matcher);
  MultipartValueMap result = mapResult(requestParts, fixNameSuffixIfArray);
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

List<RequestPart> split(List<int> data, List<int> needle, KnuthMorrisPrattMatcher matcher) {
  List<RequestPart> requestParts = List();
  while (true) {
    int endIndex = matcher.match(data);
    if (endIndex == -1) {
      break;
    }
    List<int> bytes = List.from(data.getRange(0, endIndex - needle.length));
    requestParts.add(RequestPart(bytes.sublist(2, bytes.length - 1)));
    data = List.from(data.getRange(endIndex + 1, data.length));
  }
  return requestParts;
}

Map getProps(String info, bool fixNameSuffixIfArray) {
  Map namedMap = Map();
  info.split(RegExp("; ")).forEach((str) {
    List<String> kv = str.split(RegExp("="));
    String key = kv[1].substring(1, kv[1].length - 1);
    if (fixNameSuffixIfArray) {
      namedMap[kv[0]] = QueryHelper.fixQueryKey(key);
    } else {
      namedMap[kv[0]] = key;
    }
  });
  if (fixNameSuffixIfArray) {
    namedMap = QueryHelper.fixData(namedMap);
  }
  return namedMap;
}

MultipartValueMap mapResult(List<RequestPart> requestParts, bool fixNameSuffixIfArray) {
  Map<String, List<Value>> result = Map();

  KnuthMorrisPrattMatcher knuthMorrisPrattMatcher = KnuthMorrisPrattMatcher(concat(DELIMITER));
  requestParts.forEach((RequestPart requestPart) {
    Value value;
    int splitIndex = knuthMorrisPrattMatcher.match(requestPart.bytes);
    String info = String.fromCharCodes(requestPart.bytes.getRange(0, splitIndex - knuthMorrisPrattMatcher.delimiter.length + 1));
    int contentTypeIndex = info.indexOf(RegExp(CONTENT_TYPE));
    List<int> contentBytes = requestPart.bytes.sublist(splitIndex + 1, requestPart.bytes.length);
    if (contentTypeIndex != -1) {
      MultipartFile namedValue = MultipartFile();
      namedValue.contentType = ContentType.parse(info.substring(contentTypeIndex + CONTENT_TYPE.length));
      info = info.substring(CONTENT_DISPOSITION.length, contentTypeIndex).replaceAll(RegExp(HEADER_SEPARATOR), '');
      namedValue.bytes = contentBytes;
      namedValue.size = contentBytes.length;
      Map props = getProps(info, fixNameSuffixIfArray);
      namedValue.name = props['name'];
      namedValue.originName = props['filename'];
      value = namedValue;
    } else {
      info = info.substring(CONTENT_DISPOSITION.length);
      CommonValue namedValue = CommonValue();
      namedValue.value = utf8.decode(contentBytes);
      Map props = getProps(info, fixNameSuffixIfArray);
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
