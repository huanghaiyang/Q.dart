abstract class AttributeAware<T> {
  T getAttribute(String name);

  Iterable<String> getAttributeNames();

  void setAttribute(String name, dynamic value);

  void mergeAttributes(Map<String, T> attributes);

  bool hasAttribute(String name);

  T removeAttribute(String name);

  Map<String, T> get attributes;

  Iterable<String> get attributeNames;
}
