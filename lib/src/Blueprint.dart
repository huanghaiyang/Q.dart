import 'dart:io';

import 'package:Q/Q.dart';

/// Blueprint类，用于组织相关路由，类似Flask的Blueprint
/// 可以为一组路由设置共同的前缀
class Blueprint {
  /// Blueprint的名称
  final String name;
  
  /// 路由前缀
  final String prefix;
  
  /// 注册的路由列表
  final List<Router> _routers = [];
  
  /// 创建一个Blueprint
  /// [name] Blueprint的名称
  /// [prefix] 路由前缀，默认为空字符串
  Blueprint(this.name, {this.prefix = ''});
  
  /// 注册GET路由
  Router get(String path, RouterHandleFunction handle, {
    Map pathVariables,
    ContentType produceType,
    AbstractHttpMessageConverter converter,
    HandlerAdapter handlerAdapter,
    String name}) {
    return _addRoute(HttpMethod.GET, path, handle, 
        pathVariables: pathVariables, 
        produceType: produceType, 
        converter: converter, 
        handlerAdapter: handlerAdapter, 
        name: name);
  }
  
  /// 注册POST路由
  Router post(String path, RouterHandleFunction handle, {
    Map pathVariables,
    ContentType produceType,
    AbstractHttpMessageConverter converter,
    HandlerAdapter handlerAdapter,
    String name}) {
    return _addRoute(HttpMethod.POST, path, handle, 
        pathVariables: pathVariables, 
        produceType: produceType, 
        converter: converter, 
        handlerAdapter: handlerAdapter, 
        name: name);
  }
  
  /// 注册PUT路由
  Router put(String path, RouterHandleFunction handle, {
    Map pathVariables,
    ContentType produceType,
    AbstractHttpMessageConverter converter,
    HandlerAdapter handlerAdapter,
    String name}) {
    return _addRoute(HttpMethod.PUT, path, handle, 
        pathVariables: pathVariables, 
        produceType: produceType, 
        converter: converter, 
        handlerAdapter: handlerAdapter, 
        name: name);
  }
  
  /// 注册DELETE路由
  Router delete(String path, RouterHandleFunction handle, {
    Map pathVariables,
    ContentType produceType,
    AbstractHttpMessageConverter converter,
    HandlerAdapter handlerAdapter,
    String name}) {
    return _addRoute(HttpMethod.DELETE, path, handle, 
        pathVariables: pathVariables, 
        produceType: produceType, 
        converter: converter, 
        handlerAdapter: handlerAdapter, 
        name: name);
  }
  
  /// 注册PATCH路由
  Router patch(String path, RouterHandleFunction handle, {
    Map pathVariables,
    ContentType produceType,
    AbstractHttpMessageConverter converter,
    HandlerAdapter handlerAdapter,
    String name}) {
    return _addRoute(HttpMethod.PATCH, path, handle, 
        pathVariables: pathVariables, 
        produceType: produceType, 
        converter: converter, 
        handlerAdapter: handlerAdapter, 
        name: name);
  }
  
  /// 添加路由的内部方法
  Router _addRoute(HttpMethod method, String path, RouterHandleFunction handle, {
    Map pathVariables,
    ContentType produceType,
    AbstractHttpMessageConverter converter,
    HandlerAdapter handlerAdapter,
    String name}) {
    // 构建完整的路径，添加前缀
    String fullPath = _buildFullPath(prefix, path);
    
    // 创建路由
    Router router = Router(fullPath, method, handle, 
        pathVariables: pathVariables, 
        produceType: produceType, 
        converter: converter, 
        handlerAdapter: handlerAdapter, 
        name: name);
    
    // 添加到路由列表
    _routers.add(router);
    
    return router;
  }
  
  /// 构建完整的路径
  String _buildFullPath(String prefix, String path) {
    if (prefix.isEmpty) {
      return path;
    }
    
    // 确保前缀以/开头
    if (!prefix.startsWith('/')) {
      prefix = '/$prefix';
    }
    
    // 确保路径以/开头
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    
    // 移除前缀末尾的/（如果有）
    if (prefix.endsWith('/') && prefix.length > 1) {
      prefix = prefix.substring(0, prefix.length - 1);
    }
    
    return '$prefix$path';
  }
  
  /// 获取注册的路由列表
  List<Router> get routers => List.unmodifiable(_routers);
}
