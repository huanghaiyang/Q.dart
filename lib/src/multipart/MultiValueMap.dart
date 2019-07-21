import 'dart:collection';
import 'dart:io';

import 'package:Q/src/query/CommonValue.dart';
import 'package:Q/src/query/MultipartFile.dart';
import 'package:Q/src/query/Value.dart';
import 'package:Q/src/utils/FileUtil.dart';

class MultiValueMap<K, V> implements LinkedHashMap<K, V> {
  Map<K, V> store = Map();

  MultiValueMap(this.store);

  factory MultiValueMap.from(Map other) {
    MultiValueMap<K, V> result = MultiValueMap<K, V>(other);
    other.forEach((k, v) {
      result[k] = v;
    });
    return result;
  }

  dynamic getFirstValue(K name) {
    List<dynamic> values = this.getValues(name);
    if (values != null) {
      if (values.isNotEmpty) {
        return values.first;
      } else {
        return [];
      }
    }
    return null;
  }

  List<dynamic> getValues(K name) {
    if (this.containsKey(name)) {
      V values = this[name];
      return List.from((values as List<Value>).map((value) {
        if (value is CommonValue) {
          return value.value;
        } else if (value is MultipartFile) {
          return value.bytes;
        }
        return null;
      }));
    }
    return null;
  }

  Future<File> getFirstFile(K name) async {
    dynamic value = this.getFirstValue(name);
    if (value != null && value is List<int>) {
      return createTempFile(value);
    }
    return null;
  }

  Future<List<File>> getFiles(K name) async {
    List<dynamic> values = this.getValues(name);
    List<Future> futures = List();
    values.forEach((value) {
      futures.add(createTempFile(value));
    });
    if (values != null) {
      if (values.isNotEmpty) {
        List list = await Future.wait(futures.getRange(0, futures.length));
        return List<File>.from(list);
      }
      return [];
    }
    return null;
  }

  @override
  bool containsValue(Object value) {
    return this.store.containsKey(value);
  }

  @override
  bool containsKey(Object key) {
    return this.store.containsKey(key);
  }

  @override
  Iterable<MapEntry<K, V>> get entries {
    return this.store.entries;
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) {
    return this.store.addEntries(newEntries);
  }

  @override
  V update(K key, V update(V value), {V ifAbsent()}) {
    return this.update(key, update, ifAbsent: ifAbsent);
  }

  @override
  void updateAll(V update(K key, V value)) {
    return this.store.updateAll(update);
  }

  @override
  void removeWhere(bool predicate(K key, V value)) {
    this.store.removeWhere(predicate);
  }

  @override
  V putIfAbsent(K key, V ifAbsent()) {
    return this.store.putIfAbsent(key, ifAbsent);
  }

  @override
  void addAll(Map<K, V> other) {
    return this.store.addAll(other);
  }

  @override
  V remove(Object key) {
    return this.remove(key);
  }

  @override
  void clear() {
    this.clear();
  }

  @override
  void forEach(void f(K key, V value)) {
    this.store.forEach(f);
  }

  @override
  Iterable<K> get keys {
    return this.store.keys;
  }

  @override
  Iterable<V> get values {
    return this.store.values;
  }

  @override
  int get length {
    return this.store.length;
  }

  @override
  bool get isEmpty {
    return this.store.isEmpty;
  }

  @override
  bool get isNotEmpty {
    return this.store.isNotEmpty;
  }

  @override
  V operator [](Object key) {
    return this.store[key];
  }

  @override
  void operator []=(K key, V value) {
    this.store[key] = value;
  }

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> transform(K key, V value)) {
    var result = <K2, V2>{};
    for (var key in this.keys) {
      var entry = transform(key, this[key]);
      result[entry.key] = entry.value;
    }
    return result;
  }

  @override
  Map<RK, RV> cast<RK, RV>() => this.store.cast<RK, RV>();
}
