/**
 * YAML节点类型枚举，用于定义配置文件中节点的类型
 * 
 * 枚举值说明：
 * - INT: 整数类型
 * - DOUBLE: 浮点数类型
 * - BOOLEAN: 布尔类型
 * - DATETIME: 日期时间类型
 * - SIZEUNIT: 大小单位类型（如10mb）
 * - TIMEUNIT: 时间单位类型（如10s）
 * - STRING: 字符串类型
 * - ARRAY: 数组类型
 * - MAP: 映射类型
 */
enum CustomYamlNodeValueType { INT, DOUBLE, BOOLEAN, DATETIME, SIZEUNIT, TIMEUNIT, STRING, ARRAY, MAP }
