import 'dart:io';
import 'dart:convert';
import 'dart:io' as io;
import 'package:Q/src/Context.dart';
import 'package:Q/src/Middleware.dart';

/// 压缩中间件
/// 用于压缩响应数据，减少网络传输量
class CompressionMiddleware implements Middleware {
  @override
  MiddlewareType type = MiddlewareType.AFTER;
  @override
  int priority = 40;
  @override
  String name = 'compression';
  @override
  String group = 'performance';

  /// 压缩级别
  final int level;
  
  /// 最小压缩大小（字节）
  final int minSize;
  
  /// 支持的压缩算法
  final List<CompressionAlgorithm> algorithms;

  /// 构造函数
  /// [level] 压缩级别，1-9，默认为6
  /// [minSize] 最小压缩大小（字节），默认为1024
  /// [algorithms] 支持的压缩算法，默认为[gzip, deflate]
  CompressionMiddleware({
    this.level = 6,
    this.minSize = 1024,
    this.algorithms = const [CompressionAlgorithm.gzip, CompressionAlgorithm.deflate],
  });

  @override
  Future<Context> handle(Context context, Function onFinished, Function onError) async {
    // 继续处理请求
    Context result = await onFinished();
    
    // 检查是否需要压缩
    if (_shouldCompress(result)) {
      // 获取客户端支持的压缩算法
      String acceptEncoding = result.request.req.headers.value('Accept-Encoding') ?? '';
      
      // 选择合适的压缩算法
      CompressionAlgorithm algorithm = _selectAlgorithm(acceptEncoding);
      
      if (algorithm != null) {
        try {
          // 压缩响应体
          await _compressResponse(result, algorithm);
        } catch (e) {
          print('Compression error: $e');
          // 压缩失败，不影响响应，继续返回
        }
      }
    }
    
    return result;
  }

  /// 检查是否需要压缩
  bool _shouldCompress(Context context) {
    // 检查响应状态码
    if (context.response.status < 200 || context.response.status >= 300) {
      return false;
    }
    
    // 检查响应体
    if (context.response.body == null) {
      return false;
    }
    
    // 检查内容类型
    ContentType contentType = context.response.headers.contentType;
    if (contentType == null) {
      return false;
    }
    
    // 只压缩文本类型
    String mimeType = contentType.mimeType;
    if (!_isCompressibleMimeType(mimeType)) {
      return false;
    }
    
    // 检查响应体大小
    int bodySize = _getBodySize(context.response.body);
    return bodySize >= minSize;
  }

  /// 检查MIME类型是否可压缩
  bool _isCompressibleMimeType(String mimeType) {
    return mimeType.startsWith('text/') ||
           mimeType == 'application/json' ||
           mimeType == 'application/javascript' ||
           mimeType == 'application/xml' ||
           mimeType == 'application/xhtml+xml' ||
           mimeType == 'application/rss+xml' ||
           mimeType == 'application/atom+xml' ||
           mimeType == 'application/vnd.api+json';
  }

  /// 获取响应体大小
  int _getBodySize(dynamic body) {
    if (body is String) {
      return utf8.encode(body).length;
    } else if (body is List<int>) {
      return body.length;
    } else {
      return utf8.encode(body.toString()).length;
    }
  }

  /// 选择压缩算法
  CompressionAlgorithm _selectAlgorithm(String acceptEncoding) {
    for (CompressionAlgorithm algorithm in algorithms) {
      switch (algorithm) {
        case CompressionAlgorithm.gzip:
          if (acceptEncoding.contains('gzip')) {
            return CompressionAlgorithm.gzip;
          }
          break;
        case CompressionAlgorithm.deflate:
          if (acceptEncoding.contains('deflate')) {
            return CompressionAlgorithm.deflate;
          }
          break;
      }
    }
    return null;
  }

  /// 压缩响应
  Future<void> _compressResponse(Context context, CompressionAlgorithm algorithm) async {
    // 获取响应体
    dynamic body = context.response.body;
    List<int> data;
    
    // 转换响应体为字节列表
    if (body is String) {
      data = utf8.encode(body);
    } else if (body is List<int>) {
      data = body;
    } else {
      data = utf8.encode(body.toString());
    }
    
    // 压缩数据
    List<int> compressedData;
    String encoding;
    
    switch (algorithm) {
      case CompressionAlgorithm.gzip:
        compressedData = await _gzipCompress(data);
        encoding = 'gzip';
        break;
      case CompressionAlgorithm.deflate:
        compressedData = await _deflateCompress(data);
        encoding = 'deflate';
        break;
    }
    
    // 更新响应
    context.response.body = compressedData;
    context.response.headers.add('Content-Encoding', encoding);
    context.response.headers.add('Content-Length', compressedData.length.toString());
  }

  /// Gzip压缩
  Future<List<int>> _gzipCompress(List<int> data) async {
    io.GZipCodec codec = io.GZipCodec(level: level);
    List<int> compressed = codec.encode(data);
    return compressed;
  }

  /// Deflate压缩
  Future<List<int>> _deflateCompress(List<int> data) async {
    io.ZLibCodec codec = io.ZLibCodec(level: level);
    List<int> compressed = codec.encode(data);
    return compressed;
  }
}

/// 压缩算法
enum CompressionAlgorithm {
  gzip,
  deflate,
}
