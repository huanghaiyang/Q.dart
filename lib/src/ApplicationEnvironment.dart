abstract class ApplicationEnvironment {
  String get value;

  factory ApplicationEnvironment(String value) => _ApplicationEnvironment(value);
}

class _ApplicationEnvironment implements ApplicationEnvironment {
  final String value_;

  _ApplicationEnvironment(this.value_);

  @override
  String get value {
    return this.value_;
  }
}
