import 'dart:io';
import 'package:Q/Q.dart';
import 'package:Q/src/graphql/GraphQLSchema.dart';
import 'package:Q/src/graphql/GraphQLType.dart';
import 'package:Q/src/graphql/GraphQLField.dart';
import 'package:Q/src/graphql/GraphQLArgument.dart';
import 'package:Q/src/graphql/GraphQLHandler.dart';
import 'package:Q/src/graphql/annotations/GraphQL.dart';
import 'package:Q/src/database/Database.dart';
import 'package:Q/src/database/DatabaseConnectionPoolImpl.dart';
import 'package:Q/src/database/SqliteConnection.dart';
import 'package:Q/src/graphql/adapter/GraphQLDatabaseAdapter.dart';

// 定义用户实体
class User {
  int id;
  String name;
  String email;
  int age;
  String createdAt;

  User({this.id, this.name, this.email, this.age, this.createdAt});
}

// 定义用户仓库
class UserRepository extends BaseRepository<User> {
  UserRepository(DatabaseConnectionPool connectionPool) : 
    super(
      connectionPool: connectionPool,
      tableName: 'users',
      primaryKey: 'id'
    );

  @override
  User _mapToEntity(Map<String, dynamic> record) {
    return User(
      id: record['id'],
      name: record['name'],
      email: record['email'],
      age: record['age'],
      createdAt: record['created_at'],
    );
  }

