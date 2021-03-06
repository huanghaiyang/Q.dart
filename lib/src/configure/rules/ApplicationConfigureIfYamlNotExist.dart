class ApplicationConfigureIfYamlNotExist {
  static Map rule = {
    'application': {
      'name': '<string>',
      'author': '<array<string>>',
      'createTime': '<datetime>',
      'environment': 'prod<string>',
      'resourceDir': '/lib/resources<string>',
      'configuration': {
        'interceptor': {'timeout': '10ms<timeunit>'},
        'router': {'defaultMapping': '/<string>'},
        'request': {
          'allowedContentTypes': '<array<string>>',
          'allowedMethods': '<array<string>>',
          'allowedOrigins': '<array<string>>',
          'allowedHeaders': '<array<string>>',
          'allowedCredentials': '<array<string>>',
          'maxAge': '<int>',
          'multipart': {
            'maxFileUploadSize': '10mb<sizeunit>',
            'fixNameSuffixIfArray': 'true<bool>',
            'defaultUploadTempDirPath': '~system_temp_dir_path<string>'
          },
          'prefetchStrategy': 'allow<string>'
        },
        'response': {'defaultProducedType': 'application/json; charset=utf-8 <string>'}
      }
    }
  };
}
