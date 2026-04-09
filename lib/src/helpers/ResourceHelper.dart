import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/ApplicationBootstrapArgsResolver.dart';

class ResourceHelper {
  static Future<String> findResourceDirectory() async {
    String resourceDir = await ApplicationBootstrapArgsResolver.instance().get('application.resourceDir');
    resourceDir = resourceDir != null && resourceDir.isNotEmpty ? resourceDir : '/lib/resources';
    
    // 打印调试信息
    print('Current directory: ${Directory.current.path}');
    print('Found resourceDir: $resourceDir');
    
    String result;
    // 如果资源目录以 / 开头，返回当前工作目录 + 资源目录
    if (resourceDir.startsWith('/')) {
      result = '${Directory.current.path}${resourceDir}';
    } else {
      // 否则，返回项目根目录 + 资源目录
      String path = _findProjectRoot(Directory.current.path);
      result = '${path}/${resourceDir}';
    }
    
    // 打印调试信息
    print('Resource directory: $result');
    print('Does directory exist: ${Directory(result).existsSync()}');
    if (Directory(result).existsSync()) {
      print('Directory contents: ${Directory(result).listSync().map((e) => e.path).toList()}');
    }
    
    return result;
  }
  
  /// 查找项目根目录
  /// 从当前目录向上遍历，直到找到包含 lib/resources 的目录
  static String _findProjectRoot(String currentPath) {
    Directory dir = Directory(currentPath);
    
    // 向上遍历目录树，最多遍历10层
    for (int i = 0; i < 10; i++) {
      // 检查当前目录是否包含 lib/resources
      String resourcesPath = '${dir.path}/lib/resources';
      if (Directory(resourcesPath).existsSync()) {
        return dir.path;
      }
      
      // 检查当前目录是否包含 pubspec.yaml（Dart项目根目录标志）
      String pubspecPath = '${dir.path}/pubspec.yaml';
      if (File(pubspecPath).existsSync()) {
        return dir.path;
      }
      
      // 获取父目录
      Directory parentDir = dir.parent;
      if (parentDir.path == dir.path) {
        // 已经到达根目录
        break;
      }
      dir = parentDir;
    }
    
    // 如果没找到，返回当前目录
    return currentPath;
  }
}
