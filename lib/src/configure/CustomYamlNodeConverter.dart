import 'package:Q/src/configure/CustomYamlNodeValueType.dart';

class CustomYamlNodeConverter {
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
    }
  }
}
