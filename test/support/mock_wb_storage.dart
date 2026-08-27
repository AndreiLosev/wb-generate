import 'package:wb_annatation/wb_annatation.dart';

/// In-memory [WbStorage] для тестов.
class MockWbStorage implements WbStorage {
  final Map<String, Object?> values = {};

  @override
  Object? get(String key, Object? defaultValue) {
    return values.containsKey(key) ? values[key] : defaultValue;
  }

  @override
  void put(String key, Object? value) {
    values[key] = value;
  }
}
