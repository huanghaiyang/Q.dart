import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/annotation/Route.dart';
import 'package:Q/src/helpers/RouteScanner.dart';

// 普通路由注解示例
class RegularController {
  @Get('/regular/users')
  Future<dynamic> getUsers(Context context) async {
    return {
      'message': 'Get all users from regular controller',
      'controller': 'RegularController',
      'method': 'getUsers'
    };
  }
}

// Blueprint中使用相对路径的示例
@BlueprintRoute('relative_blueprint', prefix: '/api/relative')
class RelativePathBlueprintController {
  @Get('users')
  Future<dynamic> getUsers(Context context) async {
    return {
      'message': 'Get all users from blueprint with relative path',
      'controller': 'RelativePathBlueprintController',
      'method': 'getUsers'
    };
  }
  
  @Get('users/:id')
  Future<dynamic> getUserById(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Get user by id from blueprint with relative path',
      'id': id,
      'controller': 'RelativePathBlueprintController',
      'method': 'getUserById'
    };
  }
}

// Blueprint中使用绝对路径的示例（混合式路由注解）
@BlueprintRoute('absolute_blueprint', prefix: '/api/absolute')
class AbsolutePathBlueprintController {
  @Get('/users')
  Future<dynamic> getUsers(Context context) async {
    return {
      'message': 'Get all users from blueprint with absolute path',
      'controller': 'AbsolutePathBlueprintController',
      'method': 'getUsers'
    };
  }
  
  @Get('/users/:id')
  Future<dynamic> getUserById(Context context, [HttpRequest req, HttpResponse res, @PathVariable('id') String id]) async {
    return {
      'message': 'Get user by id from blueprint with absolute path',
      'id': id,
      'controller': 'AbsolutePathBlueprintController',
      'method': 'getUserById'
    };
  }
}

void main() async {
  Application app = Application()..args([]);
  await app.init();
  
  // 扫描所有控制器
  RouteScanner.scanClass(app, RegularController);
  RouteScanner.scanClass(app, RelativePathBlueprintController);
  RouteScanner.scanClass(app, AbsolutePathBlueprintController);
  
  // 启动服务器
  await app.listen(8080);
  print('Test server started on port 8080');
  print('\nAvailable endpoints:');
  print('Regular routes:');
  print('- GET  /regular/users        - Get all users from regular controller');
  print('\nBlueprint with relative paths:');
  print('- GET  /api/relative/users        - Get all users from blueprint with relative path');
  print('- GET  /api/relative/users/:id    - Get user by id from blueprint with relative path');
  print('\nBlueprint with absolute paths (mixed routing):');
  print('- GET  /api/absolute/users        - Get all users from blueprint with absolute path');
  print('- GET  /api/absolute/users/:id    - Get user by id from blueprint with absolute path');
  print('\nPress Ctrl+C to stop the server');
}
