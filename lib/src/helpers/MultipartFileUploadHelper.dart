import 'dart:io';

import 'package:Q/src/Application.dart';
import 'package:Q/src/utils/UuidUtil.dart';

final String TEMP_DIR_PATH = 'q_temp_dir';

class MultipartFileUploadHelper {
  static Future<String> createTempFileUploadPath(String extension) async {
    Directory tempDir = await Directory(Application.getApplicationContext().configuration.multipartConfigure.defaultUploadTempDirPath)
        .createTemp(TEMP_DIR_PATH);
    return '${tempDir.path}/${uuid5}.${extension}';
  }
}
