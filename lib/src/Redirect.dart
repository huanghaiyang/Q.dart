import 'package:Q/src/Attribute.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/aware/HttpMethodAware.dart';
import 'package:Q/src/helpers/HttpMethodHelper.dart';
import 'package:Q/src/helpers/RedirectHelper.dart';

// 重定向
abstract class Redirect extends HttpMethodAware<HttpMethod> {
  String get address;

  Map<String, Attribute> get attributes;

  factory Redirect(String address, HttpMethod method, {Map<String, String> attributes, Map pathVariables}) =>
      _Redirect(address, method, attributeMap: attributes, pathVariables_: pathVariables);

  String get path;

  String get name;

  bool get isName;

  bool get isPath;

  Map get pathVariables;
}

class _Redirect implements Redirect {
  String address_;

  List<Attribute> attributes_ = List();

  HttpMethod method_ = HttpMethod.GET;

  Map pathVariables_;

  _Redirect(this.address_, this.method_, {Map<String, String> attributeMap, this.pathVariables_}) {
    if (attributeMap != null) {
      attributeMap.forEach((name, value) {
        this.attributes_.add(Attribute(name, value));
      });
    }
    if (this.pathVariables_ == null) {
      this.pathVariables_ = Map();
    }
  }

  @override
  String get address {
    return this.address_;
  }

  @override
  HttpMethod get method {
    return this.method_;
  }

  @override
  String get methodName {
    return HttpMethodHelper.getMethodName(this.method);
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
    if (this.isName) return address.replaceFirst(NAME_PATTERN, '');
    return null;
  }

  @override
  String get path {
    if (isPath) return address.replaceFirst(PATH_PATTERN, '');
    return null;
  }

  @override
  bool get isName {
    return address.startsWith(NAME_PATTERN);
  }

  @override
  bool get isPath {
    return address.startsWith(PATH_PATTERN);
  }

  @override
  Map get pathVariables {
    return this.pathVariables_;
  }
}