  @override
  Map<String, dynamic> _entityToMap(User entity) {
    return {
      'name': entity.name,
      'email': entity.email,
      'age': entity.age,
      'created_at': entity.createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  @override
  dynamic _getIdValue(User entity) {
    return entity.id;
  }

  @override
  void _setIdValue(User entity, dynamic id) {
    entity.id = id;
  }
}

// 定义 GraphQL 类型
@GraphQLType(name: 'User')
class UserType {
  @GraphQLField(name: 'id', type: 'ID')
  int id;
  
  @GraphQLField(name: 'name', type: 'String')
  String name;
  
  @GraphQLField(name: 'email', type: 'String')
  String email;
  
  @GraphQLField(name: 'age', type: 'Int')
  int age;
  
  @GraphQLField(name: 'createdAt', type: 'String')
  String createdAt;
}

// 定义查询解析器
@GraphQLType(name: 'Query')
class QueryResolver {
  GraphQLDatabaseAdapter _adapter;
  
  QueryResolver(this._adapter);
  
  // 获取单个用户
  @Query(name: 'user')
  Future<User> user(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    return await _adapter.executeQuery<User>('findById', {'id': args['id']});
  }

  // 获取所有用户
  @Query(name: 'users')
  Future<List<User>> users(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    return await _adapter.executeQuery<User>('findAll', {});
  }

  // 根据年龄获取用户
  @Query(name: 'usersByAge')
  Future<List<User>> usersByAge(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    return await _adapter.executeQuery<User>('findWhere', {
      'where': 'age = ?',
      'params': [args['age']],
    });
  }

  // 统计用户数量
  @Query(name: 'userCount')
  Future<int> userCount(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    return await _adapter.executeQuery<User>('count', {});
  }
}

// 定义变更解析器
@GraphQLType(name: 'Mutation')
class MutationResolver {
  GraphQLDatabaseAdapter _adapter;
  
  MutationResolver(this._adapter);
  
  // 创建用户
  @Mutation(name: 'createUser')
  Future<User> createUser(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    User user = User(
      name: args['name'],
      email: args['email'],
      age: args['age'],
      createdAt: DateTime.now().toIso8601String(),
    );
    return await _adapter.executeMutation<User>('insert', {'entity': user});
  }

  // 更新用户
  @Mutation(name: 'updateUser')
  Future<User> updateUser(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    User user = User(
      id: args['id'],
      name: args['name'],
      email: args['email'],
      age: args['age'],
      createdAt: args['createdAt'],
    );
    return await _adapter.executeMutation<User>('update', {'entity': user});
  }

  // 删除用户
  @Mutation(name: 'deleteUser')
  Future<bool> deleteUser(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    return await _adapter.executeMutation<User>('deleteById', {'id': args['id']});
  }
}

// 初始化数据库
Future<void> initDatabase(DatabaseConnectionPool connectionPool) async {
  // 创建用户表
  await connectionPool.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      age INTEGER,
      created_at TEXT NOT NULL
    )
  ''');
  
  // 插入测试数据
  await connectionPool.execute('''
    INSERT OR IGNORE INTO users (name, email, age, created_at) VALUES
    ('Alice', 'alice@example.com', 25, '2024-01-01T00:00:00Z'),
    ('Bob', 'bob@example.com', 30, '2024-01-02T00:00:00Z'),
    ('Charlie', 'charlie@example.com', 35, '2024-01-03T00:00:00Z')
  ''');
}

void main() async {
  Application app = Application();
  app.init();

  // 创建数据库连接池
  DatabaseConnectionPool connectionPool = DatabaseConnectionPoolImpl(
    factory: () => SqliteConnection('test.db'),
    size: 5,
  );
  
  // 初始化数据库
  await initDatabase(connectionPool);

  // 创建数据库适配层
  GraphQLDatabaseAdapter adapter = GraphQLDatabaseAdapter(connectionPool);
  
  // 注册仓库
  adapter.registerRepository<User>(UserRepository(connectionPool));

  // 创建类型映射
  Map<String, GraphQLType> types = {};
  
  // 从数据模型生成 GraphQL 类型
  GraphQLObjectType userType = GraphQLSchema.fromModel(UserType, types: types);

  // 创建 GraphQL Schema
  GraphQLSchema schema = GraphQLSchema(
    types: types,
    query: GraphQLField(
      name: 'Query',
      fields: {
        'user': GraphQLField(
          name: 'user',
          type: 'User',
          arguments: {
            'id': GraphQLArgument(
              name: 'id',
              type: 'ID',
            ),
          },
        ),
        'users': GraphQLField(
          name: 'users',
          type: '[User]',
        ),
        'usersByAge': GraphQLField(
          name: 'usersByAge',
          type: '[User]',
          arguments: {
            'age': GraphQLArgument(
              name: 'age',
              type: 'Int',
            ),
          },
        ),
        'userCount': GraphQLField(
          name: 'userCount',
          type: 'Int',
        ),
      },
    ),
    mutation: GraphQLField(
      name: 'Mutation',
      fields: {
        'createUser': GraphQLField(
          name: 'createUser',
          type: 'User',
          arguments: {
            'name': GraphQLArgument(
              name: 'name',
              type: 'String',
            ),
            'email': GraphQLArgument(
              name: 'email',
              type: 'String',
            ),
            'age': GraphQLArgument(
              name: 'age',
              type: 'Int',
            ),
          },
        ),
        'updateUser': GraphQLField(
          name: 'updateUser',
          type: 'User',
          arguments: {
            'id': GraphQLArgument(
              name: 'id',
              type: 'ID',
            ),
            'name': GraphQLArgument(
              name: 'name',
              type: 'String',
            ),
            'email': GraphQLArgument(
              name: 'email',
              type: 'String',
            ),
            'age': GraphQLArgument(
              name: 'age',
              type: 'Int',
            ),
            'createdAt': GraphQLArgument(
              name: 'createdAt',
              type: 'String',
            ),
          },
        ),
        'deleteUser': GraphQLField(
          name: 'deleteUser',
          type: 'Boolean',
          arguments: {
            'id': GraphQLArgument(
              name: 'id',
              type: 'ID',
            ),
          },
        ),
      },
    ),
  );

  // 创建 GraphQL 处理器
  GraphQLHandler graphqlHandler = GraphQLHandler(
    schema: schema,
  );
  
  // 扫描带有 GraphQL 注解的类
  graphqlHandler.scanTypes([
    QueryResolver(adapter),
    MutationResolver(adapter),
  ]);

  // 注册 GraphQL 端点
  app.post('/graphql', graphqlHandler.handle);

  // 启动服务器
  app.listen(8080);
  print('GraphQL server started on port 8080');
  print('GraphQL endpoint: http://localhost:8080/graphql');
  print('');
  print('=== Database Example ===');
  print('');
  print('Query Example:');
  print('{');
  print('  user(id: 1) {');
  print('    id');
  print('    name');
  print('    email');
  print('    age');
  print('    createdAt');
  print('  }');
  print('}');
  print('');
  print('Mutation Example:');
  print('mutation {');
  print('  createUser(name: "David", email: "david@example.com", age: 28) {');
  print('    id');
  print('    name');
  print('    email');
  print('    age');
  print('    createdAt');
  print('  }');
  print('}');
}
