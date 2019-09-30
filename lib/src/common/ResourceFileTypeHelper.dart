enum ResourceFileTypes { YML, PROPERTIES, CONF, XML, JSON }

class ResourceFileTypeHelper {
  static toExtension(ResourceFileTypes type) {
    switch (type) {
      case ResourceFileTypes.YML:
        return 'yml';
      case ResourceFileTypes.CONF:
        return 'conf';
      case ResourceFileTypes.JSON:
        return 'json';
      case ResourceFileTypes.PROPERTIES:
        return 'properties';
      case ResourceFileTypes.XML:
        return 'xml';
      default:
        break;
    }
  }
}
