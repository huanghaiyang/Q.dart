import 'dart:async';
import 'package:Q/src/database/Repository.dart';
import 'package:Q/src/database/DatabaseConnectionPool.dart';

/// GraphQL 数据库适配层
/// 用于连接 GraphQL 解析器和数据库操作
class GraphQLDatabaseAdapter {
  /// 数据库连接池
  final DatabaseConnectionPool connectionPool;
  
  /// 仓库映射
  final Map<Type, Repository> _repositories = {};
  
  /// 构造函数
  GraphQLDatabaseAdapter(this.connectionPool);
  
  /// 注册仓库
  void registerRepository<T>(Repository<T> repository) {
    _repositories[T] = repository;
  }
  
  /// 获取仓库
  Repository<T> getRepository<T>() {
    if (!_repositories.containsKey(T)) {
      throw Exception('Repository for type $T not registered');
    }
    return _repositories[T] as Repository<T>;
  }
  
  /// 执行查询操作
  Future<dynamic> executeQuery<T>(String fieldName, Map<String, dynamic> args) async {
    Repository<T> repository = getRepository<T>();
    
    switch (fieldName) {
      case 'findById':
        return await repository.findById(args['id']);
      case 'findAll':
        return await repository.findAll();
      case 'findWhere':
        return await repository.findWhere(
          where: args['where'],
          params: args['params'],
          orderBy: args['orderBy'],
          limit: args['limit'],
          offset: args['offset'],
        );
      case 'count':
        return await repository.count(
          where: args['where'],
          params: args['params'],
        );
      case 'exists':
        return await repository.exists(
          where: args['where'],
          params: args['params'],
        );
      default:
        throw Exception('Unknown query field: $fieldName');
    }
  }
  
  /// 执行变更操作
  Future<dynamic> executeMutation<T>(String fieldName, Map<String, dynamic> args) async {
    Repository<T> repository = getRepository<T>();
    
    switch (fieldName) {
      case 'save':
        return await repository.save(args['entity']);
      case 'insert':
        return await repository.insert(args['entity']);
      case 'update':
        return await repository.update(args['entity']);
      case 'delete':
        return await repository.delete(args['entity']);
      case 'deleteById':
        return await repository.deleteById(args['id']);
      case 'deleteWhere':
        return await repository.deleteWhere(
          where: args['where'],
          params: args['params'],
        );
      default:
        throw Exception('Unknown mutation field: $fieldName');
    }
  }
  
  /// 关闭连接池
  Future<void> close() async {
    await connectionPool.close();
  }
}
