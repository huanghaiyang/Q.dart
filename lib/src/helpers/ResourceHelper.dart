import 'dart:io';

class ResourceHelper {
  static String findResourceDirectory() {
    String path = Directory.current.path;
    return '${path}/lib/resources';
  }
}
