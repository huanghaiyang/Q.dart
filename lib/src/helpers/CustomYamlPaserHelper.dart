import 'package:Q/src/common/SizeUnit.dart';
import 'package:Q/src/common/TimeUnit.dart';
import 'package:Q/src/configure/CustomYamlNode.dart';
import 'package:Q/src/configure/CustomYamlNodeConverter.dart';
import 'package:Q/src/configure/CustomYamlNodeValueType.dart';

final String COLLECTION_WTF = 'array';
final String BASE_TYPE_REG = 'string|datetime|timeunit|sizeunit|bool|int|double';
final Pattern TYPE_MATCHER = RegExp('<(((${COLLECTION_WTF})<(${BASE_TYPE_REG})>)|(${BASE_TYPE_REG}))>', caseSensitive: false);

class CustomYamlPaserHelper {
  static List<String> parseDefaultValues(String value) {
    List<String> defaultValues = List();
    int index = value.indexOf(RegExp('<'));
    String valueStr = value.substring(0, index);
    valueStr.trim().split(RegExp(',')).forEach((str) {
      defaultValues.add(str.trim());
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

  static Map<String, dynamic> convertNodesToMap(List<CustomYamlNode> nodes) {
    Map<String, dynamic> result = Map();
    nodes.forEach((CustomYamlNode node) {
      CustomYamlNodeValueType type = CustomYamlNodeConverter.toType(node.type);
      CustomYamlNodeValueType subType = CustomYamlNodeConverter.toType(node.subType);
      result[node.name] = convertStringListTo(node.defaultValues, type, subType);
    });
    return result;
  }

  static dynamic convertStringListTo(List<String> values, CustomYamlNodeValueType type, CustomYamlNodeValueType subType) {
    if (type != CustomYamlNodeValueType.ARRAY) {
      return convertStringTo(values.first, type);
    } else {
      return values.map((value) {
        return convertStringTo(value, subType);
      });
    }
  }

  static dynamic convertStringTo(String value, CustomYamlNodeValueType type) {
    if (value == null) return null;
    if(value.isEmpty) return value;
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
}
