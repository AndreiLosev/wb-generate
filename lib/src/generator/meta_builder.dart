import 'package:source_gen/source_gen.dart';
import 'package:wb_sdk/wb_sdk.dart';

import 'naming.dart';

/// Собирает метаданные контролов Wiren Board.
class MetaBuilder {
  static ControlMeta buildControlMeta(
    ConstantReader annotation, {
    required String fieldName,
    required WbControlType type,
    required int order,
  }) {
    final meta = ControlMeta(
      type: type,
      title: _controlTitle(annotation, fieldName),
      order: order,
      readonly: annotation.read('readonly').boolValue,
      hidden: annotation.read('hidden').boolValue,
    );

    final units = annotation.peek('units')?.stringValue;
    if (units != null) {
      meta.units = units;
    }

    final min = annotation.peek('min')?.doubleValue;
    if (min != null) {
      meta.min = min.toInt();
    }

    final max = annotation.peek('max')?.doubleValue;
    if (max != null) {
      meta.max = max.toInt();
    }

    final precision = annotation.peek('precision')?.doubleValue;
    if (precision != null) {
      meta.precision = precision;
    }

    final enumTitles = annotation.peek('enumTitles');
    if (enumTitles != null && !enumTitles.isNull) {
      meta.enumTitles = _enumTitles(enumTitles);
    }

    return meta;
  }

  static String toControlMetaLiteral(
    ConstantReader annotation, {
    required String fieldName,
    required String typeEnumName,
    required int order,
  }) {
    final parts = <String>[
      'type: WbControlType.$typeEnumName',
      'title: ${_localizedTitleLiteral(annotation, fieldName)}',
      'order: $order',
    ];

    final units = annotation.peek('units')?.stringValue;
    if (units != null) {
      parts.add("units: '${_escapeDartString(units)}'");
    }

    final min = annotation.peek('min')?.doubleValue;
    if (min != null) {
      parts.add('min: ${min.toInt()}');
    }

    final max = annotation.peek('max')?.doubleValue;
    if (max != null) {
      parts.add('max: ${max.toInt()}');
    }

    final precision = annotation.peek('precision')?.doubleValue;
    if (precision != null) {
      parts.add('precision: ${_precisionLiteral(precision)}');
    }

    parts
      ..add('readonly: ${annotation.read('readonly').boolValue}')
      ..add('hidden: ${annotation.read('hidden').boolValue}');

    final enumTitles = annotation.peek('enumTitles');
    if (enumTitles != null && !enumTitles.isNull) {
      parts.add('enumTitles: ${_enumTitlesLiteral(enumTitles)}');
    }

    return 'ControlMeta(\n      ${parts.join(',\n      ')},\n    )';
  }

  static WbLocalizedTitle _controlTitle(
    ConstantReader annotation,
    String fieldName,
  ) {
    final defaultEn = toSnakeCase(fieldName);
    final titleReader = annotation.peek('title');
    if (titleReader == null || titleReader.isNull) {
      return WbLocalizedTitle(en: defaultEn);
    }

    final en = titleReader.peek('en')?.stringValue ?? defaultEn;
    final ru = titleReader.peek('ru')?.stringValue;
    if (ru != null) {
      return WbLocalizedTitle(en: en, ru: ru);
    }
    return WbLocalizedTitle(en: en);
  }

  static String _localizedTitleLiteral(
    ConstantReader annotation,
    String fieldName,
  ) {
    final title = _controlTitle(annotation, fieldName);
    final en = title.en ?? toSnakeCase(fieldName);
    final ru = title.ru;
    if (ru != null) {
      return "const WbLocalizedTitle(en: '${_escapeDartString(en)}', "
          "ru: '${_escapeDartString(ru)}')";
    }
    return "const WbLocalizedTitle(en: '${_escapeDartString(en)}')";
  }

  static Map<String, WbLocalizedTitle> _enumTitles(ConstantReader enumTitles) {
    final result = <String, WbLocalizedTitle>{};
    for (final key in enumTitles.mapValue.keys) {
      final keyString = key!.toStringValue()!;
      result[keyString] = _localizedTitleFromReader(
        ConstantReader(enumTitles.mapValue[key]!),
        keyString,
      );
    }
    return result;
  }

  static String _enumTitlesLiteral(ConstantReader enumTitles) {
    final entries = <String>[];
    for (final key in enumTitles.mapValue.keys) {
      final keyString = key!.toStringValue()!;
      entries.add(
        "'${_escapeDartString(keyString)}': "
        '${_localizedTitleLiteralFromReader(ConstantReader(enumTitles.mapValue[key]!), keyString)}',
      );
    }
    return '{\n        ${entries.join(',\n        ')},\n      }';
  }

  static WbLocalizedTitle _localizedTitleFromReader(
    ConstantReader reader,
    String fallbackEn,
  ) {
    final en = reader.peek('en')?.stringValue ?? fallbackEn;
    final ru = reader.peek('ru')?.stringValue;
    if (ru != null) {
      return WbLocalizedTitle(en: en, ru: ru);
    }
    return WbLocalizedTitle(en: en);
  }

  static String _localizedTitleLiteralFromReader(
    ConstantReader reader,
    String fallbackEn,
  ) {
    final title = _localizedTitleFromReader(reader, fallbackEn);
    final en = title.en ?? fallbackEn;
    final ru = title.ru;
    if (ru != null) {
      return "const WbLocalizedTitle(en: '${_escapeDartString(en)}', "
          "ru: '${_escapeDartString(ru)}')";
    }
    return "const WbLocalizedTitle(en: '${_escapeDartString(en)}')";
  }

  static String _precisionLiteral(double precision) {
    if (precision == precision.roundToDouble()) {
      return '${precision.toInt()}.0';
    }
    return '$precision';
  }

  static String _escapeDartString(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$');
  }
}
