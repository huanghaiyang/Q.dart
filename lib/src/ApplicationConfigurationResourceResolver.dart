import 'package:Q/src/ApplicationConfigurationResourceFinder.dart';
import 'package:Q/src/ApplicationEnvironment.dart';
import 'package:Q/src/aware/ApplicationConfigurationResourceResolverAware.dart';
import 'package:Q/src/common/ResourceFileTypes.dart';
import 'package:Q/src/resource/ApplicationConfigurationResource.dart';

const int DEFAULT_PRIORITY = 5;
const int DEFAULT_PRIORITY_STEP = 5;

class ApplicationConfigurationResourceResolver
    implements ApplicationConfigurationResourceResolverAware<ApplicationEnvironment, List<ApplicationConfigurationResource>> {
  ApplicationConfigurationResourceResolver._();

  static ApplicationConfigurationResourceResolver _instance;

  static ApplicationConfigurationResourceResolver instance() {
    if (_instance == null) {
      _instance = ApplicationConfigurationResourceResolver._();
    }
    return _instance;
  }

  final ApplicationConfigurationResourceFinder applicationConfigurationResourceFinder = ApplicationConfigurationResourceFinder();

  @override
  Future<List<ApplicationConfigurationResource>> resolve(ApplicationEnvironment environment) async {
    Map<String, String> paths = await applicationConfigurationResourceFinder.search(ResourceFileTypes.YML, environment);
    List<ApplicationConfigurationResource> resources = List();
    for (String key in paths.keys) {
      int priority;
      if (key == APPLICATION_CONFIGURATION_RESOURCE_PREFIX) {
        priority = DEFAULT_PRIORITY;
      } else {
        priority = DEFAULT_PRIORITY + DEFAULT_PRIORITY_STEP;
      }
      resources.add(ApplicationConfigurationResource.fromPath(paths[key], priority: priority));
    }
    return resources;
  }
}
