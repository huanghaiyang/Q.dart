String getPathExtension(String path) {
  return path.substring(path.lastIndexOf(RegExp('\\.')) + 1, path.length);
}

String getFileName(String path) {
  List<String> segments = path.split(RegExp('\\/'));
  if (segments.isNotEmpty) {
    String last = segments.last;
    int index = last.lastIndexOf(RegExp('\\.'));
    if (index >= 0) {
      return last.substring(0, index);
    }
    return last;
  }
  return null;
}
