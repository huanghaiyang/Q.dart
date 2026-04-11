import 'dart:io';
import 'dart:mirrors';

import 'package:Q/Q.dart';
import 'package:Q/src/Application.dart';
import 'package:Q/src/Redirect.dart';
import 'package:Q/src/Router.dart';
import 'package:Q/src/Method.dart';
import 'package:Q/src/annotation/AttributeValue.dart';
import 'package:Q/src/annotation/Body.dart';
import 'package:Q/src/annotation/Config.dart';
import 'package:Q/src/annotation/CookieValue.dart';
import 'package:Q/src/annotation/PathVariable.dart';
import 'package:Q/src/annotation/RequestHeader.dart';
import 'package:Q/src/annotation/RequestParam.dart';
import 'package:Q/src/annotation/Request.dart' as RequestAnnotation;
import 'package:Q/src/annotation/SessionValue.dart';
import 'package:Q/src/annotation/UrlParam.dart';
import 'package:Q/src/i18n/annotations/Locale.dart';
import 'package:Q/src/i18n/LocaleHelper.dart';
import 'package:Q/src/exception/UnSupportRouterHandlerParameterAnnotationException.dart';
import 'package:Q/src/exception/RouterNotFoundException.dart';
import 'package:Q/src/helpers/AnnotationHelpers.dart';
import 'package:Q/src/helpers/RedirectHelper.dart';
import 'package:Q/src/helpers/reflect/AttributeValueHelper.dart';
import 'package:Q/src/helpers/reflect/BodyReflectHelper.dart';
import 'package:Q/src/helpers/reflect/ConfigValueHelper.dart';
import 'package:Q/src/helpers/reflect/CookieValueHelper.dart';
import 'package:Q/src/helpers/reflect/PathVariableHelper.dart';
import 'package:Q/src/helpers/reflect/RawBodyHelper.dart';
import 'package:Q/src/helpers/reflect/RequestHeaderHelper.dart';
import 'package:Q/src/helpers/reflect/RequestParamHelper.dart';
import 'package:Q/src/helpers/reflect/RequestHelper.dart';
import 'package:Q/src/helpers/reflect/SessionValueHelper.dart';
import 'package:Q/src/helpers/reflect/UrlParamHelper.dart';
import 'package:Q/src/utils/RouterTrie.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

class RouterHelper {
  // 匹配重定向
  static Future<Router> matchRedirect(Redirect redirect, List<Router> routers) async {
    // 先路由名称匹配
    Router matchedRouter = await RedirectHelper.matchRouter(redirect, routers);
    if (matchedRouter == null) {
      await for (Router router in Stream.fromIterable(routers)) {
        bool hasMatch = await router.matchRedirect(redirect);
        if (hasMatch) {
          matchedRouter = router;
        }
      }
    }
    return matchedRouter;
  }

  // 路由Trie树缓存
  static RouterTrie _routerTrie;
  static bool _trieInitialized = false;

  // 路由匹配结果缓存
  static Map<String, Router> _routerMatchCache = {};
  // 缓存大小限制
  static const int MAX_CACHE_SIZE = 1000;
  
  // 函数参数反射缓存
  static Map<Function, List<Future<dynamic>>> _parameterReflectionCache = {};
  // 参数反射缓存大小限制
  static const int MAX_PARAM_REFLECTION_CACHE_SIZE = 500;

  /**
   * 初始化路由Trie树
   */
  static void initRouterTrie(List<Router> routers) {
    if (!_trieInitialized) {
      _routerTrie = RouterTrie();
      for (Router router in routers) {
        _routerTrie.addRouter(router);
      }
      _trieInitialized = true;
    }
  }

  /**
   * 重置路由Trie树
   */
  static void resetRouterTrie() {
    _trieInitialized = false;
    _routerTrie = null;
    // 同时清除缓存
    resetPathRegexCache();
    resetRouterMatchCache();
  }

  /**
   * 重置路径正则表达式缓存
   */
  static void resetPathRegexCache() {
    _pathRegexCache.clear();
    _pathParametersCache.clear();
  }

  /**
   * 重置路由匹配结果缓存
   */
  static void resetRouterMatchCache() {
    _routerMatchCache.clear();
  }

  /**
   * 生成缓存键
   */
  static String _generateCacheKey(HttpRequest request) {
    // 规范化路径，防止缓存投毒
    String normalizedPath = request.uri.path
        .replaceAll(RegExp(r'//+'), '/')  // 移除重复斜杠
        .replaceAll(RegExp(r'(/\.)+'), '/')   // 移除当前目录引用
        .replaceAll(RegExp(r'/[^/]+/\.\.'), '/'); // 移除父目录引用
    return '${request.method.toUpperCase()}:$normalizedPath';
  }

