import 'package:test/test.dart';
import 'package:Q/src/graphql/GraphQLHandler.dart';
import 'package:Q/src/graphql/GraphQLSchema.dart';

void main() {
  group('GraphQL Query Structure Validation', () {
    GraphQLHandler handler;
    
    setUp(() {
      // 创建一个简单的 GraphQL Schema
      GraphQLSchema schema = GraphQLSchema(
        types: {
          'Query': GraphQLObjectType(
            'Query',
            fields: {
              'hello': GraphQLField(
                name: 'hello',
                type: 'String',
              ),
            },
          ),
        },
        query: GraphQLField(
          name: 'Query',
          fields: {
            'hello': GraphQLField(
              name: 'hello',
              type: 'String',
            ),
          },
        ),
      );
      
      // 创建 GraphQL 处理器
      handler = GraphQLHandler(schema: schema);
    });
    
    test('Valid query should pass validation', () {
      String validQuery = '''
        query {
          hello
        }
      ''';
      expect(() => handler._validateQuery(validQuery), returnsNormally);
    });
    
    test('Query with unmatched opening brace should throw error', () {
      String invalidQuery = '''
        query {
          hello
        
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with unmatched closing brace should throw error', () {
      String invalidQuery = '''
        query {
          hello
        }
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with unmatched opening parenthesis should throw error', () {
      String invalidQuery = '''
        query {
          hello(
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with unmatched closing parenthesis should throw error', () {
      String invalidQuery = '''
        query {
          hello)
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with unmatched opening bracket should throw error', () {
      String invalidQuery = '''
        query {
          hello[
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with unmatched closing bracket should throw error', () {
      String invalidQuery = '''
        query {
          hello]
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with unmatched single quote should throw error', () {
      String invalidQuery = '''
        query {
          hello(name: 'test
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with unmatched double quote should throw error', () {
      String invalidQuery = '''
        query {
          hello(name: "test
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query without operation type should throw error', () {
      String invalidQuery = '''
        {
          hello
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with reserved keyword as field name should throw error', () {
      String invalidQuery = '''
        query {
          query
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with reserved keyword as argument name should throw error', () {
      String invalidQuery = '''
        query {
          hello(query: "test")
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with dangerous keyword should throw error', () {
      String invalidQuery = '''
        query {
          hello(name: "DROP TABLE users")
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with too deep nesting should throw error', () {
      String invalidQuery = '''
        query {
          hello {
            hello {
              hello {
                hello {
                  hello {
                    hello {
                      hello {
                        hello {
                          hello {
                            hello
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      ''';
      expect(() => handler._validateQuery(invalidQuery), throwsArgumentError);
    });
    
    test('Query with too long length should throw error', () {
      String longQuery = 'query { ' + 'hello ' * 10000 + '}';
      expect(() => handler._validateQuery(longQuery), throwsArgumentError);
    });
  });
}
