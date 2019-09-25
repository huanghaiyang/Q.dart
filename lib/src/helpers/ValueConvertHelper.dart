class ValueConvertHelper {
  static String convertValueToString(dynamic value) {
    if (value is List || value is Set) {
      return value.join(',');
    }
    return value.toString();
  }
}
