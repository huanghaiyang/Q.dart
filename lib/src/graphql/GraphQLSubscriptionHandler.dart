import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:Q/src/graphql/GraphQLExecutor.dart';

/// GraphQL 订阅处理器类
/// 用于处理 WebSocket 连接并实现 GraphQL 订阅功能
class GraphQLSubscriptionHandler {
  /// GraphQL 执行器
  final GraphQLExecutor executor;
  
  /// 活动的订阅
  final Map<String, StreamSubscription> _subscriptions = {};

  /// 构造函数
  GraphQLSubscriptionHandler({this.executor});

  /// 处理 WebSocket 连接
  void handleWebSocket(WebSocket webSocket) {
    // 处理连接建立
    print('WebSocket connected');
    
    // 发送连接确认消息
    _sendConnectionAck(webSocket);
    
    // 监听消息
    webSocket.listen(
      (message) async {
        try {
          // 解析消息
          Map<String, dynamic> request = jsonDecode(message);
          String type = request['type'];
          
          switch (type) {
            case 'connection_init':
              // 处理连接初始化
              _handleConnectionInit(webSocket, request);
              break;
            case 'start':
              // 处理订阅开始
              await _handleStart(webSocket, request);
              break;
            case 'stop':
              // 处理订阅停止
              _handleStop(webSocket, request);
              break;
            case 'connection_terminate':
              // 处理连接终止
              _handleConnectionTerminate(webSocket);
              break;
            default:
              // 处理未知消息类型
              _sendError(webSocket, null, 'Unknown message type');
          }
        } catch (e) {
          // 处理错误
          _sendError(webSocket, null, e.toString());
        }
      },
      onDone: () {
        // 处理连接关闭
        _handleDisconnect();
        print('WebSocket disconnected');
      },
      onError: (error) {
        // 处理错误
        print('WebSocket error: $error');
        _handleDisconnect();
      },
    );
  }
  
  /// 发送连接确认消息
  void _sendConnectionAck(WebSocket webSocket) {
    Map<String, dynamic> ackMessage = {
      'type': 'connection_ack'
    };
    webSocket.add(jsonEncode(ackMessage));
  }
  
  /// 处理连接初始化
  void _handleConnectionInit(WebSocket webSocket, Map<String, dynamic> request) {
    // 可以在这里处理连接初始化参数
    // 例如认证信息等
    _sendConnectionAck(webSocket);
  }
  
  /// 处理订阅开始
  Future<void> _handleStart(WebSocket webSocket, Map<String, dynamic> request) async {
    String id = request['id'];
    if (id == null) {
      _sendError(webSocket, null, 'Missing subscription id');
      return;
    }
    
    Map<String, dynamic> payload = request['payload'];
    if (payload == null) {
      _sendError(webSocket, id, 'Missing payload');
      return;
    }
    
    String query = payload['query'];
    if (query == null) {
      _sendError(webSocket, id, 'Missing query');
      return;
    }
    
    Map<String, dynamic> variables = payload['variables'];
    Map<String, dynamic> context = {
      'websocket': webSocket
    };
    
    try {
      // 执行订阅
      Map<String, dynamic> result = await executor.execute(
        query,
        variables: variables,
        context: context
      );
      
      // 检查结果是否是 Stream
      if (result['data'] != null) {
        for (var entry in result['data'].entries) {
          String fieldName = entry.key;
          dynamic fieldResult = entry.value;
          
          if (fieldResult is Stream) {
            // 处理 Stream 类型的结果
            StreamSubscription subscription = fieldResult.listen(
              (data) {
                _sendData(webSocket, id, {fieldName: data});
              },
              onError: (error) {
                _sendError(webSocket, id, error.toString());
              },
              onDone: () {
                _sendComplete(webSocket, id);
              }
            );
            
            // 保存订阅
            _subscriptions[id] = subscription;
          } else {
            // 处理非 Stream 类型的结果
            _sendData(webSocket, id, {fieldName: fieldResult});
            _sendComplete(webSocket, id);
          }
        }
      }
    } catch (e) {
      _sendError(webSocket, id, e.toString());
    }
  }
  
  /// 处理订阅停止
  void _handleStop(WebSocket webSocket, Map<String, dynamic> request) {
    String id = request['id'];
    if (id == null) {
      _sendError(webSocket, null, 'Missing subscription id');
      return;
    }
    
    // 取消订阅
    StreamSubscription subscription = _subscriptions.remove(id);
    if (subscription != null) {
      subscription.cancel();
    }
  }
  
  /// 处理连接终止
  void _handleConnectionTerminate(WebSocket webSocket) {
    // 关闭连接
    webSocket.close();
    _handleDisconnect();
  }
  
  /// 处理连接断开
  void _handleDisconnect() {
    // 取消所有订阅
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
  
  /// 发送数据消息
  void _sendData(WebSocket webSocket, String id, dynamic data) {
    Map<String, dynamic> message = {
      'id': id,
      'type': 'data',
      'payload': {
        'data': data
      }
    };
    _sendMessage(webSocket, message);
  }
  
  /// 发送错误消息
  void _sendError(WebSocket webSocket, String id, String message) {
    Map<String, dynamic> errorMessage = {
      'id': id,
      'type': 'error',
      'payload': {
        'errors': [
          {
            'message': message
          }
        ]
      }
    };
    _sendMessage(webSocket, errorMessage);
  }
  
  /// 发送完成消息
  void _sendComplete(WebSocket webSocket, String id) {
    Map<String, dynamic> completeMessage = {
      'id': id,
      'type': 'complete'
    };
    _sendMessage(webSocket, completeMessage);
  }
  
  /// 发送消息
  void _sendMessage(WebSocket webSocket, Map<String, dynamic> message) {
    try {
      webSocket.add(jsonEncode(message));
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
