final String COLLECTION_WTF = 'array';
final String BASE_TYPE_REG = 'string|datetime|timeunit|sizeunit|bool|int|double';
final Pattern TYPE_MATCHER = RegExp('<(((${COLLECTION_WTF})<(${BASE_TYPE_REG})>)|(${BASE_TYPE_REG}))>', caseSensitive: false);
final Pattern DEFAULT_VALUE_MATCHER = RegExp('\\{([a-zA-Z0-9]*)\\}');

class CustomYamlPaserHelper {
  static List<String> parseDefaultValues(value) {
    List<String> defaultValues = List();
    Iterable<Match> defaultValuesMatches = DEFAULT_VALUE_MATCHER.allMatches(value);
    for (Match match in defaultValuesMatches) {
      defaultValues.add(match.group(1));
    }
    return defaultValues;
  }

  static MapEntry<String, String> parseValueTypes(String value) {
    String type;
    String subType;
    Iterable<Match> defaultValuesMatches = TYPE_MATCHER.allMatches(value);
    List<String> list = List();
    for (Match match in defaultValuesMatches) {
      for (int i = 0; i < match.groupCount; i++) {
        list.add(match.group(i));
      }
    }
    if (list.contains(COLLECTION_WTF)) {
      type = COLLECTION_WTF;
      subType = list[4];
    } else {
      type = list[1];
    }
    return MapEntry(type, subType);
  }
}
