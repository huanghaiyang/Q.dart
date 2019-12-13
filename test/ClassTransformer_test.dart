import 'package:Q/Q.dart';
import 'package:Q/src/helpers/reflect/ClassTransformer.dart';
import 'package:test/test.dart';

Future<Person> createPerson(String name, int id, int age, List<Person> friends, List<String> nicknames) async {
  return Person._(name: name, id: id, age: age, friends: friends, nicknames: nicknames);
}

@Model({'name': String, 'int': int, 'age': num, 'friends': List, 'nicknames': List})
@SideEffectModel(createPerson)
class Person {
  int id;
  String name;
  num age;
  List<Person> friends;
  List<String> nicknames;

  Person._({this.name, this.id, this.age, this.friends, this.nicknames});
}

void main() {
  group('ClassTransformer tests', () {
    test('verify', () async {
      Person spiderMan = Person._(name: 'peter');

      dynamic result = await ClassTransformer.fromMap({"name": "peter"}, Person);
      if (result is Person) {
        expect(result.name, spiderMan.name);
      }
    });
  });
}
