/**
 * YAML节点类型转换器，用于在字符串类型名和CustomYamlNodeValueType枚举之间进行转换
 */
import 'package:Q/src/configure/CustomYamlNodeValueType.dart';

class CustomYamlNodeConverter {
  /**
   * 将字符串类型名转换为CustomYamlNodeValueType枚举
   * 
   * @param type 字符串类型名
   * @return 对应的CustomYamlNodeValueType枚举值
   */
  static CustomYamlNodeValueType toType(String type) {
    switch (type) {
      case 'bool':
        return CustomYamlNodeValueType.BOOLEAN;
      case 'int':
        return CustomYamlNodeValueType.INT;
      case 'double':
        return CustomYamlNodeValueType.DOUBLE;
      case 'array':
        return CustomYamlNodeValueType.ARRAY;
      case 'string':
        return CustomYamlNodeValueType.STRING;
      case 'timeunit':
        return CustomYamlNodeValueType.TIMEUNIT;
      case 'sizeunit':
        return CustomYamlNodeValueType.SIZEUNIT;
      case 'datetime':
        return CustomYamlNodeValueType.DATETIME;
      case 'map':
        return CustomYamlNodeValueType.MAP;
    }
  }
  
  /**
   * 将CustomYamlNodeValueType枚举转换为字符串类型名
   * 
   * @param type CustomYamlNodeValueType枚举值
   * @return 对应的字符串类型名
   */
  static String fromType(CustomYamlNodeValueType type) {
    switch (type) {
      case CustomYamlNodeValueType.BOOLEAN:
        return 'bool';
      case CustomYamlNodeValueType.INT:
        return 'int';
      case CustomYamlNodeValueType.DOUBLE:
        return 'double';
      case CustomYamlNodeValueType.ARRAY:
        return 'array';
      case CustomYamlNodeValueType.STRING:
        return 'string';
      case CustomYamlNodeValueType.TIMEUNIT:
        return 'timeunit';
      case CustomYamlNodeValueType.SIZEUNIT:
        return 'sizeunit';
      case CustomYamlNodeValueType.DATETIME:
        return 'datetime';
      case CustomYamlNodeValueType.MAP:
        return 'map';
    }
  }
}
