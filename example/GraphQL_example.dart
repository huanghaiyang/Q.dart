import 'dart:io';
import 'dart:async';
import 'package:Q/Q.dart';
import 'package:Q/src/graphql/GraphQLSchema.dart';
import 'package:Q/src/graphql/GraphQLType.dart';
import 'package:Q/src/graphql/GraphQLField.dart';
import 'package:Q/src/graphql/GraphQLArgument.dart';
import 'package:Q/src/graphql/GraphQLHandler.dart';
import 'package:Q/src/graphql/annotations/GraphQL.dart';

// 定义用户数据模型
@GraphQLType(name: 'User')
class UserModel {
  @GraphQLField(name: 'id', type: 'ID')
  String id;
  
  @GraphQLField(name: 'name', type: 'String')
  String name;
  
  @GraphQLField(name: 'email', type: 'String')
  String email;
  
  @GraphQLField(name: 'age', type: 'Int')
  int age;
  
  @GraphQLField(name: 'createdAt', type: 'String')
  String createdAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.age,
    this.createdAt,
  });
}

// 模拟用户数据库
class UserDatabase {
  static final Map<String, UserModel> _users = {
    '1': UserModel(
      id: '1',
      name: 'Alice',
      email: 'alice@example.com',
      age: 25,
      createdAt: DateTime.now().toIso8601String(),
    ),
    '2': UserModel(
      id: '2',
      name: 'Bob',
      email: 'bob@example.com',
      age: 30,
      createdAt: DateTime.now().toIso8601String(),
    ),
    '3': UserModel(
      id: '3',
      name: 'Charlie',
      email: 'charlie@example.com',
      age: 35,
      createdAt: DateTime.now().toIso8601String(),
    ),
  };

  static List<UserModel> get allUsers => _users.values.toList();

  static UserModel getById(String id) => _users[id];

  static UserModel create(UserModel user) {
    String id = '${_users.length + 1}';
    UserModel newUser = UserModel(
      id: id,
      name: user.name,
      email: user.email,
      age: user.age,
      createdAt: DateTime.now().toIso8601String(),
    );
    _users[id] = newUser;
    return newUser;
  }

  static UserModel update(String id, UserModel user) {
    if (_users.containsKey(id)) {
      UserModel updatedUser = UserModel(
        id: id,
        name: user.name ?? _users[id].name,
        email: user.email ?? _users[id].email,
        age: user.age ?? _users[id].age,
        createdAt: _users[id].createdAt,
      );
      _users[id] = updatedUser;
      return updatedUser;
    }
    return null;
  }

  static bool delete(String id) {
    return _users.remove(id) != null;
  }
}

// 定义查询解析器
@GraphQLType(name: 'Query')
class QueryResolver {


  // 异步查询方法 - 获取单个用户
  @Query(name: 'user')
  Future<UserModel> user(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    // 模拟异步操作
    await Future.delayed(Duration(milliseconds: 50));
    
    String id = args['id'];
    return UserDatabase.getById(id);
  }

  // 异步查询方法 - 获取所有用户
  @Query(name: 'users')
  Future<List<UserModel>> users(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    // 模拟异步操作
    await Future.delayed(Duration(milliseconds: 100));
    
    return UserDatabase.allUsers;
  }

  // 异步查询方法 - 根据年龄筛选用户
  @Query(name: 'usersByAge')
  Future<List<UserModel>> usersByAge(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    // 模拟异步操作
    await Future.delayed(Duration(milliseconds: 100));
    
    int age = args['age'];
    return UserDatabase.allUsers.where((user) => user.age == age).toList();
  }
}

// 定义变更解析器
@GraphQLType(name: 'Mutation')
class MutationResolver {
  // 异步变更方法 - 创建用户
  @Mutation(name: 'createUser')
  Future<UserModel> createUser(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    // 模拟异步操作
    await Future.delayed(Duration(milliseconds: 150));
    
    UserModel user = UserModel(
      name: args['name'],
      email: args['email'],
      age: args['age'],
    );
    return UserDatabase.create(user);
  }

  // 异步变更方法 - 更新用户
  @Mutation(name: 'updateUser')
  Future<UserModel> updateUser(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    // 模拟异步操作
    await Future.delayed(Duration(milliseconds: 100));
    
    String id = args['id'];
    UserModel user = UserModel(
      name: args['name'],
      email: args['email'],
      age: args['age'],
    );
    return UserDatabase.update(id, user);
  }

  // 异步变更方法 - 删除用户
  @Mutation(name: 'deleteUser')
  Future<bool> deleteUser(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    // 模拟异步操作
    await Future.delayed(Duration(milliseconds: 50));
    
    String id = args['id'];
    return UserDatabase.delete(id);
  }
}

