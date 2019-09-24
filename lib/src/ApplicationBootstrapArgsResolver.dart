import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationBootstrapArgsResolverAware.dart';
import 'package:Q/src/command/ApplicationConfigurationMapper.dart';
import 'package:args/args.dart';

class ApplicationBootstrapArgsResolver
    implements ApplicationBootstrapArgsResolverAware<ArgParser, ApplicationConfigurationMapper, ArgResults> {
  ApplicationBootstrapArgsResolver._();

  static ApplicationBootstrapArgsResolver _instance;

  static ApplicationBootstrapArgsResolver instance() {
    if (_instance == null) {
      _instance = ApplicationBootstrapArgsResolver._();
    }
    return _instance;
  }

  ArgParser _parser;

  ArgResults _parsedResult;

  Map<String, dynamic> _transformedResult = Map();

  Map<String, String> keyMap = Map();

  Set<String> keys = Set();

  @override
  Future<dynamic> resolve() async {
    _parser = ArgParser();
    _parser = await this.define(_parser, ApplicationConfigurationMapper.instance());
    _parsedResult = _parser.parse(Application.instance().parsedArguments);

    for (var key in keys) {
      _transformedResult[keyMap[key]] = _parsedResult[key];
    }
    return transformedResult;
  }

  @override
  Future<ArgParser> define(ArgParser argParser, ApplicationConfigurationMapper configurationMapper) async {
    Map<String, dynamic> map = configurationMapper.value();
    for (MapEntry entry in map.entries) {
      String originalKey = entry.key;
      String key = ApplicationConfigurationMapper.getKey(originalKey);
      keyMap[key] = originalKey;
      keys.add(key);
      argParser.addOption(key, defaultsTo: entry.value.toString());
    }
    return Future.value(argParser);
  }

  @override
  Future<dynamic> get(String key) async {
    return Future.value(transformedResult[key]);
  }

  @override
  Map<String, dynamic> get transformedResult {
    return Map.unmodifiable(_transformedResult);
  }

  @override
  ArgResults get parsedResult {
    return _parsedResult;
  }
}