  /**
   * 添加路由匹配结果到缓存
   */
  static void _addToCache(String key, Router router) {
    // 检查缓存大小
    if (_routerMatchCache.length >= MAX_CACHE_SIZE) {
      // 移除最早的缓存项
      String firstKey = _routerMatchCache.keys.first;
      _routerMatchCache.remove(firstKey);
    }
    _routerMatchCache[key] = router;
  }

  // 匹配路由
  static Future<Router> matchRouter(HttpRequest req, List<Router> routers) async {
    try {
      // 生成缓存键
      String cacheKey = _generateCacheKey(req);
      
      // 检查缓存
      if (_routerMatchCache.containsKey(cacheKey)) {
        Router cachedRouter = _routerMatchCache[cacheKey];
        cachedRouter.apply(req);
        // 更新路由状态
        cachedRouter.state.matched = true;
        cachedRouter.state.matchTime = DateTime.now();
        cachedRouter.state.matchedRouterName = cachedRouter.name;
        cachedRouter.state.fromCache = true;
        return cachedRouter;
      }

      // 初始化Trie树
      if (!_trieInitialized) {
        initRouterTrie(routers);
      }

      // 使用Trie树匹配路由
      Router matchedRouter = _routerTrie.matchRouter(req);
      if (matchedRouter != null) {
        matchedRouter.apply(req);
        // 更新路由状态
        matchedRouter.state.matched = true;
        matchedRouter.state.matchTime = DateTime.now();
        matchedRouter.state.matchedRouterName = matchedRouter.name;
        matchedRouter.state.fromCache = false;
        // 添加到缓存
        _addToCache(cacheKey, matchedRouter);
      } else {
        // 抛出详细的路由未找到异常
        throw RouterNotFoundException.withRequest(req);
      }
      return matchedRouter;
    } catch (e) {
      // 安全处理异常
      print('Router matching error: $e');
      // 抛出通用异常，避免泄露敏感信息
      throw RouterNotFoundException('Route not found');
    }
  }

  // 正则表达式缓存
  static Map<String, RegExp> _pathRegexCache = {};
  static Map<String, List<String>> _pathParametersCache = {};

  // 通过理由地址获取路由地址参数
  static Map<String, String> applyPathVariables(String requestPath, String path) {
    // 检查缓存
    if (!_pathRegexCache.containsKey(path)) {
      final parameters = <String>[];
      final regExp = pathToRegExp(path, parameters: parameters);
      _pathRegexCache[path] = regExp;
      _pathParametersCache[path] = parameters;
    }

    final regExp = _pathRegexCache[path];
    final parameters = _pathParametersCache[path];
    final match = regExp.matchAsPrefix(requestPath);
    
    // 提取参数
    Map<String, String> params = {};
    if (match != null) {
      params = extract(parameters, match);
    }
    
    // 验证和过滤参数
    Map<String, String> filteredParams = {};
    params.forEach((key, value) {
      // 验证参数名称的合法性
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(key)) {
        return; // 跳过非法参数名
      }
      
      // 移除可能的恶意字符
      String filteredValue = value.replaceAll(RegExp(r'[<"&]'), '');
      // 移除控制字符
      filteredValue = filteredValue.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
      // 限制参数值长度，防止过大的参数值
      if (filteredValue.length > 1000) {
        filteredValue = filteredValue.substring(0, 1000);
      }
      
      filteredParams[key] = filteredValue;
    });
    
