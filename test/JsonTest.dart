import 'dart:convert';

import 'package:test/test.dart';

void main() {
  group('Json tests', () {
    test('verify json decode', () {
      expect(jsonDecode('{"name":"peter"}'), {'name': 'peter'});
    });
  });
}
