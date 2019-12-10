import 'package:Q/Q.dart';
import 'package:Q/src/helpers/reflect/ClassTransformer.dart';
import 'package:test/test.dart';

@Model({'name': String, 'int': int, 'age': num, 'friends': List, 'alias': List})
class Person {
  int id;
  String name;
  num age;
  List<Person> friends;
  List<String> alias;
}

void main() {
  group('ClassTransformer tests', () {
    test('verify', () async {
      Person spiderMan = Person();
      spiderMan.name = 'peter';

      dynamic result = await ClassTransformer.fromMap({"name": "peter"}, Person);
      if (result is Person) {
        expect(result.name, spiderMan.name);
      }
    });
  });
}
