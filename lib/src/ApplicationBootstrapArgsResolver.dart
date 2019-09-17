import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationBootstrapArgsResolverAware.dart';
import 'package:Q/src/command/ApplicationCommand.dart';
import 'package:args/args.dart';

class ApplicationBootstrapArgsResolver implements ApplicationBootstrapArgsResolverAware<ApplicationCommand> {
  ApplicationBootstrapArgsResolver._();

  static ApplicationBootstrapArgsResolver _instance;

  static ApplicationBootstrapArgsResolver getInstance() {
    if (_instance == null) {
      _instance = ApplicationBootstrapArgsResolver._();
    }
    return _instance;
  }

  ArgParser argParser;
  ArgResults argResults;

  @override
  Future<ApplicationCommand> resolve() async {
    argParser = ArgParser();
    argResults = argParser.parse(Application.instance().arguments);
  }
}
