enum ResourceFileTypes { YML, PROPERTIES, CONF, XML, JSON }

class ResourceFileTypesLink {
  static get(ResourceFileTypes type) {
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
