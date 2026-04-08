import 'package:test/test.dart';
import 'package:Q/src/graphql/GraphQLType.dart';
import 'package:Q/src/graphql/GraphQLField.dart';
import 'package:Q/src/graphql/GraphQLArgument.dart';

void main() {
  group('GraphQL SDL Security', () {
    test('GraphQLType name validation', () {
      // 测试有效名称
      expect(() => GraphQLObjectType('ValidType'), returnsNormally);
      expect(() => GraphQLObjectType('valid_type_123'), returnsNormally);
      
      // 测试无效名称 - 实现会在构造函数中自动清理，所以这些不会抛出异常
      // 而是会被清理为有效的名称
      expect(() => GraphQLObjectType(null), throwsArgumentError);
      
      // 空字符串会被自动清理为 Type_
      GraphQLObjectType emptyType = GraphQLObjectType('');
      expect(emptyType.name, equals('Type_'));
      
      // 这些名称会被自动清理
      GraphQLObjectType type1 = GraphQLObjectType('123Type');
      expect(type1.name, startsWith('Type_'));
      
      GraphQLObjectType type2 = GraphQLObjectType('Type-With-Dash');
      expect(type2.name, equals('Type_With_Dash'));
      
      GraphQLObjectType type3 = GraphQLObjectType('Type@With@Special@Chars');
      expect(type3.name, equals('Type_With_Special_Chars'));
    });
    
    test('GraphQLType name sanitization', () {
      // 测试名称清理
      GraphQLObjectType type1 = GraphQLObjectType('123Type');
      expect(type1.name, startsWith('Type_'));
      
      GraphQLObjectType type2 = GraphQLObjectType('Type-With-Dash');
      expect(type2.name, equals('Type_With_Dash'));
      
      GraphQLObjectType type3 = GraphQLObjectType('Type@With@Special@Chars');
      expect(type3.name, equals('Type_With_Special_Chars'));
    });
    
    test('GraphQLField name validation', () {
      // 测试有效名称
      expect(() => GraphQLField(name: 'validField', type: 'String'), returnsNormally);
      expect(() => GraphQLField(name: '_valid_field_123', type: 'String'), returnsNormally);
      
      // 测试无效名称 - 实现会在构造函数中自动清理，所以这些不会抛出异常
      // 而是会被清理为有效的名称
      GraphQLField field1 = GraphQLField(name: '123field', type: 'String');
      expect(field1.name, startsWith('_'));
      
      GraphQLField field2 = GraphQLField(name: 'field-With-Dash', type: 'String');
      expect(field2.name, equals('field_With_Dash'));
      
      GraphQLField field3 = GraphQLField(name: 'field@With@Special@Chars', type: 'String');
      expect(field3.name, equals('field_With_Special_Chars'));
    });
    
    test('GraphQLArgument name validation', () {
      // 测试有效名称
      expect(() => GraphQLArgument(name: 'validArg', type: 'String'), returnsNormally);
      expect(() => GraphQLArgument(name: '_valid_arg_123', type: 'String'), returnsNormally);
      
      // 测试无效名称 - 实现会在构造函数中自动清理，所以这些不会抛出异常
      // 而是会被清理为有效的名称
      GraphQLArgument arg1 = GraphQLArgument(name: '123arg', type: 'String');
      expect(arg1.name, startsWith('_'));
      
      GraphQLArgument arg2 = GraphQLArgument(name: 'arg-With-Dash', type: 'String');
      expect(arg2.name, equals('arg_With_Dash'));
      
      GraphQLArgument arg3 = GraphQLArgument(name: 'arg@With@Special@Chars', type: 'String');
      expect(arg3.name, equals('arg_With_Special_Chars'));
    });
    
    test('GraphQLArgument string escape', () {
      // 测试字符串转义
      GraphQLArgument arg = GraphQLArgument(
        name: 'testArg', 
        type: 'String', 
        defaultValue: 'test\nwith\r\tspecial\\chars"'
      );
      String sdl = arg.toSDL();
      expect(sdl, contains('"test\\nwith\\r\\tspecial\\\\chars\\""'));
    });
    
    test('SDL generation safety', () {
      // 测试生成安全的 SDL
      GraphQLObjectType type = GraphQLObjectType('TestType', fields: {
        'testField': GraphQLField(
          name: 'testField',
          type: 'String',
          arguments: {
            'testArg': GraphQLArgument(
              name: 'testArg',
              type: 'String',
              defaultValue: 'test\nvalue'
            )
          }
        )
      });
      
      String sdl = type.toSDL();
      expect(sdl, contains('type TestType {'));
      // SDL 输出中换行符被转义为 \n
      expect(sdl, contains('testField(testArg: String = "test\\nvalue"): String'));
      expect(sdl, contains('}'));
    });
  });
}
