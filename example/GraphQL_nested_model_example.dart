import 'dart:io';
import 'dart:async';
import 'package:Q/Q.dart';
import 'package:Q/src/graphql/GraphQLSchema.dart';
import 'package:Q/src/graphql/GraphQLType.dart';
import 'package:Q/src/graphql/GraphQLField.dart';
import 'package:Q/src/graphql/GraphQLArgument.dart';
import 'package:Q/src/graphql/GraphQLHandler.dart';
import 'package:Q/src/graphql/annotations/GraphQL.dart';

// 定义城市模型
@GraphQLType(name: 'City')
class CityModel {
  @GraphQLField(name: 'id', type: 'ID')
  String id;
  
  @GraphQLField(name: 'name', type: 'String')
  String name;
  
  @GraphQLField(name: 'country', type: 'String')
  String country;

  CityModel({this.id, this.name, this.country});
}

// 定义地址模型
@GraphQLType(name: 'Address')
class AddressModel {
  @GraphQLField(name: 'id', type: 'ID')
  String id;
  
  @GraphQLField(name: 'street', type: 'String')
  String street;
  
  @GraphQLField(name: 'city', type: 'City')
  CityModel city;
  
  @GraphQLField(name: 'zipCode', type: 'String')
  String zipCode;

  AddressModel({this.id, this.street, this.city, this.zipCode});
}

// 定义用户模型
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
  
  @GraphQLField(name: 'address', type: 'Address')
  AddressModel address;
  
  @GraphQLField(name: 'createdAt', type: 'String')
  String createdAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.age,
    this.address,
    this.createdAt,
  });
}

// 模拟数据库
class Database {
  // 城市数据
  static final Map<String, CityModel> _cities = {
    '1': CityModel(
      id: '1',
      name: 'New York',
      country: 'USA',
    ),
    '2': CityModel(
      id: '2',
      name: 'London',
      country: 'UK',
    ),
  };

  // 地址数据
  static final Map<String, AddressModel> _addresses = {
    '1': AddressModel(
      id: '1',
      street: '123 Main St',
      city: _cities['1'],
      zipCode: '10001',
    ),
    '2': AddressModel(
      id: '2',
      street: '456 Oxford St',
      city: _cities['2'],
      zipCode: 'SW1A 1AA',
    ),
  };

  // 用户数据
  static final Map<String, UserModel> _users = {
    '1': UserModel(
      id: '1',
      name: 'Alice',
      email: 'alice@example.com',
      age: 25,
      address: _addresses['1'],
      createdAt: DateTime.now().toIso8601String(),
    ),
    '2': UserModel(
      id: '2',
      name: 'Bob',
      email: 'bob@example.com',
      age: 30,
      address: _addresses['2'],
      createdAt: DateTime.now().toIso8601String(),
    ),
  };

  static UserModel getUserById(String id) => _users[id];
  static List<UserModel> getAllUsers() => _users.values.toList();
}

// 定义查询解析器
@GraphQLType(name: 'Query')
class QueryResolver {
  // 获取单个用户
  @Query(name: 'user')
  Future<UserModel> user(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    await Future.delayed(Duration(milliseconds: 50));
    String id = args['id'];
    return Database.getUserById(id);
  }

  // 获取所有用户
  @Query(name: 'users')
  Future<List<UserModel>> users(dynamic parent, Map<String, dynamic> args, Map<String, dynamic> context) async {
    await Future.delayed(Duration(milliseconds: 100));
    return Database.getAllUsers();
  }
}

void main() {
  Application app = Application();
  app.init();

  // 创建类型映射，用于存储所有生成的类型
  Map<String, GraphQLType> types = {};

  // 从数据模型生成 GraphQL 类型（支持多层次嵌套）
  GraphQLObjectType userType = GraphQLSchema.fromModel(UserModel, types: types);

  // 查看生成的所有类型
  print('Generated types:');
  for (var typeName in types.keys) {
    print('--- $typeName ---');
    print(types[typeName].toSDL());
    print('');
  }

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
      },
    ),
  );

  // 创建 GraphQL 处理器
  GraphQLHandler graphqlHandler = GraphQLHandler(
    schema: schema,
  );
  
  // 扫描带有 GraphQL 注解的类
  graphqlHandler.scanTypes([QueryResolver]);

  // 注册 GraphQL 端点
  app.post('/graphql', graphqlHandler.handle);

  // 启动服务器
  app.listen(8080);
  print('GraphQL server started on port 8080');
  print('GraphQL endpoint: http://localhost:8080/graphql');
  print('');
  print('=== Nested Model Example ===');
  print('');
  print('Query Example:');
  print('{');
  print('  user(id: "1") {');
  print('    id');
  print('    name');
  print('    email');
  print('    age');
  print('    address {');
  print('      id');
  print('      street');
  print('      zipCode');
  print('      city {');
  print('        id');
  print('        name');
  print('        country');
  print('      }');
  print('    }');
  print('    createdAt');
  print('  }');
  print('}');
  print('');
  print('{');
  print('  users {');
  print('    id');
  print('    name');
  print('    address {');
  print('      street');
  print('      city {');
  print('        name');
  print('        country');
  print('      }');
  print('    }');
  print('  }');
  print('}');
}
