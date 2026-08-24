import 'dart:convert';

import 'package:source_gen/source_gen.dart';

import 'naming.dart';

/// Собирает JSON-метаданные устройства и контролов Wiren Board.
class MetaBuilder {
  static String deviceMetaJson(ConstantReader annotation) {
    final title = _localizedTitleMap(annotation.read('title'));

    return jsonEncode({
      'driver': 'vktmotage',
      'title': title,
    });
  }

  static String controlMetaJson(
    ConstantReader annotation, {
    required String fieldName,
  }) {
    final meta = <String, dynamic>{
      'type': annotation.read('type').peek('mqttValue')!.stringValue,
      'title': _controlTitleMap(annotation, fieldName),
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

    final order = annotation.peek('order')?.intValue;
    if (order != null) {
      meta['order'] = order;
    }

    if (annotation.read('readonly').boolValue) {
      meta['readonly'] = true;
    }

    if (annotation.read('hidden').boolValue) {
      meta['hidden'] = true;
    }

    final enumTitles = annotation.peek('enumTitles');
    if (enumTitles != null && !enumTitles.isNull) {
      meta['enum'] = _enumTitlesMap(enumTitles);
    }

    return jsonEncode(meta);
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

  static Map<String, String> _localizedTitleMap(ConstantReader title) {
    final result = <String, String>{};
    final en = title.peek('en')?.stringValue;
    final ru = title.peek('ru')?.stringValue;
    if (en != null) {
      result['en'] = en;
    }
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
      for (final locale in valueReader.mapValue.keys) {
        localized[locale!.toStringValue()!] =
            valueReader.mapValue[locale]!.toStringValue()!;
      }
      result[keyString] = localized;
    }
    return result;
  }
}
