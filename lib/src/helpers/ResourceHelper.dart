import 'dart:io';

import 'package:Q/Q.dart';

class ResourceHelper {
  static Future<String> findResourceDirectory() async {
    String resourceDir = await ApplicationBootstrapArgsResolver.instance().get('application.resourceDir');
    resourceDir = resourceDir != null && resourceDir.isNotEmpty ? resourceDir : '/lib/resources';
    String path = Directory.current.path;
    return '${path}${resourceDir}';
  }
}
