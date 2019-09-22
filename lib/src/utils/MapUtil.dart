class MapUtil {
  static Map<String, dynamic> flatten(Map map, Map<String, dynamic> result, {String pathPath}) {
    for (MapEntry entry in map.entries) {
      String key = entry.key;
      dynamic value = entry.value;
      String path = pathPath != null ? '${pathPath}.${key}' : key;
      if (value is Map) {
        flatten(value, result, pathPath: path);
      } else {
        result[path] = value;
      }
    }
    return result;
  }
}
