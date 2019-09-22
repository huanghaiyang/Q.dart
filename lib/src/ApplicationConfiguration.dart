abstract class ApplicationConfiguration {
  factory ApplicationConfiguration(Map<String, dynamic> values, int priority) => _ApplicationConfiguration(values, priority);

  Map<String, dynamic> get values;

  int get priority;
}

class _ApplicationConfiguration implements ApplicationConfiguration {
  final Map<String, dynamic> values_;

  final int priority_;

  _ApplicationConfiguration(this.values_, this.priority_);

  @override
  Map<String, dynamic> get values {
    return Map.unmodifiable(values_);
  }

  @override
  int get priority {
    return priority_;
  }
}
