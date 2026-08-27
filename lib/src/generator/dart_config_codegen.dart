import 'yaml_config_parser.dart';

/// Генерирует плоский data-класс [WbConfig] из [WbConfigModel].
class DartConfigCodegen {
  static String generate(WbConfigModel model) {
    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln('class WbConfig {')
      ..writeln('  const WbConfig({');

    for (final field in model.fields) {
      buffer.writeln('    ${_constructorParam(field)},');
    }

    buffer
      ..writeln('  });')
      ..writeln()
      ..writeln('  static const WbConfig instance = WbConfig(');

    for (final field in model.fields) {
      if (field.hasDefault && field.value == 1883) {
        continue;
      }
      buffer.writeln('    ${_instanceArg(field)}');
    }

    buffer
      ..writeln('  );')
      ..writeln();

    for (final field in model.fields) {
      final type = field.nullable ? '${field.typeName}?' : field.typeName;
      buffer.writeln('  final $type ${field.name};');
    }

    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('const wbConfig = WbConfig.instance;');

    return buffer.toString();
  }

  static String _constructorParam(WbConfigField field) {
    if (field.hasDefault && field.defaultLiteral != null) {
      return 'this.${field.name} = ${field.defaultLiteral}';
    }
    if (field.nullable) {
      return 'this.${field.name}';
    }
    return 'required this.${field.name}';
  }

  static String _instanceArg(WbConfigField field) {
    return '${field.name}: ${_literal(field.value, field.typeName)},';
  }

  static String _literal(Object? value, String typeName) {
    if (value == null) {
      return 'null';
    }

    switch (typeName) {
      case 'String':
        return "'${_escapeDartString(value as String)}'";
      case 'bool':
        return value == true ? 'true' : 'false';
      case 'int':
        return '${value as int}';
      case 'double':
        final doubleValue = value as double;
        if (doubleValue == doubleValue.roundToDouble()) {
          return '${doubleValue.toInt()}.0';
        }
        return '$doubleValue';
      default:
        throw ArgumentError('Unsupported type: $typeName');
    }
  }

  static String _escapeDartString(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$');
  }
}
