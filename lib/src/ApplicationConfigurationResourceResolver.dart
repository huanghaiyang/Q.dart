import 'package:Q/src/ApplicationConfigurationResourceFinder.dart';
import 'package:Q/src/aware/ApplicationConfigurationResourceResolverAware.dart';
import 'package:Q/src/common/ResourceFileTypes.dart';
import 'package:Q/src/resource/ApplicationConfigurationResource.dart';

class ApplicationConfigurationResourceResolver
    implements ApplicationConfigurationResourceResolverAware<List<ApplicationConfigurationResource>> {
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
  Future<List<ApplicationConfigurationResource>> resolve() async {
    Map<String, String> paths = await applicationConfigurationResourceFinder.search(ResourceFileTypes.YML);
    List<ApplicationConfigurationResource> resources = List();
    for (var value in paths.values) {
      resources.add(ApplicationConfigurationResource.fromPath(value));
    }
    return resources;
  }
}
