import 'dart:io';

import 'package:wb_sdk/wb_sdk.dart';

import 'mock_wb_storage.dart';

/// Регистрирует in-memory storage через [WbHiveStorage] singleton для тестов.
class TestWbStorage {
  TestWbStorage._({
    required this.mock,
    required Directory directory,
  }) : _directory = directory;

  final MockWbStorage mock;
  final Directory _directory;

  WbStorage get storage => WbHiveStorage.getInstanse();

  static Future<TestWbStorage> create() async {
    final directory = await Directory.systemTemp.createTemp(
      'wb_generate_storage_test',
    );
    final mock = MockWbStorage();
    final hiveStorage = _TestWbHiveStorage(
      directory: directory.path,
      mock: mock,
    );
    await hiveStorage.open();
    return TestWbStorage._(
      mock: mock,
      directory: directory,
    );
  }

  Future<void> disposeForTest() async {
    if (_directory.existsSync()) {
      await _directory.delete(recursive: true);
    }
  }
}

class _TestWbHiveStorage extends WbHiveStorage {
  _TestWbHiveStorage({
    required String directory,
    required this.mock,
  }) : super(directory: directory);

  final MockWbStorage mock;

  @override
  Future<void> open() async {
    await super.open();
  }

  @override
  void put(String key, Object? value) {
    mock.put(key, value);
  }

  @override
  Object? get(String key, Object? defaultValue) {
    return mock.get(key, defaultValue);
  }
}
