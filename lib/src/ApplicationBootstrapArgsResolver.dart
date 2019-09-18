import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationBootstrapArgsResolverAware.dart';
import 'package:Q/src/command/ApplicationConfigurationTree.dart';
import 'package:args/args.dart';

class ApplicationBootstrapArgsResolver
    implements ApplicationBootstrapArgsResolverAware<ArgResults, ApplicationConfigurationTree, ArgParser> {
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
    argParser = await this.define(ApplicationConfigurationTree.instance());
    argResults = argParser.parse(Application.instance().arguments);
    return argResults;
  }

  @override
  Future<ArgParser> define(ApplicationConfigurationTree commandStructure) {}
}
