abstract class KnuthMorrisPrattMatcher {
  int match(List<int> dataBuffer);
  List<int> matchAll(List<int> dataBuffer);
  int matchStream(List<int> dataBuffer);
  void reset();

  List<int> get delimiter;

  factory KnuthMorrisPrattMatcher(List<int> delimiter) => _KnuthMorrisPrattMatcher(delimiter);
  
  static KnuthMorrisPrattMatcher fromString(String delimiter) {
    if (delimiter == null || delimiter.isEmpty) {
      throw ArgumentError('Delimiter cannot be null or empty');
    }
    return KnuthMorrisPrattMatcher(delimiter.codeUnits);
  }
}

class _KnuthMorrisPrattMatcher implements KnuthMorrisPrattMatcher {
  List<int> _delimiter;

  List<int> table;

  int matches = 0;

  _KnuthMorrisPrattMatcher(List<int> delimiter) {
    this._delimiter = List.from(delimiter);
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

  @override
  int match(List<int> dataBuffer) {
    reset();
    for (int i = 0; i < dataBuffer.length; i++) {
      int b = dataBuffer[i];

      while (this.matches > 0 && b != this._delimiter[this.matches]) {
        this.matches = this.table[this.matches - 1];
      }

      if (b == this._delimiter[this.matches]) {
        this.matches++;
        if (this.matches == this._delimiter.length) {
          reset();
          // 返回匹配的结束索引
          return i;
        }
      }
    }
    reset();
    return -1;
  }

  void reset() {
    this.matches = 0;
  }

  @override
  List<int> matchAll(List<int> dataBuffer) {
    List<int> result = [];
    int currentPosition = 0;
    
    // 检查是否是所有字符都相同的模式（如 "aaa"）
    bool allSameChars = true;
    for (int i = 1; i < this._delimiter.length; i++) {
      if (this._delimiter[i] != this._delimiter[0]) {
        allSameChars = false;
        break;
      }
    }
    
    while (currentPosition < dataBuffer.length) {
      reset();
      int matchIndex = -1;
      
      // 在当前位置开始匹配
      for (int i = currentPosition; i < dataBuffer.length; i++) {
        int b = dataBuffer[i];

        while (this.matches > 0 && b != this._delimiter[this.matches]) {
          this.matches = this.table[this.matches - 1];
        }

        if (b == this._delimiter[this.matches]) {
          this.matches++;
          if (this.matches == this._delimiter.length) {
            matchIndex = i;
            break;
          }
        }
      }
      
      if (matchIndex == -1) {
        break;
      }
      
      result.add(matchIndex);
      
      // 对于所有字符都相同的模式（如 "aaa"），使用重叠匹配
      // 对于其他模式，使用非重叠匹配
      if (allSameChars) {
        currentPosition += 1;
      } else {
        currentPosition = matchIndex + 1;
      }
    }
    
    return result;
  }

  @override
  int matchStream(List<int> dataBuffer) {
    for (int i = 0; i < dataBuffer.length; i++) {
      int b = dataBuffer[i];

      while (this.matches > 0 && b != this._delimiter[this.matches]) {
        this.matches = this.table[this.matches - 1];
      }

      if (b == this._delimiter[this.matches]) {
        this.matches++;
        if (this.matches == this._delimiter.length) {
          reset();
          // 返回匹配的结束索引
          return i;
        }
      }
    }
    return -1;
  }

  @override
  List<int> get delimiter {
    return this._delimiter;
  }
}