// 定义订阅解析器
@GraphQLType(name: 'Subscription')
class SubscriptionResolver {
  // 用户创建订阅
  @Subscription(name: 'userCreated')
  Stream<UserModel> userCreated(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) {
    // 模拟用户创建事件流
    return Stream.periodic(Duration(seconds: 5), (i) {
      UserModel user = UserModel(
        id: '${UserDatabase.allUsers.length + 1}',
        name: 'New User $i',
        email: 'newuser$i@example.com',
        age: 20 + i,
        createdAt: DateTime.now().toIso8601String(),
      );
      return user;
    }).take(5);
  }

  // 用户更新订阅
  @Subscription(name: 'userUpdated')
  Stream<UserModel> userUpdated(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) {
    // 模拟用户更新事件流
    return Stream.periodic(Duration(seconds: 3), (i) {
      String id = '${(i % 3) + 1}';
      UserModel user = UserDatabase.getById(id);
      if (user != null) {
        user.name = 'Updated User ${user.id}';
        return user;
      }
      return null;
    }).take(5);
  }

  // 倒计时订阅
  @Subscription(name: 'countdown')
  Stream<int> countdown(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) {
    int seconds = args['seconds'] ?? 10;
    return Stream.periodic(Duration(seconds: 1), (i) => seconds - i - 1)
        .take(seconds);
  }
}

void main() {
  Application app = Application();
  app.init();

  // 从数据模型生成 GraphQL 类型
  GraphQLObjectType userType = GraphQLSchema.fromModel(UserModel);

  // 创建 GraphQL Schema
  GraphQLSchema schema = GraphQLSchema(
    types: {
      'User': userType,
      'Query': GraphQLObjectType(
        'Query',
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
        },
      ),
      'Mutation': GraphQLObjectType(
        'Mutation',
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
      'Subscription': GraphQLObjectType(
        'Subscription',
        fields: {
          'userCreated': GraphQLField(
            name: 'userCreated',
            type: 'User',
          ),
          'userUpdated': GraphQLField(
            name: 'userUpdated',
            type: 'User',
          ),
          'countdown': GraphQLField(
            name: 'countdown',
            type: 'Int',
            arguments: {
              'seconds': GraphQLArgument(
                name: 'seconds',
                type: 'Int',
                defaultValue: 10,
              ),
            },
          ),
        },
      ),
    },
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
    subscription: GraphQLField(
      name: 'Subscription',
      fields: {
        'userCreated': GraphQLField(
          name: 'userCreated',
          type: 'User',
        ),
        'userUpdated': GraphQLField(
          name: 'userUpdated',
          type: 'User',
        ),
        'countdown': GraphQLField(
          name: 'countdown',
          type: 'Int',
          arguments: {
            'seconds': GraphQLArgument(
              name: 'seconds',
              type: 'Int',
              defaultValue: 10,
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
    QueryResolver,
    MutationResolver,
    SubscriptionResolver,
  ]);

  // 注册 GraphQL 端点
  app.post('/graphql', graphqlHandler.handle);

  // 启动服务器
  app.listen(8080);
  print('GraphQL server started on port 8080');
  print('GraphQL endpoint: http://localhost:8080/graphql');
  print('');
  print('=== GraphQL Example ===');
  print('');
  print('Query Examples:');
  print('');
  print('1. Get single user:');
  print('{');
  print('  user(id: "1") {');
  print('    id');
  print('    name');
  print('    email');
  print('    age');
  print('    createdAt');
  print('  }');
  print('}');
  print('');
  print('3. Get all users:');
  print('{');
  print('  users {');
  print('    id');
  print('    name');
  print('    email');
  print('    age');
  print('  }');
  print('}');
  print('');
  print('4. Get users by age:');
  print('{');
  print('  usersByAge(age: 30) {');
  print('    id');
  print('    name');
  print('    email');
  print('  }');
  print('}');
  print('');
  print('Mutation Examples:');
  print('');
  print('1. Create user:');
  print('mutation {');
  print('  createUser(name: "David", email: "david@example.com", age: 28) {');
  print('    id');
  print('    name');
  print('    email');
  print('    age');
  print('    createdAt');
  print('  }');
  print('}');
  print('');
  print('2. Update user:');
  print('mutation {');
  print('  updateUser(id: "1", name: "Alice Smith", age: 26) {');
  print('    id');
  print('    name');
  print('    email');
  print('    age');
  print('  }');
  print('}');
  print('');
  print('3. Delete user:');
  print('mutation {');
  print('  deleteUser(id: "3")');
  print('}');
  print('');
  print('Subscription Examples:');
  print('');
  print('1. Subscribe to user created events:');
  print('subscription {');
  print('  userCreated {');
  print('    id');
  print('    name');
  print('    email');
  print('  }');
  print('}');
  print('');
  print('2. Subscribe to user updated events:');
  print('subscription {');
  print('  userUpdated {');
  print('    id');
  print('    name');
  print('    email');
  print('  }');
  print('}');
  print('');
  print('3. Countdown subscription:');
  print('subscription {');
  print('  countdown(seconds: 5)');
  print('}');
  print('');
  print('Generated User Type:');
  print(userType.toSDL());
}

