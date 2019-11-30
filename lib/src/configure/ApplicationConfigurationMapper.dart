import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/ApplicationConfiguration.dart';
import 'package:Q/src/aware/ApplicationConfigurationMapperAware.dart';
import 'package:Q/src/configure/CustomYamlNode.dart';
import 'package:Q/src/configure/CustomYamlParser.dart';
import 'package:Q/src/configure/CustomYamlParserHelper.dart';
import 'package:Q/src/configure/rules/ApplicationConfigureIfYamlNotExist.dart';

final String _DEFAULT_CONFIGURATION_FILE_NAME = 'configure.yml';

class ApplicationConfigurationMapper
    implements ApplicationConfigurationMapperAware<List<CustomYamlNode>, Map<String, dynamic>, ApplicationConfiguration, CustomYamlNode> {
  static String DOT_STAND_IN_CHAR = '_';

  static String generateKey(String key) {
    return key.replaceAll(RegExp("\\."), ApplicationConfigurationMapper.DOT_STAND_IN_CHAR);
  }

  static dynamic get(String key) {
    return ApplicationConfigurationMapper.instance().values[key];
  }

  static dynamic as(String key, String value) {
    return ApplicationConfigurationMapper.instance().convertAs(key, value).value;
  }

  ApplicationConfigurationMapper._();

  static ApplicationConfigurationMapper _instance;

  static ApplicationConfigurationMapper instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationMapper._();
    }
    return _instance;
  }

  List<CustomYamlNode> nodes_ = List();

  bool _isParsed = false;

  Map<String, dynamic> values_ = Map();

  @override
  Future<ApplicationConfiguration> init() async {
    /**
     * Q.dart作为lib使用时是访问不到lib/resources下的文件的，因为lib不允许包含任何静态文件
     */
    File file = File('${Directory.current.path}/lib/resources/${_DEFAULT_CONFIGURATION_FILE_NAME}');
    if (await file.exists()) {
      CustomYamlParser yamlParser = CustomYamlParser(await file.readAsString());
      nodes_ = await yamlParser.parse();
    } else {
      nodes_ = await CustomYamlParserHelper.parseMap(MapUtil.flatten(ApplicationConfigureIfYamlNotExist.rule, {}));
    }
    nodes_.forEach((node) {
      dynamic reflectValue = CustomYamlParserHelper.reflectNodeValue(node);
      values_[node.name] = reflectValue;
      node.value = reflectValue;
    });
    _isParsed = true;
    return ApplicationConfiguration(values_, 0);
  }

  @override
  List<CustomYamlNode> get nodes {
    return List.unmodifiable(nodes_);
  }

  @override
  Map<String, dynamic> get values {
    return Map.unmodifiable(values_);
  }

  @override
  bool get isParsed {
    return _isParsed;
  }

  @override
  CustomYamlNode convertAs(String key, String value) {
    Iterable<CustomYamlNode> iterable = nodes.where((node) {
      return node.name == key;
    });
    if (iterable.isNotEmpty) {
      CustomYamlNode defaultNode = iterable.first;
      if (defaultNode != null) {
        List<String> values = CustomYamlParserHelper.parseDefaultValues(value);
        CustomYamlNode node = CustomYamlNode(defaultNode.name, defaultNode.type, values, subType: defaultNode.subType);
        node.value = CustomYamlParserHelper.reflectNodeValue(node);
        return node;
      }
    }
    return CustomYamlNode(key, 'string', [value], value: value);
  }
}
