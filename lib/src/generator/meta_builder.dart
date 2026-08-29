import 'package:source_gen/source_gen.dart';

import 'naming.dart';

/// Собирает метаданные контролов Wiren Board.
class MetaBuilder {
  static Map<String, dynamic> controlMeta(
    ConstantReader annotation, {
    required String fieldName,
    required int order,
  }) {
    final meta = <String, dynamic>{
      'type': annotation.read('type').peek('mqttValue')!.stringValue,
      'title': _controlTitleMap(annotation, fieldName),
      'order': order,
      'readonly': annotation.read('readonly').boolValue,
      'hidden': annotation.read('hidden').boolValue,
    };

    final units = annotation.peek('units')?.stringValue;
    if (units != null) {
      meta['units'] = units;
    }

    final min = annotation.peek('min')?.doubleValue;
    if (min != null) {
      meta['min'] = min;
    }

    final max = annotation.peek('max')?.doubleValue;
    if (max != null) {
      meta['max'] = max;
    }

    final precision = annotation.peek('precision')?.doubleValue;
    if (precision != null) {
      meta['precision'] = precision;
    }

    final enumTitles = annotation.peek('enumTitles');
    if (enumTitles != null && !enumTitles.isNull) {
      meta['enum'] = _enumTitlesMap(enumTitles);
    }

    return meta;
  }

  static String toDartLiteral(Object? value) {
    if (value == null) {
      return 'null';
    }

    if (value is Map) {
      final entries = value.entries
          .map(
            (entry) =>
                "'${_escapeDartString(entry.key.toString())}': ${toDartLiteral(entry.value)}",
          )
          .join(', ');
      return '{$entries}';
    }

    if (value is String) {
      return "'${_escapeDartString(value)}'";
    }

    if (value is bool) {
      return value ? 'true' : 'false';
    }

    if (value is int) {
      return '$value';
    }

    if (value is double) {
      if (value == value.roundToDouble()) {
        return '${value.toInt()}.0';
      }
      return '$value';
    }

    throw ArgumentError('Unsupported value type: ${value.runtimeType}');
  }

  static Map<String, String> _controlTitleMap(
    ConstantReader annotation,
    String fieldName,
  ) {
    final defaultEn = toSnakeCase(fieldName);
    final titleReader = annotation.peek('title');
    if (titleReader == null || titleReader.isNull) {
      return {'en': defaultEn};
    }

    final result = <String, String>{
      'en': titleReader.peek('en')?.stringValue ?? defaultEn,
    };
    final ru = titleReader.peek('ru')?.stringValue;
    if (ru != null) {
      result['ru'] = ru;
    }
    return result;
  }

  static Map<String, Map<String, String>> _enumTitlesMap(
    ConstantReader enumTitles,
  ) {
    final result = <String, Map<String, String>>{};
    for (final key in enumTitles.mapValue.keys) {
      final keyString = key!.toStringValue()!;
      final valueReader = ConstantReader(enumTitles.mapValue[key]!);
      final localized = <String, String>{};
      final en = valueReader.peek('en')?.stringValue;
      final ru = valueReader.peek('ru')?.stringValue;
      if (en != null) {
        localized['en'] = en;
      }
      if (ru != null) {
        localized['ru'] = ru;
      }
      result[keyString] = localized;
    }
    return result;
  }

  static String _escapeDartString(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$');
  }
}
