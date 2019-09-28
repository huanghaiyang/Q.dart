import 'package:Q/src/configure/CustomYamlNode.dart';
import 'package:Q/src/helpers/CustomYamlPaserHelper.dart';
import 'package:Q/src/utils/MapUtil.dart';
import 'package:Q/src/utils/YamlUtil.dart';
import 'package:yaml/yaml.dart';

abstract class CustomYamlPaser {
  Future<List<CustomYamlNode>> parse();

  Future<List<CustomYamlNode>> get nodes;

  String get yaml;

  factory CustomYamlPaser(String document) => _CustomYamlPaser(document);
}

class _CustomYamlPaser implements CustomYamlPaser {
  final String yaml_;

  Future<List<CustomYamlNode>> nodes_;

  _CustomYamlPaser(this.yaml_);

  @override
  Future<List<CustomYamlNode>> parse() async {
    List<CustomYamlNode> result = List();
    Map<String, dynamic> map = Map();
    MapUtil.flatten(YamlUtil.convertDocumentToMap(loadYamlDocument(yaml_)), map);
    for (MapEntry entry in map.entries) {
      String name = entry.key;
      List<String> defaultValues = CustomYamlPaserHelper.parseDefaultValues(entry.value);
      MapEntry<String, String> typeEntry = CustomYamlPaserHelper.parseValueTypes(entry.value);
      result.add(CustomYamlNode(name, typeEntry.key, defaultValues, subType: typeEntry.value));
    }
    return Future.value(result);
  }

  @override
  Future<List<CustomYamlNode>> get nodes {
    return nodes_;
  }

  @override
  String get yaml {
    return yaml_;
  }
}
