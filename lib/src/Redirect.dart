import 'package:Q/src/Attribute.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/helpers/RedirectHelper.dart';

// 重定向
abstract class Redirect {
  String get address;

  String get method;

  Map<String, Attribute> get attributes;

  factory Redirect(String address, String method, {List<Attribute> attributes}) => _Redirect(address, method, attributes_: attributes);

  String get path;

  String get name;
}

class _Redirect implements Redirect {
  String address_;

  List<Attribute> attributes_ = List();

  String method_ = GET;

  _Redirect(this.address_, this.method_, {this.attributes_});

  @override
  String get address {
    return this.address_;
  }

  @override
  String get method {
    return this.method_;
  }

  @override
  Map<String, Attribute> get attributes {
    Map<String, Attribute> attributes = Map();
    this.attributes_.forEach((attribute) {
      attributes[attribute.name] = attribute;
    });
    return attributes;
  }

  @override
  String get name {
    if (address.startsWith(NAME_PATTERN)) return address.replaceFirst(NAME_PATTERN, '');
    return null;
  }

  @override
  String get path {
    if (address.startsWith(PATH_PATTERN)) return address.replaceFirst(PATH_PATTERN, '');
    return null;
  }
}
