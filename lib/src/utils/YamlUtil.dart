import 'package:yaml/yaml.dart';

class YamlUtil {
  static Map convertDocumentToMap(YamlDocument document) {
    if (document == null) return null;
    YamlMap node = document.contents.value;
    return Map.from(node);
  }
}
