import 'package:Q/src/helpers/reflect/ClassTransformer.dart';
import 'package:test/test.dart';

class Person {
  String name;

  Person();

  Person._model(String name) {
    this.name = name;
  }
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
