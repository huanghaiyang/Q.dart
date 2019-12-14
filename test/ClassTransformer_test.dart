import 'package:Q/Q.dart';
import 'package:Q/src/helpers/reflect/ClassTransformer.dart';
import 'package:test/test.dart';

Person createPerson(String name, int id, int age, List<Person> friends, {List<String> nicknames, List<Person> girlFriends}) {
  return Person._(name: name, id: id, age: age, friends: friends, nicknames: nicknames, girlFriends: girlFriends);
}

//@Model({'name': String, 'int': int, 'age': num, 'friends': List, 'nicknames': List})
@SideEffectModel(createPerson)
class Person {
  int id;
  String name;
  num age;
  List<Person> friends;
  List<String> nicknames;
  List<Person> girlFriends;

  Person._({this.name, this.id, this.age, this.friends, this.nicknames, this.girlFriends});
}

void main() {
  group('ClassTransformer tests', () {
    test('verify', () async {
      Person spiderMan = Person._(name: 'peter');

      dynamic result = await ClassTransformer.fromMap({
        "name": "peter",
        "id": 10,
        "age": 17,
        "friends": [
          {"id": 0, "name": "iron man"},
          {"id": 1, "name": "thor"}
        ],
        "nicknames": ["spider", "kid", 'monkey man'],
        "girlFriends": [
          {"id": 11, "name": "spider girl"}
        ]
      }, Person);
      if (result is Person) {
        expect(result.name, spiderMan.name);
      }
    });
  });
}
