abstract class CustomYamlNode {
  String get name;

  String get type;

  String get subType;

  List<String> get defaultValues;

  factory CustomYamlNode(String name, String type, List<String> defaultValues, {String subType}) =>
      _CustomYamlNode(name, type, defaultValues, subType_: subType);
}

class _CustomYamlNode implements CustomYamlNode {
  final String name_;

  final String type_;

  final String subType_;

  final List<String> defaultValues_;

  _CustomYamlNode(this.name_, this.type_, this.defaultValues_, {this.subType_});

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
}
