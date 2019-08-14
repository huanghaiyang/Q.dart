String getPathExtension(String path) {
  return path.substring(path.lastIndexOf(RegExp('\\.')) + 1, path.length);
}