    return filteredParams;
  }

  // 检查路由路径是否有效
  static bool checkPathAvailable(String path) {
    if (path == null || path.isEmpty) return false;
    // 防止路径遍历攻击
    if (path.contains('..') || path.contains('./') || path.contains('//')) {
      return false;
    }
    // 确保路径以 / 开头
    if (!path.startsWith('/')) {
      return false;
    }
    // 防止包含控制字符
    if (RegExp(r'[\x00-\x1F\x7F]').hasMatch(path)) {
      return false;
    }
    // 允许路由参数（如 :id）
    return true;
  }

  // 通过路由地址参数重建地址
  static String reBuildPathByVariables(Router router) {
    String path = router.path;
    router.pathVariables.forEach((dynamic key, dynamic val) {
      String keyStr = key.toString();
      String valStr = val.toString();
      // 使用字符串替换而不是正则表达式，提高效率
      path = path.replaceAll(':$keyStr', valStr);
    });
    return path;
  }

  // 反射获取路由处理器方法的参数列表
  static Future<List<dynamic>> listParameters(Router router) async {
    // 验证参数的合法性
    if (router == null) {
      throw ArgumentError('Router cannot be null');
    }
    if (router.handle == null) {
      throw ArgumentError('Router handle cannot be null');
    }
    
    // 检查缓存
    if (_parameterReflectionCache.containsKey(router.handle)) {
      List<Future<dynamic>> cachedFutures = _parameterReflectionCache[router.handle];
      return await Future.wait(cachedFutures);
    }
    
    List<Future<dynamic>> futures = [];
    try {
      FunctionTypeMirror functionTypeMirror = reflect(router.handle).type;
      // 限制参数数量，防止过多参数导致的安全问题
      if (functionTypeMirror.parameters.length > 100) {
        print('Warning: Router handle has too many parameters: ${functionTypeMirror.parameters.length}');
        return futures;
      }
      
      functionTypeMirror.parameters.forEach((ParameterMirror parameterMirror) {
        List<InstanceMirror> instanceMirrors = parameterMirror.metadata;
        if (instanceMirrors.isNotEmpty) {
          for (InstanceMirror instanceMirror in instanceMirrors) {
            ClassMirror type = instanceMirror.type;
            // 验证注解类型是否安全
            if (SUPPORTED_ROUTER_HANDLER_PARAMETER_ANNOTATION_CLASSES.indexWhere((classMirror) => classMirror == type) == -1) {
              continue; // 跳过不支持的注解
            }
            // 限制注解数量，防止恶意注解
            if (instanceMirrors.length > 30) {
              continue; // 每个参数最多3个注解
            }
            
            List params = [router, parameterMirror, instanceMirror];
            // 安全地应用反射辅助方法
            if (type == reflectClass(PathVariable)) {
              futures.add(Function.apply(PathVariableHelper.reflectPathVariable, params));
              break;
            }
            if (type == reflectClass(CookieValue)) {
              futures.add(Function.apply(CookieValueHelper.reflectCookieValue, params));
              break;
            }
            if (type == reflectClass(RequestHeader)) {
              futures.add(Function.apply(RequestHeaderHelper.reflectRequestHeader, params));
              break;
            }
            if (type == reflectClass(SessionValue)) {
              futures.add(Function.apply(SessionValueHelper.reflectSessionValue, params));
              break;
            }
            if (type == reflectClass(AttributeValue)) {
              futures.add(Function.apply(AttributeValueHelper.reflectAttributeValue, params));
              break;
            }
            if (type == reflectClass(UrlParam)) {
              futures.add(Function.apply(UrlParamHelper.reflectUrlParams, params));
              break;
            }
            if (type == reflectClass(RequestParam)) {
              futures.add(Function.apply(RequestParamHelper.reflectRequestParam, params));
              break;
            }
            if (type == reflectClass(Config)) {
              futures.add(Function.apply(ConfigValueHelper.reflectConfigValue, params));
              break;
            }
            if (type == reflectClass(Body)) {
              futures.add(Function.apply(BodyReflectHelper.reflectBody, params));
              break;
            }
            if (type == reflectClass(RawBody)) {
              futures.add(Function.apply(RawBodyHelper.reflect, params));
              break;
            }
            if (type == reflectClass(Locale)) {
              List localeParams = [router.context, parameterMirror, instanceMirror];
              futures.add(Function.apply(LocaleHelper.reflectLocaleParameter, localeParams));
              break;
            }
            if (type == reflectClass(RequestAnnotation.Request)) {
              futures.add(Function.apply(RequestHelper.reflectRequest, params));
              break;
            }
          }
        }
      });
      
      // 缓存反射结果
      if (futures.isNotEmpty) {
        // 检查缓存大小
        if (_parameterReflectionCache.length >= MAX_PARAM_REFLECTION_CACHE_SIZE) {
          // 移除最早的缓存项
          Function firstKey = _parameterReflectionCache.keys.first;
          _parameterReflectionCache.remove(firstKey);
        }
        _parameterReflectionCache[router.handle] = futures;
      }
    } catch (e) {
      // 安全处理反射异常
      print('Reflection error: $e');
    }
    return await Future.wait(futures);
  }

  // 检查路由处理器上的注解参数是否合法
  static void checkoutRouterHandlerParameterAnnotations(Router router) {
    FunctionTypeMirror functionTypeMirror = reflect(router.handle).type;
    for (ParameterMirror parameterMirror in functionTypeMirror.parameters) {
      List<InstanceMirror> instanceMirrors = parameterMirror.metadata;
      if (instanceMirrors.isNotEmpty) {
        for (InstanceMirror instanceMirror in instanceMirrors) {
          ClassMirror type = instanceMirror.type;
          if (SUPPORTED_ROUTER_HANDLER_PARAMETER_ANNOTATION_CLASSES.indexWhere((classMirror) => classMirror == type) == -1) {
            throw UnSupportRouterHandlerParameterAnnotationException(router: router, annotation: type.reflectedType);
          }
        }
      }
    }
  }

  // 默认路由根路径
  static String getPath(String path) {
    String defaultMapping = '/'; // 默认值
    try {
      var config = Application.getApplicationContext()?.configuration;
      if (config != null) {
        var routerMapping = config.routerMappingConfigure;
        if (routerMapping != null && routerMapping.defaultMapping != null) {
          defaultMapping = routerMapping.defaultMapping;
        }
      }
    } catch (e) {
      // 忽略配置错误，使用默认值
      print('Error getting default mapping: $e');
    }
    if (!path.startsWith(defaultMapping)) {
      path = '$defaultMapping${path}';
    }
    return path;
  }
}
