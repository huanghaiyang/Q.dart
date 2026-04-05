/**
 * 配置工具类，提供配置值的类型转换功能
 */
import 'dart:collection';

class ConfigureUtil {
  /**
   * 将动态类型值转换为字符串列表
   * 
   * @param value 动态类型值
   * @return 字符串列表，如果输入为null或不是列表则返回null
   */
  static List<String> convertToListString(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return null;
  }

  /**
   * 将动态类型值转换为字符串到字符串列表的映射
   * 
   * @param value 动态类型值
   * @return 字符串到字符串列表的映射，如果输入为null或不是映射则返回null
   */
  static Map<String, List<String>> convertToMapStringList(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      Map<String, List<String>> result = {};
      value.forEach((key, val) {
        if (val is List) {
          result[key.toString()] = val.map((item) => item.toString()).toList();
        }
      });
      return result;
    }
    return null;
  }
}