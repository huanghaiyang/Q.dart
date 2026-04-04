import 'dart:async';

import 'DatabaseConnectionPool.dart';

/// Repository 基础接口
/// 提供基本的 CRUD 操作
abstract class Repository<T> {
  /// 根据主键查找实体
  /// 
  /// [id] 主键值
  /// 
  /// 返回实体对象，如果不存在则返回 null
  Future<T> findById(dynamic id);

  /// 查找所有实体
  /// 
  /// 返回实体列表
  Future<List<T>> findAll();

  /// 根据条件查找实体
  /// 
  /// [where] WHERE 条件
  /// [params] 查询参数
  /// [orderBy] 排序字段
  /// [limit] 限制数量
  /// [offset] 偏移量
  /// 
  /// 返回实体列表
  Future<List<T>> findWhere({
    String where,
    List<dynamic> params,
    String orderBy,
    int limit,
    int offset,
  });

  /// 保存实体（插入或更新）
  /// 
  /// [entity] 要保存的实体
  /// 
  /// 返回保存后的实体
  Future<T> save(T entity);

  /// 插入实体
  /// 
  /// [entity] 要插入的实体
  /// 
  /// 返回插入后的实体
  Future<T> insert(T entity);

  /// 更新实体
  /// 
  /// [entity] 要更新的实体
  /// 
  /// 返回更新后的实体
  Future<T> update(T entity);

  /// 删除实体
  /// 
  /// [entity] 要删除的实体
  /// 
  /// 返回是否删除成功
  Future<bool> delete(T entity);

  /// 根据主键删除实体
  /// 
  /// [id] 主键值
  /// 
  /// 返回是否删除成功
  Future<bool> deleteById(dynamic id);

  /// 批量删除
  /// 
  /// [where] WHERE 条件
  /// [params] 查询参数
  /// 
  /// 返回删除的行数
  Future<int> deleteWhere({
    String where,
    List<dynamic> params,
  });

  /// 统计实体数量
  /// 
  /// [where] WHERE 条件
  /// [params] 查询参数
  /// 
  /// 返回实体数量
  Future<int> count({
    String where,
    List<dynamic> params,
  });

  /// 检查实体是否存在
  /// 
  /// [where] WHERE 条件
  /// [params] 查询参数
  /// 
  /// 返回是否存在
  Future<bool> exists({
    String where,
    List<dynamic> params,
  });
}

/// Repository 基础实现
abstract class BaseRepository<T> implements Repository<T> {
  final DatabaseConnectionPool _connectionPool;
  final String _tableName;
  final String _primaryKey;
  
  BaseRepository({
    DatabaseConnectionPool connectionPool,
    String tableName,
    String primaryKey = 'id',
  }) : _connectionPool = connectionPool,
       _tableName = tableName,
       _primaryKey = primaryKey;

  @override
  Future<T> findById(dynamic id) async {
    final results = await _connectionPool.query(
      'SELECT * FROM $_tableName WHERE $_primaryKey = ?',
      params: [id],
    );
    
    if (results.isEmpty) {
      return null;
    }
    
    return _mapToEntity(results.first);
  }

  @override
  Future<List<T>> findAll() async {
    final results = await _connectionPool.query('SELECT * FROM $_tableName');
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<List<T>> findWhere({
    String where,
    List<dynamic> params,
    String orderBy,
    int limit,
    int offset,
  }) async {
    String sql = 'SELECT * FROM $_tableName';
    List<dynamic> queryParams = [];
    
    if (where != null && where.isNotEmpty) {
      sql += ' WHERE $where';
      if (params != null) {
        queryParams.addAll(params);
      }
    }
    
    if (orderBy != null && orderBy.isNotEmpty) {
      sql += ' ORDER BY $orderBy';
    }
    
    if (limit != null) {
      sql += ' LIMIT $limit';
    }
    
    if (offset != null) {
      sql += ' OFFSET $offset';
    }
    
    final results = await _connectionPool.query(sql, params: queryParams);
    return results.map(_mapToEntity).toList();
  }

  @override
  Future<T> save(T entity) async {
    final id = _getIdValue(entity);
    
    if (id == null) {
      return await insert(entity);
    } else {
      return await update(entity);
    }
  }

  @override
  Future<T> insert(T entity) async {
    final data = _entityToMap(entity);
    final columns = data.keys.join(', ');
    final placeholders = List.filled(data.length, '?').join(', ');
    final values = data.values.toList();
    
    final id = await _connectionPool.insert(
      'INSERT INTO $_tableName ($columns) VALUES ($placeholders)',
      params: values,
    );
    
    _setIdValue(entity, id);
    return entity;
  }

  @override
  Future<T> update(T entity) async {
    final id = _getIdValue(entity);
    if (id == null) {
      throw Exception('Cannot update entity without ID');
    }
    
    final data = _entityToMap(entity);
    final setClause = data.keys.map((key) => '$key = ?').join(', ');
    final values = [...data.values.toList(), id];
    
    await _connectionPool.execute(
      'UPDATE $_tableName SET $setClause WHERE $_primaryKey = ?',
      params: values,
    );
    
    return entity;
  }

  @override
  Future<bool> delete(T entity) async {
    final id = _getIdValue(entity);
    if (id == null) {
      throw Exception('Cannot delete entity without ID');
    }
    
    return await deleteById(id);
  }

  @override
  Future<bool> deleteById(dynamic id) async {
    final result = await _connectionPool.execute(
      'DELETE FROM $_tableName WHERE $_primaryKey = ?',
      params: [id],
    );
    
    return result > 0;
  }

  @override
  Future<int> deleteWhere({
    String where,
    List<dynamic> params,
  }) async {
    String sql = 'DELETE FROM $_tableName';
    List<dynamic> queryParams = [];
    
    if (where != null && where.isNotEmpty) {
      sql += ' WHERE $where';
      if (params != null) {
        queryParams.addAll(params);
      }
    }
    
    return await _connectionPool.execute(sql, params: queryParams);
  }

  @override
  Future<int> count({
    String where,
    List<dynamic> params,
  }) async {
    String sql = 'SELECT COUNT(*) as count FROM $_tableName';
    List<dynamic> queryParams = [];
    
    if (where != null && where.isNotEmpty) {
      sql += ' WHERE $where';
      if (params != null) {
        queryParams.addAll(params);
      }
    }
    
    final results = await _connectionPool.query(sql, params: queryParams);
    return (results.first['count'] as int);
  }

  @override
  Future<bool> exists({
    String where,
    List<dynamic> params,
  }) async {
    final count = await this.count(where: where, params: params);
    return count > 0;
  }

  /// 将数据库记录映射为实体对象
  /// 
  /// [record] 数据库记录
  /// 
  /// 返回实体对象
  T _mapToEntity(Map<String, dynamic> record);

  /// 将实体对象映射为数据库记录
  /// 
  /// [entity] 实体对象
  /// 
  /// 返回数据库记录
  Map<String, dynamic> _entityToMap(T entity);

  /// 获取实体的主键值
  /// 
  /// [entity] 实体对象
  /// 
  /// 返回主键值
  dynamic _getIdValue(T entity);

  /// 设置实体的主键值
  /// 
  /// [entity] 实体对象
  /// [id] 主键值
  void _setIdValue(T entity, dynamic id);
}
