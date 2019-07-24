import 'package:Q/src/Attribute.dart';

abstract class Redirect {
  String get path;

  Map<String, Attribute> get attributes;

  factory Redirect(String path, [Map<String, Attribute> attributes]) => _Redirect(path, attributes);
}

class _Redirect implements Redirect {
  String path_;

  Map<String, Attribute> attributes_ = Map();

  _Redirect(this.path_, this.attributes_);

  @override
  String get path {
    return this.path_;
  }

  @override
  Map<String, Attribute> get attributes {
    return this.attributes_;
  }
}
