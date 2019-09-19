import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationBootstrapArgsResolverAware.dart';
import 'package:Q/src/command/ApplicationConfigurationMapper.dart';
import 'package:args/args.dart';

class ApplicationBootstrapArgsResolver implements ApplicationBootstrapArgsResolverAware<ArgParser, ApplicationConfigurationMapper> {
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
  Future<dynamic> resolve() async {
    _parser = ArgParser();
    _parser = await this.define(_parser, ApplicationConfigurationMapper.instance());
    _parsedResult = _parser.parse(Application.instance().parsedArguments);
  }

  @override
  Future<ArgParser> define(ArgParser argParser, ApplicationConfigurationMapper configurationMapper) async {
    Map<String, dynamic> map = configurationMapper.value();
    for (MapEntry entry in map.entries) {
      String key = ApplicationConfigurationMapper.getKey(entry.key);
      argParser.addOption(key);
    }
    return Future.value(argParser);
  }

  @override
  Future<dynamic> get(String key) async {
    return Future.value(_parsedResult[ApplicationConfigurationMapper.getKey(key)]);
  }
}
