// 数据组合
List<int> concat(List<List<int>> byteArrays) {
  int length = 0;
  for (List<int> byteArray in byteArrays) {
    length += byteArray.length;
  }
  List<int> result = List(length);
  length = 0;
  for (List<int> byteArray in byteArrays) {
    result.setRange(length, length + byteArray.length, byteArray);
    length += byteArray.length;
  }
  return result;
}
