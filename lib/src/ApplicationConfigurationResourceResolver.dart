import 'package:Q/src/ApplicationConfigurationResourceFinder.dart';
import 'package:Q/src/ApplicationEnvironment.dart';
import 'package:Q/src/aware/ApplicationConfigurationResourceResolverAware.dart';
import 'package:Q/src/common/ResourceFileTypeHelper.dart';
import 'package:Q/src/resource/ApplicationConfigurationResource.dart';

const int DEFAULT_PRIORITY = 5;
const int DEFAULT_PRIORITY_STEP = 5;

class ApplicationConfigurationResourceResolver
    implements ApplicationConfigurationResourceResolverAware<ApplicationEnvironment, List<ApplicationConfigurationResource>> {
  ApplicationConfigurationResourceResolver._();

  static ApplicationConfigurationResourceResolver _instance;

  static ApplicationConfigurationResourceResolver instance() {
    return _instance ?? (_instance = ApplicationConfigurationResourceResolver._());
  }

  final ApplicationConfigurationResourceFinder applicationConfigurationResourceFinder = ApplicationConfigurationResourceFinder();

  @override
  Future<List<ApplicationConfigurationResource>> resolve(ApplicationEnvironment environment) async {
    if (environment == null) {
      return [];
    }
    try {
      Map<String, String> paths = await applicationConfigurationResourceFinder.search(ResourceFileTypes.YML, environment);
      if (paths == null || paths.isEmpty) {
        return [];
      }
      List<ApplicationConfigurationResource> resources = List();
      for (String key in paths.keys) {
        if (key == null || paths[key] == null) {
          continue;
        }
        int priority;
        if (key == APPLICATION_CONFIGURATION_RESOURCE_PREFIX) {
          priority = DEFAULT_PRIORITY;
        } else {
          priority = DEFAULT_PRIORITY + DEFAULT_PRIORITY_STEP;
        }
        try {
          ApplicationConfigurationResource resource = ApplicationConfigurationResource.fromPath(paths[key], priority: priority);
          if (resource != null) {
            resources.add(resource);
          }
        } catch (e) {
          print('Error creating configuration resource for ${paths[key]}: $e');
          continue;
        }
      }
      return resources;
    } catch (e) {
      print('Error resolving configuration resources: $e');
      return [];
    }
  }
}
