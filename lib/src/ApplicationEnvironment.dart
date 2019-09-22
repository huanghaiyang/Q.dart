abstract class ApplicationEnvironment {
  String get value;

  bool get isDefault;

  factory ApplicationEnvironment(String value, bool isDefault) => _ApplicationEnvironment(value, isDefault);
}

class _ApplicationEnvironment implements ApplicationEnvironment {
  final String value_;

  final bool isDefault_;

  _ApplicationEnvironment(this.value_, this.isDefault_);

  @override
  String get value {
    return this.value_;
  }

  @override
  bool get isDefault {
    return isDefault_;
  }
}
