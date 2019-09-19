import 'package:Q/src/Application.dart';
import 'package:Q/src/aware/ApplicationArgumentsParsedAware.dart';
import 'package:Q/src/command/ApplicationConfigurationMapper.dart';
import 'package:Q/src/delegate/AbstractDelegate.dart';

final String EQUAL_TOKEN = '=';

abstract class ApplicationArgumentsParsedDelegate extends AbstractDelegate
    with ApplicationArgumentsParsedAware<List<String>, List<String>> {
  factory ApplicationArgumentsParsedDelegate(Application application) => _ApplicationArgumentsParsedDelegate(application);

  factory ApplicationArgumentsParsedDelegate.from(Application application) {
    return application.getDelegate(ApplicationArgumentsParsedDelegate);
  }
}

class _ApplicationArgumentsParsedDelegate implements ApplicationArgumentsParsedDelegate {
  final Application application;

  _ApplicationArgumentsParsedDelegate(this.application);

  List<String> _arguments;

  List<String> _parsedArguments;

  @override
  void args(List<String> arguments) {
    this._arguments = arguments;
    this._parsedArguments = this._parse(arguments);
  }

  @override
  List<String> get arguments => List.unmodifiable(_arguments);

  @override
  List<String> get parsedArguments => List.unmodifiable(_parsedArguments);

  List<String> _parse(List<String> arguments) {
    return List<String>.from(arguments.map((arg) {
      List<String> pair = arg.split(RegExp(EQUAL_TOKEN));
      if (pair.isNotEmpty) {
        String key = pair.first;
        String value = pair.length > 1 ? pair.last : null;
        key = ApplicationConfigurationMapper.getKey(key);
        if (value != null) {
          return '${key}${EQUAL_TOKEN}${value}';
        } else {
          return key;
        }
      }
      return arg;
    }));
  }
}
