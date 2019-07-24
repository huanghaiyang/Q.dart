import 'package:Q/src/Attribute.dart';
import 'package:Q/src/Method.dart';

abstract class Redirect {
  String get path;

  String get method;

  Map<String, Attribute> get attributes;

  factory Redirect(String path, String method, [List<Attribute> attributes]) => _Redirect(path, method, attributes);
}

class _Redirect implements Redirect {
  String path_;

  List<Attribute> attributes_ = List();

  String method_ = GET;

  _Redirect(this.path_, this.method_, this.attributes_);

  @override
  String get path {
    return this.path_;
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
}
