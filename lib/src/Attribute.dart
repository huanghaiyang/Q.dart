import 'package:Q/src/Router.dart';

abstract class Attribute {
  factory Attribute(String name, dynamic value, [Router router]) => _Attribute(name, value, router);

  String get name;

  dynamic get value;

  Router get router;
}

class _Attribute implements Attribute {
  final String name_;
  final dynamic value_;
  final Router router_;

  _Attribute(this.name_, this.value_, [this.router_]);

  @override
  Router get router {
    return this.router_;
  }

  @override
  dynamic get value {
    return this.value_;
  }

  @override
  String get name {
    return this.name_;
  }
}
