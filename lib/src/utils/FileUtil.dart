import 'dart:io';

import 'package:Q/src/Sign.dart';
import 'package:Q/src/utils/UuidUtil.dart';

// 创建临时文件
Future<File> createTempFile(List<int> data, String extension) async {
  File tempFile = File(await createTempFilePath(extension));
  return tempFile.writeAsBytes(data);
}

// 创建临时文件路径
Future<String> createTempFilePath(String extension) async {
  Directory tempDir = await Directory.systemTemp.createTemp(TEMP_DIR_PATH);
  return '${tempDir.path}/${uuid5}.${extension}';
}

String getPathExtension(String path) {
  return path.substring(path.lastIndexOf(RegExp('\\.')) + 1, path.length);
}
