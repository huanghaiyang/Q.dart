class SymbolUtil {
  static toChars(Symbol symbol) {
    String str = symbol.toString();
    str = str.replaceRange(str.length - 2, str.length, '');
    return str.replaceRange(0, 8, '');
  }
}
