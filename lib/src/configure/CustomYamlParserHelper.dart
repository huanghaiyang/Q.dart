import 'dart:io';

import 'package:Q/src/common/SizeUnit.dart';
import 'package:Q/src/common/TimeUnit.dart';
import 'package:Q/src/configure/ApplicationContextVariableNames.dart';
import 'package:Q/src/configure/CustomYamlNode.dart';
import 'package:Q/src/configure/CustomYamlNodeConverter.dart';
import 'package:Q/src/configure/CustomYamlNodeValueType.dart';

final String COLLECTION_WTF = 'array';
final String BASE_TYPE_REG = 'string|datetime|timeunit|sizeunit|bool|int|double';
final Pattern TYPE_MATCHER = RegExp('<(((${COLLECTION_WTF})<(${BASE_TYPE_REG})>)|(${BASE_TYPE_REG}))>', caseSensitive: false);
final Pattern GLOBAL_CONFIGURATION_VARIABLE_MATCHER = RegExp('\\\~');

class CustomYamlParserHelper {
  static List<String> parseDefaultValues(String value) {
    value = value.trim();
    List<String> defaultValues = List();
    int index = value.indexOf(RegExp('<'));
    if (index >= 0) {
      value = value.substring(0, index);
    }
    value.trim().split(RegExp(',')).forEach((str) {
      String val = str.trim();
      if (val.isNotEmpty) {
        if (val.startsWith(GLOBAL_CONFIGURATION_VARIABLE_MATCHER)) {
          val = convertToVariable(val.replaceFirst(GLOBAL_CONFIGURATION_VARIABLE_MATCHER, ''));
        }
        defaultValues.add(val);
      }
    });
    return defaultValues;
  }

  static MapEntry<String, String> parseValueTypes(String value) {
    String type;
    String subType;
    Iterable<Match> defaultValuesMatches = TYPE_MATCHER.allMatches(value);
    List<String> list = List();
    for (Match match in defaultValuesMatches) {
      for (int i = 0; i < match.groupCount; i++) {
        list.add(match.group(i));
      }
    }
    if (list.contains(COLLECTION_WTF)) {
      type = COLLECTION_WTF;
      subType = list[4];
    } else {
      type = list[1];
    }
    return MapEntry(type, subType);
  }

  static dynamic reflectNodeValue(CustomYamlNode node) {
    CustomYamlNodeValueType type = CustomYamlNodeConverter.toType(node.type);
    CustomYamlNodeValueType subType = CustomYamlNodeConverter.toType(node.subType);
    dynamic value = convertStringListTo(node.defaultValues, type, subType);
    return value;
  }

  static dynamic convertStringListTo(List<String> values, CustomYamlNodeValueType type, CustomYamlNodeValueType subType) {
    if (type != CustomYamlNodeValueType.ARRAY) {
      if (values.isEmpty) return null;
      return convertStringTo(values.first, type);
    } else {
      return List.from(values.where((value) {
        return value.trim().isNotEmpty;
      }).map((value) {
        return convertStringTo(value, subType);
      }));
    }
  }

  static dynamic convertStringTo(String value, CustomYamlNodeValueType type) {
    if (value == null) return null;
    if (value.isEmpty) return value;
    switch (type) {
      case CustomYamlNodeValueType.BOOLEAN:
        return value == 'true' ? true : false;
      case CustomYamlNodeValueType.DATETIME:
        return DateTime.parse(value);
      case CustomYamlNodeValueType.STRING:
        return value;
      case CustomYamlNodeValueType.DOUBLE:
        return double.parse(value);
      case CustomYamlNodeValueType.INT:
        return int.parse(value);
      case CustomYamlNodeValueType.SIZEUNIT:
        return SizeUnit.parse(value);
      case CustomYamlNodeValueType.TIMEUNIT:
        return TimeUnit.parse(value);
      case CustomYamlNodeValueType.ARRAY:
        return null;
    }
  }

  static String convertToVariable(String value) {
    switch (value) {
      case ApplicationContextVariableNames.SYSTEM_TEMP_DIR_PATH:
        return Directory.systemTemp.path;
    }
    return value;
  }

  static Future<List<CustomYamlNode>> parseMap(Map map) {
    List<CustomYamlNode> result = List();
    for (MapEntry entry in map.entries) {
      String name = entry.key;
      List<String> defaultValues = CustomYamlParserHelper.parseDefaultValues(entry.value);
      MapEntry<String, String> typeEntry = CustomYamlParserHelper.parseValueTypes(entry.value);
      result.add(CustomYamlNode(name, typeEntry.key, defaultValues, subType: typeEntry.value));
    }
    return Future.value(result);
  }
}
