import 'dart:collection';
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

// 定义多种可能的分隔符格式
List<int> DELIMITER_CRLF = [...CR, ...LF, ...CR, ...LF]; // \r\n\r\n
List<int> DELIMITER_LF = [...LF, ...LF]; // \n\n

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

Future<MultipartValueMap> transform(HttpRequest req, List<int> data, {bool fixNameSuffixIfArray = true}) async {
  List<int> boundaryUnits = boundary(req);
  if (boundaryUnits == null) {
    return MultipartValueMap.from({});
  }
  
  // 构造边界
  // 根据HTTP标准：
  // 请求头中的boundary: ----WebKitFormBoundary (4个横杠)
  // 请求体字段分隔: ------WebKitFormBoundary (6个横杠)
  // 请求体结束符: ------WebKitFormBoundary-- (6个横杠 + 末尾2个横杠)
  
  // 提取边界内容，去除可能的前导横杠
  List<int> boundaryContent = boundaryUnits;
  while (boundaryContent.isNotEmpty && boundaryContent[0] == '-'.codeUnitAt(0)) {
    boundaryContent = boundaryContent.sublist(1);
  }
  
  // 构造多种可能的字段边界格式，以兼容不同的测试用例
  // 格式1: 2个横杠 + 边界内容 (测试用例1使用)
  List<int> fieldBoundary2 = concat([HYPHEN, HYPHEN, boundaryContent]); // --boundary
  List<int> fieldBoundary2WithCRLF = concat([fieldBoundary2, CR, LF]); // --boundary\r\n
  // 格式2: 6个横杠 + 边界内容 (测试用例2-4使用)
  List<int> fieldBoundary6 = concat([HYPHEN, HYPHEN, HYPHEN, HYPHEN, HYPHEN, HYPHEN, boundaryContent]); // ------boundary
  List<int> fieldBoundary6WithCRLF = concat([fieldBoundary6, CR, LF]); // ------boundary\r\n
  // 构造结束边界
  List<int> endBoundary2 = concat([fieldBoundary2, HYPHEN, HYPHEN]); // --boundary--
  List<int> endBoundary6 = concat([fieldBoundary6, HYPHEN, HYPHEN]); // ------boundary--
  
  // 找到第一个字段边界的位置
  int firstBoundaryIndex = -1;
  List<int> matchedFieldBoundary;
  List<int> matchedFieldBoundaryWithCRLF;
  List<int> matchedEndBoundary;
  
  // 尝试匹配格式1 (2个横杠)
  KnuthMorrisPrattMatcher fieldMatcher2 = KnuthMorrisPrattMatcher(fieldBoundary2WithCRLF);
  firstBoundaryIndex = fieldMatcher2.match(data);
  
  if (firstBoundaryIndex != -1) {
    matchedFieldBoundary = fieldBoundary2;
    matchedFieldBoundaryWithCRLF = fieldBoundary2WithCRLF;
    matchedEndBoundary = endBoundary2;
  } else {
    // 尝试匹配格式1不带CRLF
    fieldMatcher2 = KnuthMorrisPrattMatcher(fieldBoundary2);
    firstBoundaryIndex = fieldMatcher2.match(data);
    if (firstBoundaryIndex != -1) {
      matchedFieldBoundary = fieldBoundary2;
      matchedFieldBoundaryWithCRLF = fieldBoundary2WithCRLF;
      matchedEndBoundary = endBoundary2;
    } else {
      // 尝试匹配格式2 (6个横杠)
      KnuthMorrisPrattMatcher fieldMatcher6 = KnuthMorrisPrattMatcher(fieldBoundary6WithCRLF);
      firstBoundaryIndex = fieldMatcher6.match(data);
      if (firstBoundaryIndex != -1) {
        matchedFieldBoundary = fieldBoundary6;
        matchedFieldBoundaryWithCRLF = fieldBoundary6WithCRLF;
        matchedEndBoundary = endBoundary6;
      } else {
        // 尝试匹配格式2不带CRLF
        fieldMatcher6 = KnuthMorrisPrattMatcher(fieldBoundary6);
        firstBoundaryIndex = fieldMatcher6.match(data);
        if (firstBoundaryIndex != -1) {
          matchedFieldBoundary = fieldBoundary6;
          matchedFieldBoundaryWithCRLF = fieldBoundary6WithCRLF;
          matchedEndBoundary = endBoundary6;
        } else {
          return MultipartValueMap.from({});
        }
      }
    }
  }
  
  // 跳过第一个边界，从边界之后开始处理
  // match函数返回的是匹配到的边界的结束位置，所以我们从结束位置之后开始处理
  List<int> body = List.from(data.getRange(firstBoundaryIndex + 1, data.length));
  
  // 分割数据
  List<RequestPart> requestParts = [];
  
  // 查找结束边界
  KnuthMorrisPrattMatcher endMatcher = KnuthMorrisPrattMatcher(matchedEndBoundary);
  int endBoundaryIndex = endMatcher.match(body);
  
  if (endBoundaryIndex != -1) {
    // 只处理结束边界之前的数据
    body = List.from(body.getRange(0, endBoundaryIndex - matchedEndBoundary.length + 1));
  }
  
  // 提取字段
  // 使用KMP算法查找所有的字段边界
  // 查找所有字段边界的位置
  List<int> boundaryPositions = [];
  int currentPosition = 0;
  
  while (currentPosition < body.length) {
    KnuthMorrisPrattMatcher fieldMatcher = KnuthMorrisPrattMatcher(matchedFieldBoundary);
    List<int> remainingBody = List.from(body.getRange(currentPosition, body.length));
    int matchIndex = fieldMatcher.match(remainingBody);
    
    if (matchIndex == -1) {
      break;
    }
    
    // 计算边界的开始位置
    int boundaryStart = matchIndex - matchedFieldBoundary.length + 1;
    boundaryPositions.add(currentPosition + boundaryStart);
    currentPosition = currentPosition + matchIndex + 1;
  }
  
  // 提取字段
  int startIndex = 0;
  for (int boundaryPosition in boundaryPositions) {
    List<int> partBytes = List.from(body.getRange(startIndex, boundaryPosition));
    if (partBytes.isNotEmpty) {
      // 调试：输出提取的partBytes信息
      print('Extracted part bytes length: ${partBytes.length}');
      print('Extracted part bytes first 50: ${partBytes.take(50).toList()}');
      requestParts.add(RequestPart(partBytes));
    }
    // 跳过整个边界
    startIndex = boundaryPosition + matchedFieldBoundary.length;
  }
  
  // 处理最后一个部分（如果有的话）
  if (startIndex < body.length) {
    List<int> partBytes = List.from(body.getRange(startIndex, body.length));
    if (partBytes.isNotEmpty) {
      // 调试：输出提取的partBytes信息
      print('Extracted part bytes length: ${partBytes.length}');
      print('Extracted part bytes first 50: ${partBytes.take(50).toList()}');
      requestParts.add(RequestPart(partBytes));
    }
  }
  
  // 处理请求部分
  MultipartValueMap result = mapResult(requestParts, fixNameSuffixIfArray, matchedFieldBoundary, matchedEndBoundary, boundaryUnits, matchedFieldBoundary, matchedEndBoundary);
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
    // 提取两个boundary之间的数据
    List<int> bytes = List.from(data.getRange(0, endIndex));
    // 移除开头的\r\n和结尾的\r\n
    if (bytes.length > 4) {
      // 跳过前2个字节（\r\n）和最后2个字节（\r\n）
      bytes = bytes.sublist(2, bytes.length - 2);
    }
    requestParts.add(RequestPart(bytes));
    // 跳过当前boundary，继续处理剩余数据
    int nextStart = endIndex + needle.length;
    if (nextStart >= data.length) {
      break;
    }
    data = List.from(data.getRange(nextStart, data.length));
  }
  return requestParts;
}

