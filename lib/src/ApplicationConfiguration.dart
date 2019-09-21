abstract class ApplicationConfiguration {
  factory ApplicationConfiguration(Map<String, dynamic> values) => _ApplicationConfiguration(values);

  Map<String, dynamic> get values;
}

class _ApplicationConfiguration implements ApplicationConfiguration {
  final Map<String, dynamic> values_;

  _ApplicationConfiguration(this.values_);

  @override
  Map<String, dynamic> get values {
    return Map.unmodifiable(values_);
  }
}
