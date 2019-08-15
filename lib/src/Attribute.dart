// 用户当前请求上下文中的数据传递
abstract class Attribute {
  factory Attribute(String name, dynamic value) => _Attribute(name, value);

  String get name;

  dynamic get value;
}

class _Attribute implements Attribute {
  final String name_;
  final dynamic value_;

  _Attribute(this.name_, this.value_);

  @override
  dynamic get value {
    return this.value_;
  }

  @override
  String get name {
    return this.name_;
  }
}
