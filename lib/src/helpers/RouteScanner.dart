import 'dart:io';
import 'dart:mirrors';

import 'package:Q/Q.dart';
import 'package:Q/src/annotation/Route.dart';

/// 路由扫描器，用于扫描带有路由注解的类和方法
class RouteScanner {
  /// 扫描指定类中的路由注解，将其转换为路由并注册到应用
  static void scanClass(Application app, Type clazz) {
    if (app == null || clazz == null) return;
    
    ClassMirror classMirror = reflectClass(clazz);
    
    // 检查类是否带有BlueprintRoute注解
    BlueprintRoute blueprintAnnotation = _getBlueprintAnnotation(classMirror);
    if (blueprintAnnotation != null) {
      // 如果是Blueprint类，创建Blueprint并扫描其中的路由
      _scanBlueprintClass(app, classMirror, blueprintAnnotation);
    } else {
      // 否则，直接扫描类中的路由注解
      _scanRegularClass(app, classMirror);
    }
  }
  
  /// 扫描指定包中的所有类，查找带有路由注解的方法
  static void scanPackage(Application app, String packageName) {
    // 这里可以实现更复杂的包扫描逻辑
    // 目前暂时只支持扫描指定类
  }
  
  /// 扫描带有BlueprintRoute注解的类
  static void _scanBlueprintClass(Application app, ClassMirror classMirror, BlueprintRoute blueprintAnnotation) {
    // 创建Blueprint
    Blueprint blueprint = Blueprint(blueprintAnnotation.name, prefix: blueprintAnnotation.prefix);
    
    // 扫描类中的所有方法
    for (var declaration in classMirror.declarations.values) {
      if (declaration is MethodMirror && !declaration.isConstructor && !declaration.isStatic) {
        // 检查方法上的路由注解
        Route route = _getRouteAnnotation(declaration);
        if (route != null) {
          // 检查路由路径是否为完整路径（以/开头）
          if (route.path.startsWith('/')) {
            // 对于Blueprint中的路由，建议使用相对路径
            // 但为了兼容性，我们支持完整路径，会自动添加Blueprint前缀
            print('Warning: Using absolute path "${route.path}" in Blueprint "${blueprintAnnotation.name}". The path will be prefixed with "${blueprintAnnotation.prefix}".');
          }
          
          // 创建路由处理函数
          RouterHandleFunction handle = (Context context, [HttpRequest req, HttpResponse res, dynamic data]) async {
            // 创建类实例
            var instance = classMirror.newInstance(Symbol.empty, []).reflectee;
            
            // 准备方法参数
            List<dynamic> args = [context];
            if (req != null) args.add(req);
            if (res != null) args.add(res);
            if (data != null) args.add(data);
            
            // 调用方法
            var result = await classMirror.invoke(declaration.simpleName, args).reflectee;
            return result;
          };
          
          // 根据注解类型创建相应的路由到Blueprint中
          _createRouteInBlueprint(blueprint, route, declaration, handle);
        }
      }
    }
    
    // 注册Blueprint到应用
    app.registerBlueprint(blueprint);
  }
  
  /// 扫描普通类中的路由注解
  static void _scanRegularClass(Application app, ClassMirror classMirror) {
    // 扫描类中的所有方法
    for (var declaration in classMirror.declarations.values) {
      if (declaration is MethodMirror && !declaration.isConstructor && !declaration.isStatic) {
        // 检查方法上的路由注解
        Route route = _getRouteAnnotation(declaration);
        if (route != null) {
          // 创建路由处理函数
          RouterHandleFunction handle = (Context context, [HttpRequest req, HttpResponse res, dynamic data]) async {
            // 创建类实例
            var instance = classMirror.newInstance(Symbol.empty, []).reflectee;
            
            // 准备方法参数
            List<dynamic> args = [context];
            if (req != null) args.add(req);
            if (res != null) args.add(res);
            if (data != null) args.add(data);
            
            // 调用方法
            var result = await classMirror.invoke(declaration.simpleName, args).reflectee;
            return result;
          };
          
          // 根据注解类型创建相应的路由
          _createRoute(app, route, declaration, handle);
        }
      }
    }
  }
  
  /// 获取类上的BlueprintRoute注解
  static BlueprintRoute _getBlueprintAnnotation(ClassMirror classMirror) {
    List<BlueprintRoute> annotations = [];
    for (var metadata in classMirror.metadata) {
      var annotation = metadata.reflectee;
      if (annotation is BlueprintRoute) {
        annotations.add(annotation);
      }
    }
    
    if (annotations.length > 1) {
      throw ArgumentError('A class can only have one @BlueprintRoute annotation. Found ${annotations.length} annotations.');
    }
    
    return annotations.isNotEmpty ? annotations[0] : null;
  }
  
  /// 获取方法上的路由注解
  static Route _getRouteAnnotation(MethodMirror methodMirror) {
    List<Route> annotations = [];
    for (var metadata in methodMirror.metadata) {
      var annotation = metadata.reflectee;
      if (annotation is Route) {
        annotations.add(annotation);
      }
    }
    
    if (annotations.length > 1) {
      throw ArgumentError('A method can only have one HTTP method annotation (e.g., @Get, @Post). Found ${annotations.length} annotations.');
    }
    
    return annotations.isNotEmpty ? annotations[0] : null;
  }
  
  /// 根据注解类型创建相应的路由到Application中
  static void _createRoute(Application app, Route route, MethodMirror methodMirror, RouterHandleFunction handle) {
    if (route is Get) {
      app.get(route.path, handle, name: route.name);
    } else if (route is Post) {
      app.post(route.path, handle, name: route.name);
    } else if (route is Put) {
      app.put(route.path, handle, name: route.name);
    } else if (route is Delete) {
      app.delete(route.path, handle, name: route.name);
    } else if (route is Patch) {
      app.patch(route.path, handle, name: route.name);
    }
  }
  
  /// 根据注解类型创建相应的路由到Blueprint中
  static void _createRouteInBlueprint(Blueprint blueprint, Route route, MethodMirror methodMirror, RouterHandleFunction handle) {
    if (route is Get) {
      blueprint.get(route.path, handle, name: route.name);
    } else if (route is Post) {
      blueprint.post(route.path, handle, name: route.name);
    } else if (route is Put) {
      blueprint.put(route.path, handle, name: route.name);
    } else if (route is Delete) {
      blueprint.delete(route.path, handle, name: route.name);
    } else if (route is Patch) {
      blueprint.patch(route.path, handle, name: route.name);
    }
  }
}
