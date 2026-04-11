import 'dart:io';

import 'package:Q/Q.dart';

class ResponseHelper {
  static void addCorsHeaders(HttpRequest request, HttpResponse response) async {
    var applicationContext = Application.getApplicationContext();
    var config = applicationContext?.configuration?.httpRequestConfigure;
    
    // 设置允许的源
    if (config?.allowedOrigins != null && config.allowedOrigins.isNotEmpty) {
      if (config.allowedOrigins.contains('*')) {
        response.headers.add('Access-Control-Allow-Origin', '*');
      } else {
        // 根据请求的Origin头设置相应的允许源
        String origin = request.headers.value('Origin');
        if (origin != null && config.allowedOrigins.contains(origin)) {
          response.headers.add('Access-Control-Allow-Origin', origin);
        } else {
          // 如果请求的Origin不在允许列表中，使用第一个允许的源
          response.headers.add('Access-Control-Allow-Origin', config.allowedOrigins[0]);
        }
      }
    } else {
      response.headers.add('Access-Control-Allow-Origin', '*');
    }
    
    // 设置允许的方法
    if (config?.allowedMethods != null && config.allowedMethods.isNotEmpty) {
      String methods = config.allowedMethods.map((method) => method.toString().split('.')[1]).join(', ');
      response.headers.add('Access-Control-Allow-Methods', methods);
    } else {
      response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD');
    }
    
    // 设置允许的头
    if (config?.allowedHeaders != null && config.allowedHeaders.isNotEmpty) {
      String headers = config.allowedHeaders.join(', ');
      response.headers.add('Access-Control-Allow-Headers', headers);
    } else {
      response.headers.add('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, X-CSRF-Token');
    }
    
    // 设置是否允许凭证
    if (config?.allowedCredentials != null && config.allowedCredentials.contains('true')) {
      response.headers.add('Access-Control-Allow-Credentials', 'true');
    }
    
    // 设置预检请求的缓存时间
    if (config?.maxAge != null) {
      response.headers.add('Access-Control-Max-Age', config.maxAge.toString());
    }
  }
}
