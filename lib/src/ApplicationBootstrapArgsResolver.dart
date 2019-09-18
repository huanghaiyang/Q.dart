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

  ArgParser argParser;

  ArgResults argResults;

  @override
  Future<ArgResults> resolve() async {
    argParser = ArgParser();
    argParser = await this.define(argParser, ApplicationConfigurationMapper.instance());
    argResults = argParser.parse(Application.instance().arguments);
    return argResults;
  }

  @override
  Future<ArgParser> define(ArgParser argParser, ApplicationConfigurationMapper commandStructure) async {
    Map<String, dynamic> map = commandStructure.value();
    for (MapEntry entry in map.entries) {
      String key = entry.key;
      argParser.addOption(key);
    }
    return argParser;
  }
}
