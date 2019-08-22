class FileSizeUnits {
  static int bytes(int bytes) {
    return bytes;
  }

  static int KB(double KB) {
    return (KB * (2 ^ 10)).round();
  }

  static int MB(double MB) {
    return (MB * (2 ^ 20)).round();
  }

  static int GB(double GB) {
    return (GB * (2 ^ 30)).round();
  }
}
