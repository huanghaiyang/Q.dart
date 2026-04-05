final String APPLICATION_ENVIRONMENT_VARIABLE = 'application.environment';
final String APPLICATION_NAME = 'application.name';
final String APPLICATION_AUTHORS = 'application.author';
final String APPLICATION_CREATE_TIME = 'application.createTime';
final String APPLICATION_INTERCEPTOR_TIMEOUT = 'application.configuration.interceptor.timeout';
final String APPLICATION_ROUTER_DEFAULT_MAPPING = 'application.configuration.router.defaultMapping';
final String APPLICATION_REQUEST_ALLOWED_CONTENT_TYPES = 'application.configuration.request.allowedContentTypes';
final String APPLICATION_REQUEST_ALLOWED_METHODS = 'application.configuration.request.allowedMethods';
final String APPLICATION_REQUEST_ALLOWED_ORIGINS = 'application.configuration.request.allowedOrigins';
final String APPLICATION_REQUEST_ALLOWED_HEADERS = 'application.configuration.request.allowedHeaders';
final String APPLICATION_REQUEST_ALLOWED_CREDENTIALS = 'application.configuration.request.allowedCredentials';
final String APPLICATION_REQUEST_MAX_AGE = 'application.configuration.request.maxAge';
final String APPLICATION_REQUEST_PREFETCH_STRATEGY = 'application.configuration.request.prefetchStrategy';
final String APPLICATION_MULTIPART_MAX_FILE_UPLOAD_SIZE = 'application.configuration.request.multipart.maxFileUploadSize';
final String APPLICATION_MULTIPART_FIX_NAME_SUFFIX_IF_ARRAY = 'application.configuration.request.multipart.fixNameSuffixIfArray';
final String APPLICATION_MULTIPART_DEFAULT_UPLOAD_TEMP_DIR_PATH = 'application.configuration.request.multipart.defaultUploadTempDirPath';
final String APPLICATION_RESPONSE_DEFAULT_PRODUCED_TYPE = 'application.configuration.response.defaultProducedType';

// 数据库配置
final String DATABASE_TYPE = 'database.type';
final String DATABASE_CONNECTION_PATH = 'database.connection.path';
final String DATABASE_CONNECTION_HOST = 'database.connection.host';
final String DATABASE_CONNECTION_PORT = 'database.connection.port';
final String DATABASE_CONNECTION_DATABASE = 'database.connection.database';
final String DATABASE_CONNECTION_USERNAME = 'database.connection.username';
final String DATABASE_CONNECTION_PASSWORD = 'database.connection.password';
final String DATABASE_POOL_MAX_CONNECTIONS = 'database.pool.maxConnections';
final String DATABASE_POOL_MIN_CONNECTIONS = 'database.pool.minConnections';
final String DATABASE_POOL_CONNECTION_TIMEOUT = 'database.pool.connectionTimeout';
final String DATABASE_POOL_IDLE_TIMEOUT = 'database.pool.idleTimeout';
final String DATABASE_POOL_MAX_LIFETIME = 'database.pool.maxLifetime';
final String DATABASE_MIGRATION_ENABLED = 'database.migrations.enabled';
final String DATABASE_MIGRATION_TABLE = 'database.migrations.table';
final String DATABASE_MIGRATION_AUTO_RUN = 'database.migrations.autoRun';

// 缓存配置
final String CACHE_ENABLED = 'cache.enabled';
final String CACHE_DEFAULT_TTL = 'cache.defaultTtl';
final String CACHE_SECURITY_ENABLED = 'cache.security.enabled';
final String CACHE_SECURITY_ENCRYPTION_KEY = 'cache.security.encryptionKey';
final String CACHE_RATE_LIMIT_ENABLED = 'cache.rateLimit.enabled';
final String CACHE_RATE_LIMIT_MAX_REQUESTS = 'cache.rateLimit.maxRequests';
final String CACHE_RATE_LIMIT_WINDOW = 'cache.rateLimit.window';
final String CACHE_REDIS_ENABLED = 'cache.redis.enabled';
final String CACHE_REDIS_HOST = 'cache.redis.host';
final String CACHE_REDIS_PORT = 'cache.redis.port';
final String CACHE_REDIS_PASSWORD = 'cache.redis.password';
final String CACHE_REDIS_DB = 'cache.redis.db';

// 安全配置
final String SECURITY_CSRF_ENABLED = 'security.csrf.enabled';
final String SECURITY_CSRF_PROTECTED_METHODS = 'security.csrf.protectedMethods';
final String SECURITY_CSRF_TOKEN_MAX_AGE = 'security.csrf.tokenMaxAge';
final String SECURITY_CSRF_TOKEN_HEADER = 'security.csrf.tokenHeader';
final String SECURITY_CSRF_TOKEN_COOKIE = 'security.csrf.tokenCookie';
final String SECURITY_XSS_ENABLED = 'security.xss.enabled';
final String SECURITY_XSS_BLOCK_REQUEST = 'security.xss.blockRequest';
final String SECURITY_XSS_PROTECTED_CONTENT_TYPES = 'security.xss.protectedContentTypes';
final String SECURITY_AUTH_ENABLED = 'security.auth.enabled';
final String SECURITY_AUTH_PUBLIC_PATHS = 'security.auth.publicPaths';
final String SECURITY_AUTH_PATH_ROLES = 'security.auth.pathRoles';
final String SECURITY_AUTH_TOKEN_HEADER = 'security.auth.tokenHeader';
final String SECURITY_AUTH_TOKEN_EXPIRATION = 'security.auth.tokenExpiration';
final String SECURITY_HEADERS_ENABLED = 'security.securityHeaders.enabled';
final String SECURITY_HEADERS_XSS_PROTECTION = 'security.securityHeaders.xssProtection';
final String SECURITY_HEADERS_CONTENT_TYPE_OPTIONS = 'security.securityHeaders.contentTypeOptions';
final String SECURITY_HEADERS_FRAME_OPTIONS = 'security.securityHeaders.frameOptions';
final String SECURITY_HEADERS_CONTENT_SECURITY_POLICY = 'security.securityHeaders.contentSecurityPolicy';
final String SECURITY_HEADERS_CONTENT_SECURITY_POLICY_VALUE = 'security.securityHeaders.contentSecurityPolicyValue';

// HTTPS配置
final String HTTPS_ENABLED = 'https.enabled';
final String HTTPS_CERTIFICATE_PATH = 'https.certificatePath';
final String HTTPS_PRIVATE_KEY_PATH = 'https.privateKeyPath';
final String HTTPS_CERTIFICATE_PASSWORD = 'https.certificatePassword';
final String HTTPS_ENABLE_HTTP2 = 'https.enableHttp2';
final String HTTPS_ENABLE_TLS13 = 'https.enableTls13';
final String HTTPS_TLS_VERSIONS = 'https.tlsVersions';
final String HTTPS_CLIENT_CERTIFICATE_REQUIRED = 'https.clientCertificateRequired';
final String HTTPS_TRUSTED_CA_CERTIFICATE_PATH = 'https.trustedCaCertificatePath';

// 国际化配置
final String I18N_ENABLED = 'i18n.enabled';
final String I18N_DEFAULT_LOCALE = 'i18n.defaultLocale';
final String I18N_SUPPORTED_LOCALES = 'i18n.supportedLocales';
final String I18N_RESOURCE_PATH = 'i18n.resourcePath';

// 日志配置
final String LOGGING_LEVEL = 'logging.level';
final String LOGGING_FORMAT = 'logging.format';
final String LOGGING_OUTPUT = 'logging.output';
final String LOGGING_FILE = 'logging.file';

