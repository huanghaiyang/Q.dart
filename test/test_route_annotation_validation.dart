import 'dart:io';

import 'package:Q/Q.dart';
import 'package:Q/src/annotation/Route.dart';
import 'package:Q/src/helpers/RouteScanner.dart';

// 正常情况：一个方法只有一个HTTP方法注解
class NormalController {
  @Get('/normal/users')
  Future<dynamic> getUsers(Context context) async {
    return {
      'message': 'Get all users',
      'controller': 'NormalController',
      'method': 'getUsers'
    };
  }
}

// 错误情况：一个方法有多个HTTP方法注解
class MultipleHttpMethodsController {
  @Get('/multiple/users')
  @Post('/multiple/users')
  Future<dynamic> handleUsers(Context context) async {
    return {
      'message': 'Handle users',
      'controller': 'MultipleHttpMethodsController',
      'method': 'handleUsers'
    };
  }
}

// 正常情况：一个类只有一个@BlueprintRoute注解
@BlueprintRoute('normal_blueprint', prefix: '/api/normal')
class NormalBlueprintController {
  @Get('users')
  Future<dynamic> getUsers(Context context) async {
    return {
      'message': 'Get all users from blueprint',
      'controller': 'NormalBlueprintController',
      'method': 'getUsers'
    };
  }
}

// 错误情况：一个类有多个@BlueprintRoute注解
@BlueprintRoute('first_blueprint', prefix: '/api/first')
@BlueprintRoute('second_blueprint', prefix: '/api/second')
class MultipleBlueprintsController {
  @Get('users')
  Future<dynamic> getUsers(Context context) async {
    return {
      'message': 'Get all users',
      'controller': 'MultipleBlueprintsController',
      'method': 'getUsers'
    };
  }
}

Future<void> testNormalController() async {
  print('\nTesting NormalController...');
  try {
    Application app = Application()..args([]);
    await app.init();
    RouteScanner.scanClass(app, NormalController);
    print('✓ NormalController: No errors - one HTTP method annotation per method');
  } catch (e) {
    print('✗ NormalController: Error - $e');
  }
}

Future<void> testMultipleHttpMethodsController() async {
  print('\nTesting MultipleHttpMethodsController...');
  try {
    Application app = Application()..args([]);
    await app.init();
    RouteScanner.scanClass(app, MultipleHttpMethodsController);
    print('✗ MultipleHttpMethodsController: No error thrown - should have error for multiple HTTP method annotations');
  } catch (e) {
    print('✓ MultipleHttpMethodsController: Correctly threw error - $e');
  }
}

Future<void> testNormalBlueprintController() async {
  print('\nTesting NormalBlueprintController...');
  try {
    Application app = Application()..args([]);
    await app.init();
    RouteScanner.scanClass(app, NormalBlueprintController);
    print('✓ NormalBlueprintController: No errors - one @BlueprintRoute annotation per class');
  } catch (e) {
    print('✗ NormalBlueprintController: Error - $e');
  }
}

Future<void> testMultipleBlueprintsController() async {
  print('\nTesting MultipleBlueprintsController...');
  try {
    Application app = Application()..args([]);
    await app.init();
    RouteScanner.scanClass(app, MultipleBlueprintsController);
    print('✗ MultipleBlueprintsController: No error thrown - should have error for multiple @BlueprintRoute annotations');
  } catch (e) {
    print('✓ MultipleBlueprintsController: Correctly threw error - $e');
  }
}

void main() async {
  print('Testing route annotation validation...');
  
  await testNormalController();
  await testMultipleHttpMethodsController();
  await testNormalBlueprintController();
  await testMultipleBlueprintsController();
  
  print('\nAll tests completed!');
}
