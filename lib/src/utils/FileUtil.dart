import 'dart:io';

import 'package:Q/src/Sign.dart';
import 'package:Q/src/utils/UuidUtil.dart';

// 创建临时文件
Future<File> createTempFile(List<int> data) async {
  Directory tempDir = await Directory.systemTemp.createTemp(TEMP_DIR_PATH);
  File tempFile = File('${tempDir.path}/${uuid5}.jpg');
  return tempFile.writeAsBytes(data);
}
