import 'package:Q/src/ApplicationConfiguration.dart';

abstract class AbstractConfigure {
  Future<dynamic> init(ApplicationConfiguration applicationConfiguration);
}
