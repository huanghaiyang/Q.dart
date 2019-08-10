class QueryHelper {
  static Map fixData(Map data) {
    List<String> keys = List.from(data.keys);
    for (String key in keys) {
      data[fixQueryKey(key)] = data[key];
    }
    return data;
  }

  static String fixQueryKey(String key) {
    if (key.endsWith('[]')) {
      key = key.substring(0, key.length - 2);
    }
    return key;
  }
}
