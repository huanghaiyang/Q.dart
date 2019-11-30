import 'package:Q/src/configure/CustomYamlNode.dart';
import 'package:Q/src/configure/CustomYamlParserHelper.dart';
import 'package:Q/src/utils/MapUtil.dart';
import 'package:Q/src/utils/YamlUtil.dart';
import 'package:yaml/yaml.dart';

abstract class CustomYamlParser {
  Future<List<CustomYamlNode>> parse();

  Future<List<CustomYamlNode>> get nodes;

  String get yaml;

  factory CustomYamlParser(String document) => _CustomYamlParser(document);
}

class _CustomYamlParser implements CustomYamlParser {
  final String yaml_;

  Future<List<CustomYamlNode>> nodes_;

  _CustomYamlParser(this.yaml_);

  @override
  Future<List<CustomYamlNode>> parse() async {
    Map<String, dynamic> map = Map();
    MapUtil.flatten(YamlUtil.convertDocumentToMap(loadYamlDocument(yaml_)), map);
    return CustomYamlParserHelper.parseMap(map);
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
