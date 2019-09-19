import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationBootstrapArgsResolverAware.dart';
import 'package:Q/src/command/ApplicationConfigurationMapper.dart';
import 'package:args/args.dart';

class ApplicationBootstrapArgsResolver
    implements ApplicationBootstrapArgsResolverAware<ArgResults, ApplicationConfigurationMapper, ArgParser> {
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

  @override
  Future<ArgResults> resolve() async {
    _parser = ArgParser();
    _parser = await this.define(_parser, ApplicationConfigurationMapper.instance());
    _parsedResult = _parser.parse(Application.instance().parsedArguments);
    return _parsedResult;
  }

  @override
  Future<ArgParser> define(ArgParser _parser, ApplicationConfigurationMapper commandStructure) async {
    Map<String, dynamic> map = commandStructure.value();
    for (MapEntry entry in map.entries) {
      String key = ApplicationConfigurationMapper.getKey(entry.key);
      _parser.addOption(key);
    }
    return _parser;
  }

  @override
  Future<dynamic> get(String key) async {
    return await _parsedResult[ApplicationConfigurationMapper.getKey(key)];
  }
}