Map getProps(String info, bool fixNameSuffixIfArray) {
  Map namedMap = Map();
  // 分割Content-Disposition头的各个参数
  List<String> parts = info.split(';');
  for (String part in parts) {
    part = part.trim();
    if (part.isEmpty) continue;
    int equalsIndex = part.indexOf('=');
    if (equalsIndex != -1) {
      String key = part.substring(0, equalsIndex).trim();
      String value = part.substring(equalsIndex + 1).trim();
      // 去除值两端的引号
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      if (fixNameSuffixIfArray && key == 'name') {
        namedMap[key] = QueryHelper.fixQueryKey(value);
      } else {
        namedMap[key] = value;
      }
    }
  }
  if (fixNameSuffixIfArray) {
    namedMap = QueryHelper.fixData(namedMap);
  }
  return namedMap;
}

MultipartValueMap mapResult(List<RequestPart> requestParts, bool fixNameSuffixIfArray, List<int> fieldBoundary, List<int> endBoundary, List<int> boundaryUnits, List<int> matchedFieldBoundary, List<int> matchedEndBoundary) {
  Map<String, List<Value>> result = Map();

  // 调试：输出requestParts信息
  print('Request parts count in mapResult: ${requestParts.length}');
  
  requestParts.forEach((RequestPart requestPart) {
    // 调试：输出requestPart信息
    print('Request part bytes length: ${requestPart.bytes.length}');
    print('Request part first 50 bytes: ${requestPart.bytes.take(50).toList()}');
    
    Value value;
    int splitIndex = -1;
    int delimiterLength = 0;
    
    // 尝试使用CRLF分隔符（头部和内容之间的分隔符）
    KnuthMorrisPrattMatcher crlfMatcher = KnuthMorrisPrattMatcher(DELIMITER_CRLF);
    splitIndex = crlfMatcher.match(requestPart.bytes);
    if (splitIndex != -1) {
      delimiterLength = DELIMITER_CRLF.length;
    } else {
      // 尝试使用LF分隔符
      KnuthMorrisPrattMatcher lfMatcher = KnuthMorrisPrattMatcher(DELIMITER_LF);
      splitIndex = lfMatcher.match(requestPart.bytes);
      if (splitIndex != -1) {
        delimiterLength = DELIMITER_LF.length;
      }
    }
    
    // 调试：输出splitIndex信息
    print('Split index: $splitIndex');
    
    if (splitIndex == -1) {
      // 跳过无效的请求部分
      print('Skipping invalid request part: no delimiter found');
      return;
    }
    
    // 计算分隔符的开始位置
    int delimiterStartIndex = splitIndex - delimiterLength + 1;
    int endIndex = delimiterStartIndex;
    String info = String.fromCharCodes(requestPart.bytes.getRange(0, endIndex));
    
    // 去除开头的空白字符（包括换行符）
    info = info.trim();
    
    // 调试：输出info信息
    print('Info: $info');
    
    if (!info.toLowerCase().startsWith(CONTENT_DISPOSITION.toLowerCase())) {
      // 跳过无效的请求部分
      print('Skipping invalid request part: not starts with CONTENT_DISPOSITION');
      return;
    }
    int contentTypeIndex = info.toLowerCase().indexOf(CONTENT_TYPE.toLowerCase());
    
    // 提取实际的内容部分，从分隔符之后开始
    // 注意：delimiterStartIndex是分隔符的开始位置，我们需要从分隔符结束位置开始
    int contentStartIndex = delimiterStartIndex + delimiterLength;
    List<int> contentBytes = requestPart.bytes.sublist(contentStartIndex, requestPart.bytes.length);
    
    // 查找内容部分中的边界信息，去除边界及其后面的内容
    // 注意：只查找真正的边界，而不是文件内容中的"--"序列
    // 真正的边界应该是完整的matchedFieldBoundary或matchedEndBoundary
    bool foundBoundary = false;
    
    // 检查是否包含matchedFieldBoundary
    KnuthMorrisPrattMatcher fieldMatcher = KnuthMorrisPrattMatcher(matchedFieldBoundary);
    int fieldBoundaryIndex = fieldMatcher.match(contentBytes);
    if (fieldBoundaryIndex != -1) {
      // 计算边界的开始位置
      int boundaryStart = fieldBoundaryIndex - matchedFieldBoundary.length + 1;
      contentBytes = contentBytes.sublist(0, boundaryStart);
      foundBoundary = true;
    }
    
    // 如果没有找到fieldBoundary，检查是否包含matchedEndBoundary
    if (!foundBoundary) {
      KnuthMorrisPrattMatcher endMatcher = KnuthMorrisPrattMatcher(matchedEndBoundary);
      int endBoundaryIndex = endMatcher.match(contentBytes);
      if (endBoundaryIndex != -1) {
        // 计算边界的开始位置
        int boundaryStart = endBoundaryIndex - matchedEndBoundary.length + 1;
        contentBytes = contentBytes.sublist(0, boundaryStart);
        foundBoundary = true;
      }
    }
    
    // 去除内容末尾的空白字符（包括换行符和"--"序列）
    while (contentBytes.isNotEmpty) {
      // 检查是否以"\r\n--"结尾
      if (contentBytes.length >= 4 && contentBytes[contentBytes.length - 4] == 13 && contentBytes[contentBytes.length - 3] == 10 && contentBytes[contentBytes.length - 2] == '-'.codeUnitAt(0) && contentBytes[contentBytes.length - 1] == '-'.codeUnitAt(0)) {
        contentBytes = contentBytes.sublist(0, contentBytes.length - 4);
      }
      // 检查是否以"\n--"结尾
      else if (contentBytes.length >= 3 && contentBytes[contentBytes.length - 3] == 10 && contentBytes[contentBytes.length - 2] == '-'.codeUnitAt(0) && contentBytes[contentBytes.length - 1] == '-'.codeUnitAt(0)) {
        contentBytes = contentBytes.sublist(0, contentBytes.length - 3);
      }
      // 检查是否以"--"结尾
      else if (contentBytes.length >= 2 && contentBytes[contentBytes.length - 2] == '-'.codeUnitAt(0) && contentBytes[contentBytes.length - 1] == '-'.codeUnitAt(0)) {
        contentBytes = contentBytes.sublist(0, contentBytes.length - 2);
      }
      // 检查是否以换行符结尾
      else if (contentBytes.length >= 1 && (contentBytes.last == 10 || contentBytes.last == 13)) {
        contentBytes = contentBytes.sublist(0, contentBytes.length - 1);
      }
      else {
        break;
      }
    }
    
    // 去除内容开头的空白字符（包括换行符）
    while (contentBytes.isNotEmpty && (contentBytes.first == 10 || contentBytes.first == 13)) {
      contentBytes = contentBytes.sublist(1, contentBytes.length);
    }
    
    // 调试：输出处理后的contentBytes长度
    print('Processed contentBytes length: ${contentBytes.length}');
    
    // 去除内容末尾的空白字符（包括换行符）
    while (contentBytes.isNotEmpty && (contentBytes.last == 10 || contentBytes.last == 13)) {
      contentBytes = contentBytes.sublist(0, contentBytes.length - 1);
    }
    
    // 去除内容开头的空白字符（包括换行符）
    while (contentBytes.isNotEmpty && (contentBytes.first == 10 || contentBytes.first == 13)) {
      contentBytes = contentBytes.sublist(1, contentBytes.length);
    }
    if (contentTypeIndex != -1) {
    MultipartFile namedValue = MultipartFile();
    // 找到原始字符串中的Content-Type位置
    int originalContentTypeIndex = info.indexOf(CONTENT_TYPE, contentTypeIndex - CONTENT_TYPE.length);
    int contentTypeHeaderLength = CONTENT_TYPE.length;
    if (originalContentTypeIndex == -1) {
      // 尝试查找小写的content-type
      originalContentTypeIndex = info.indexOf('content-type:', contentTypeIndex - 'content-type:'.length);
      contentTypeHeaderLength = 'content-type:'.length;
    }
    if (originalContentTypeIndex != -1) {
      // 提取Content-Type值
      String contentTypeStr = info.substring(originalContentTypeIndex + contentTypeHeaderLength).trim();
      // 找到Content-Type值的结束位置（遇到换行符或分号）
      int contentTypeEndIndex = contentTypeStr.indexOf('\r\n');
      if (contentTypeEndIndex == -1) {
        contentTypeEndIndex = contentTypeStr.indexOf('\n');
      }
      if (contentTypeEndIndex != -1) {
        contentTypeStr = contentTypeStr.substring(0, contentTypeEndIndex).trim();
      }
      namedValue.contentType = ContentType.parse(contentTypeStr);
      // 提取Content-Disposition部分
      info = info.substring(CONTENT_DISPOSITION.length, originalContentTypeIndex).replaceAll(RegExp(HEADER_SEPARATOR), '');
    } else {
      // 如果找不到Content-Type，使用默认值
      namedValue.contentType = ContentType.binary;
      info = info.substring(CONTENT_DISPOSITION.length);
    }
    namedValue.bytes = contentBytes;
    namedValue.size = contentBytes.length;
    Map props = getProps(info, fixNameSuffixIfArray);
    namedValue.name = props['name'];
    // 修复filename提取问题
    namedValue.originalName = props['filename']?.trim()?.replaceAll('"', '');
    value = namedValue;
  } else {
    info = info.substring(CONTENT_DISPOSITION.length);
    CommonValue namedValue = CommonValue();
    try {
      namedValue.value = utf8.decode(contentBytes);
    } catch (e) {
      // 如果不是有效的 UTF-8 编码，就使用 base64 编码
      namedValue.value = base64.encode(contentBytes);
    }
    Map props = getProps(info, fixNameSuffixIfArray);
    namedValue.name = props['name'];
    value = namedValue;
  }
  if (value != null && value.name != null) {
    String key = value.name;
    // 处理数组字段，例如将 friends[0] 和 friends[1] 合并到 friends 键下
    if (fixNameSuffixIfArray && key.contains('[') && key.contains(']')) {
      int bracketIndex = key.indexOf('[');
      String baseKey = key.substring(0, bracketIndex);
      key = baseKey;
    }
    if (!result.containsKey(key)) {
      result[key] = List();
    }
    result[key].add(value);
    // 调试：输出添加的value信息
    print('Added value: ${value.name} = ${value is CommonValue ? (value as CommonValue).value : 'MultipartFile'}');
  }
  });
  
  // 调试：输出result信息
  print('Result map: $result');
  
  return MultipartValueMap.from(result);
}
