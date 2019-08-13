import 'package:Q/src/query/Value.dart';

abstract class CommonValue extends Value {
  String get value;

  set value(String value);

  factory CommonValue({String value, String name}) => _CommonValue(value_: value, name_: name);
}

class _CommonValue implements CommonValue {
  String value_;

  String name_;

  @override
  String get value {
    return this.value_;
  }

  @override
  set value(String value) {
    this.value_ = value;
  }

  @override
  String get name {
    return this.name_;
  }

  @override
  set name(String name) {
    this.name_ = name;
  }

  _CommonValue({this.value_, this.name_});
}
