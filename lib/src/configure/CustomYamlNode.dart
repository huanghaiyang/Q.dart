import 'package:Q/src/exception/IllegalArgumentException.dart';

abstract class CustomYamlNode {
  String get name;

  String get type;

  String get subType;

  List<String> get defaultValues;

  dynamic get value;

  set value(dynamic value);

  factory CustomYamlNode(String name, String type, List<String> defaultValues, {String subType}) =>
      _CustomYamlNode(name, type, defaultValues, subType_: subType);
}

class _CustomYamlNode implements CustomYamlNode {
  final String name_;

  final String type_;

  final String subType_;

  final List<String> defaultValues_;

  dynamic value_;

  _CustomYamlNode(this.name_, this.type_, this.defaultValues_, {this.subType_}) {
    if (this.name_ == null) {
      throw IllegalArgumentException(message: 'CustomYamlNode property [name] must not be null.');
    }
    if (this.type_ == null) {
      throw IllegalArgumentException(message: 'CustomYamlNode property [type] must not be null.');
    }
  }

  @override
  String get name {
    return name_;
  }

  @override
  List<String> get defaultValues {
    return defaultValues_;
  }

  @override
  String get subType {
    return subType_;
  }

  @override
  String get type {
    return type_;
  }

  @override
  dynamic get value {
    return value_;
  }

  @override
  set value(dynamic value) {
    value_ = value;
  }
}
