enum ResourceType { CONFIGURATION }

abstract class Resource {
  String get name;

  String get filepath;

  ResourceType get type;
}
