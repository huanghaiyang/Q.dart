import 'package:Q/Q.dart';
import 'package:test/test.dart';

void main() {
  group('FileUtil tests', () {
    test('verify file name', () {
      expect(getFileName('/a/b/c.dart'), 'c');
      expect(getFileName('a.dart'), 'a');
      expect(getFileName('a/b/c.dart'), 'c');
      expect(getFileName('a'), 'a');
    });

    test('verify file ext', () {
      expect(getPathExtension("a/b/c.dart"), 'dart');
      expect(getPathExtension('c.dart'), 'dart');
    });
  });
}
