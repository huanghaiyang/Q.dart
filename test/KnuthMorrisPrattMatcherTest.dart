import 'package:test/test.dart';
import 'package:Q/src/multipart/KnuthMorrisPrattMatcher.dart';

void main() {
  group('KnuthMorrisPrattMatcher', () {
    test('should find single match', () {
      final matcher = KnuthMorrisPrattMatcher.fromString('abc');
      final data = 'xyzabc123'.codeUnits;
      
      final result = matcher.match(data);
      expect(result, 5); // 'abc' ends at index 5
    });

    test('should return -1 when no match', () {
      final matcher = KnuthMorrisPrattMatcher.fromString('abc');
      final data = 'xyz123'.codeUnits;
      
      final result = matcher.match(data);
      expect(result, -1);
    });

    test('should find all matches', () {
      final matcher = KnuthMorrisPrattMatcher.fromString('ab');
      final data = 'ababab'.codeUnits;
      
      final results = matcher.matchAll(data);
      expect(results, [1, 3, 5]);
    });

    test('should handle streaming matching', () {
      final matcher = KnuthMorrisPrattMatcher.fromString('abcd');
      
      // First chunk
      final result1 = matcher.matchStream('xyzab'.codeUnits);
      expect(result1, -1);
      
      // Second chunk completes the match
      final result2 = matcher.matchStream('cd123'.codeUnits);
      expect(result2, 1); // 'cd' completes the match at index 1 of second chunk
    });

    test('should reset state', () {
      final matcher = KnuthMorrisPrattMatcher.fromString('abc');
      
      // First match
      final data1 = 'xyzabc123'.codeUnits;
      final result1 = matcher.match(data1);
      expect(result1, 5);
      
      // Reset and match again
      matcher.reset();
      final data2 = 'anotherabc'.codeUnits;
      final result2 = matcher.match(data2);
      expect(result2, 9);
    });

    test('should handle empty data', () {
      final matcher = KnuthMorrisPrattMatcher.fromString('abc');
      
      final result = matcher.match([]);
      expect(result, -1);
    });

    test('should throw error for empty delimiter', () {
      expect(() => KnuthMorrisPrattMatcher([]), throwsArgumentError);
      expect(() => KnuthMorrisPrattMatcher.fromString(''), throwsArgumentError);
    });

    test('should handle edge cases', () {
      // Single character delimiter
      final singleCharMatcher = KnuthMorrisPrattMatcher.fromString('a');
      final singleCharResult = singleCharMatcher.match('xyzabc'.codeUnits);
      expect(singleCharResult, 3);
      
      // Delimiter same as data
      final exactMatcher = KnuthMorrisPrattMatcher.fromString('exact');
      final exactResult = exactMatcher.match('exact'.codeUnits);
      expect(exactResult, 4);
    });

    test('should handle overlapping matches', () {
      final matcher = KnuthMorrisPrattMatcher.fromString('aaa');
      final data = 'aaaaa'.codeUnits;
      
      final results = matcher.matchAll(data);
      expect(results, [2, 3, 4]); // Matches at positions 0-2, 1-3, 2-4
    });
  });
}
