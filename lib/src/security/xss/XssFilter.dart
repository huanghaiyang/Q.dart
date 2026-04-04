/// XSS 过滤器
/// 提供 HTML 转义和 XSS 攻击防护功能
class XssFilter {
  /// HTML 特殊字符转义映射
  static final Map<String, String> _htmlEscapeMap = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#x27;',
    '/': '&#x2F;',
  };

  /// 转义 HTML 特殊字符
  static String escapeHtml(String input) {
    if (input == null || input.isEmpty) {
      return input;
    }
    
    return input.replaceAllMapped(
      RegExp('[${_htmlEscapeMap.keys.map(RegExp.escape).join()}]'),
      (match) => _htmlEscapeMap[match.group(0)] ?? match.group(0),
    );
  }

  /// 过滤 JavaScript 事件处理器
  static String filterJavaScriptEvents(String input) {
    if (input == null || input.isEmpty) {
      return input;
    }

    // 移除常见的事件处理器属性
    final eventPattern = RegExp(
      r"\s(on\w+)\s*=\s*[^>\s]+",
      caseSensitive: false,
    );
    
    return input.replaceAll(eventPattern, '');
  }

  /// 过滤危险的 HTML 标签
  static String filterDangerousTags(String input) {
    if (input == null || input.isEmpty) {
      return input;
    }

    // 移除危险的标签
    final dangerousTags = [
      'script',
      'iframe',
      'object',
      'embed',
      'form',
      'input',
      'textarea',
    ];

    String result = input;
    for (String tag in dangerousTags) {
      // 移除开始标签
      result = result.replaceAll(
        RegExp('<$tag[^>]*>', caseSensitive: false),
        '',
      );
      // 移除结束标签
      result = result.replaceAll(
        RegExp('</$tag>', caseSensitive: false),
        '',
      );
    }

    return result;
  }

  /// 过滤 JavaScript 伪协议
  static String filterJavaScriptProtocol(String input) {
    if (input == null || input.isEmpty) {
      return input;
    }

    // 移除 javascript: 伪协议
    final jsProtocolPattern = RegExp(
      r'javascript\s*:',
      caseSensitive: false,
    );

    return input.replaceAll(jsProtocolPattern, '');
  }

  /// 综合 XSS 过滤
  static String sanitize(String input) {
    if (input == null || input.isEmpty) {
      return input;
    }

    String result = input;
    result = escapeHtml(result);
    result = filterJavaScriptEvents(result);
    result = filterDangerousTags(result);
    result = filterJavaScriptProtocol(result);

    return result;
  }

  /// 检查是否包含 XSS 攻击特征
  static bool containsXss(String input) {
    if (input == null || input.isEmpty) {
      return false;
    }

    final xssPatterns = [
      r'<script[^>]*>',
      r'javascript\s*:',
      r'on\w+\s*=',
      r'<iframe',
      r'<object',
      r'<embed',
      r'eval\s*\(',
      r'expression\s*\(',
    ];

    for (String pattern in xssPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }

    return false;
  }
}
