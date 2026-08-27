import 'package:yaml/yaml.dart';

import 'naming.dart';

/// Поле конфигурации активного окружения Wiren Board.
class WbConfigField {
  const WbConfigField({
    required this.name,
    required this.typeName,
    required this.value,
    required this.nullable,
    this.hasDefault = false,
    this.defaultLiteral,
  });

  final String name;
  final String typeName;
  final Object? value;
  final bool nullable;
  final bool hasDefault;
  final String? defaultLiteral;
}

/// Модель для кодогена плоского [WbConfig].
class WbConfigModel {
  const WbConfigModel({required this.fields});

  final List<WbConfigField> fields;
}

/// Ошибка парсинга секции `wirenboard` в pubspec.yaml.
class YamlConfigException implements Exception {
  YamlConfigException(this.message);

  final String message;

  @override
  String toString() => 'YamlConfigException: $message';
}

/// Парсит `pubspec.yaml` и извлекает поля активного окружения.
class YamlConfigParser {
  static const _wirenboardKey = 'wirenboard';
  static const _portDefault = 1883;

  static WbConfigModel parse(
    String pubspecContent, {
    String currentEnv = 'dev',
  }) {
    final model = tryParse(pubspecContent, currentEnv: currentEnv);
    if (model == null) {
      throw YamlConfigException(
        'pubspec.yaml must contain a "$_wirenboardKey" section.',
      );
    }
    return model;
  }

  /// Парсит секцию `wirenboard`, если она есть. Без секции возвращает `null`.
  static WbConfigModel? tryParse(
    String pubspecContent, {
    String currentEnv = 'dev',
  }) {
    final root = loadYaml(pubspecContent);
    if (root is! Map) {
      throw YamlConfigException('pubspec.yaml root must be a map.');
    }

    final wirenboard = root[_wirenboardKey];
    if (wirenboard == null) {
      return null;
    }
    if (wirenboard is! Map) {
      throw YamlConfigException(
        'pubspec.yaml "$_wirenboardKey" must be a map.',
      );
    }

    final envBlocks = <String, Map<Object?, Object?>>{};
    for (final entry in wirenboard.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is! Map) {
        throw YamlConfigException(
          'pubspec.yaml "$_wirenboardKey.$key" must be a map (environment block).',
        );
      }
      envBlocks[key] = value;
    }

    if (envBlocks.isEmpty) {
      throw YamlConfigException(
        'pubspec.yaml "$_wirenboardKey" must contain at least one environment '
        'block.',
      );
    }

    final activeBlock = envBlocks[currentEnv];
    if (activeBlock == null) {
      throw YamlConfigException(
        'current_env is "$currentEnv" but no such environment block exists in '
        'pubspec.yaml "$_wirenboardKey". Available: '
        '${envBlocks.keys.join(", ")}.',
      );
    }

    final fields = <WbConfigField>[];
    for (final entry in activeBlock.entries) {
      final yamlKey = entry.key.toString();
      final value = entry.value;

      if (value is Map || value is List) {
        throw YamlConfigException(
          'pubspec.yaml "$_wirenboardKey.$currentEnv.$yamlKey" must be a '
          'scalar value (nested maps and lists are not supported).',
        );
      }

      final fieldName = toCamelCase(yamlKey);
      final parsed = _parseScalar(
        yamlKey: yamlKey,
        envName: currentEnv,
        value: value,
        fieldName: fieldName,
      );
      fields.add(parsed);
    }

    if (fields.isEmpty) {
      throw YamlConfigException(
        'pubspec.yaml "$_wirenboardKey.$currentEnv" must contain at least one '
        'configuration field.',
      );
    }

    return WbConfigModel(fields: fields);
  }

  static WbConfigField _parseScalar({
    required String yamlKey,
    required String envName,
    required Object? value,
    required String fieldName,
  }) {
    if (value == null) {
      return WbConfigField(
        name: fieldName,
        typeName: 'String',
        value: null,
        nullable: true,
      );
    }

    if (value is bool) {
      return WbConfigField(
        name: fieldName,
        typeName: 'bool',
        value: value,
        nullable: false,
      );
    }

    if (value is int) {
      final hasPortDefault = fieldName == 'port' && value == _portDefault;
      return WbConfigField(
        name: fieldName,
        typeName: 'int',
        value: value,
        nullable: false,
        hasDefault: hasPortDefault,
        defaultLiteral: hasPortDefault ? '$_portDefault' : null,
      );
    }

    if (value is double) {
      return WbConfigField(
        name: fieldName,
        typeName: 'double',
        value: value,
        nullable: false,
      );
    }

    if (value is String) {
      return WbConfigField(
        name: fieldName,
        typeName: 'String',
        value: value,
        nullable: false,
      );
    }

    throw YamlConfigException(
      'pubspec.yaml "wirenboard.$envName.$yamlKey" has unsupported type '
      '${value.runtimeType}.',
    );
  }
}
