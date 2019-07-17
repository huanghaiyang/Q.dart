class KnuthMorrisPrattMatcher {
  List<int> delimiter;

  List<int> table;

  int matches = 0;

  KnuthMorrisPrattMatcher(List<int> delimiter) {
    this.delimiter = List.from(delimiter);
    this.table = longestSuffixPrefixTable(delimiter);
  }

  List<int> longestSuffixPrefixTable(List<int> delimiter) {
    List<int> result = List(delimiter.length);
    result[0] = 0;
    for (int i = 1; i < delimiter.length; i++) {
      int j = result[i - 1];
      while (j > 0 && delimiter[i] != delimiter[j]) {
        j = result[j - 1];
      }
      if (delimiter[i] == delimiter[j]) {
        j++;
      }
      result[i] = j;
    }
    return result;
  }

  int match(List<int> dataBuffer) {
    for (int i = 0; i < dataBuffer.length; i++) {
      int b = dataBuffer[i];

      while (this.matches > 0 && b != this.delimiter[this.matches]) {
        this.matches = this.table[this.matches - 1];
      }

      if (b == this.delimiter[this.matches]) {
        this.matches++;
        if (this.matches == this.delimiter.length) {
          reset();
          return i;
        }
      }
    }
    return -1;
  }

  void reset() {
    this.matches = 0;
  }
}
