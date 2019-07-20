import 'dart:io';

import 'package:Q/src/utils/UuidUtil.dart';

Future<File> createTempFile(List<int> data) async {
  Directory tempDir = await Directory.systemTemp.createTemp('q_temp_dir');
  File tempFile = File('${tempDir.path}/${uuid}.jpg');
  return tempFile.writeAsBytes(data);
}
