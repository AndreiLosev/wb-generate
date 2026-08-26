import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:wb_annatation/wb_annatation.dart';
import 'package:wb_generate/src/generator/meta_builder.dart';

import 'support/analysis.dart';

void main() {
  group('MetaBuilder', () {
    test('собирает meta контрола с опциональными полями', () async {
      final json = await _controlMetaJson('lamp');
      expect(json, contains('"type":"switch"'));
      expect(json, contains('"order":2'));
      expect(json, contains('"title":{"en":"Lamp","ru":"Лампа"}'));
      expect(json, contains('"readonly":false'));
      expect(json, contains('"hidden":false'));
    });

    test('включает readonly, hidden, enum и units', () async {
      final json = await _controlMetaJson('power');
      expect(json, contains('"type":"value"'));
      expect(json, contains('"units":"W"'));
      expect(json, contains('"readonly":true'));
      expect(json, contains('"hidden":false'));
      expect(json, isNot(contains('"enum"')));
    });

    test('собирает enumTitles для text-контрола', () async {
      final json = await _controlMetaJson('mode');
      expect(json, contains('"enum":{"0":{"en":"Off","ru":"Выкл"}'));
    });

    test('использует snake_case поля как en, если title не задан', () async {
      final json = await _controlMetaJsonFromFixture(
        'ControlTitleSamples',
        'wallSwitch',
      );

      expect(json, contains('"title":{"en":"wall_switch"}'));
      expect(json, contains('"order":1'));
    });

    test('использует snake_case поля как en, если title.en не задан', () async {
      final json = await _controlMetaJsonFromFixture(
        'ControlTitleSamples',
        'kitchenSwitch',
      );

      expect(
        json,
        contains('"title":{"en":"kitchen_switch","ru":"Выключатель"}'),
      );
      expect(json, contains('"order":2'));
    });
  });
}

Future<String> _controlMetaJsonFromFixture(
  String className,
  String fieldName,
) async {
  final clazz = await resolveFixtureClass(className);
  final field = clazz.getField(fieldName)!;
  final reader = _controlReader(field);
  final order = _controlOrder(clazz, fieldName);

  return MetaBuilder.controlMetaJson(
    reader,
    fieldName: field.name,
    order: order,
  );
}

Future<String> _controlMetaJson(String fieldName) async {
  final clazz = await resolveFixtureClass('RoomLight');
  final field = clazz.getField(fieldName)!;
  final reader = _controlReader(field);
  final order = _controlOrder(clazz, fieldName);

  return MetaBuilder.controlMetaJson(
    reader,
    fieldName: field.name,
    order: order,
  );
}

int _controlOrder(ClassElement clazz, String fieldName) {
  var order = 0;
  for (final field in clazz.fields) {
    if (field.isStatic || field.isSynthetic) {
      continue;
    }
    if (!_hasControlAnnotation(field)) {
      continue;
    }
    order++;
    if (field.name == fieldName) {
      return order;
    }
  }
  throw StateError('Control field $fieldName not found.');
}

bool _hasControlAnnotation(FieldElement field) {
  const inputChecker = TypeChecker.fromRuntime(InputControl);
  const outputChecker = TypeChecker.fromRuntime(OutputControl);
  return inputChecker.hasAnnotationOfExact(field) ||
      outputChecker.hasAnnotationOfExact(field);
}

ConstantReader _controlReader(FieldElement field) {
  const inputChecker = TypeChecker.fromRuntime(InputControl);
  const outputChecker = TypeChecker.fromRuntime(OutputControl);

  final annotation = inputChecker.firstAnnotationOfExact(field) ??
      outputChecker.firstAnnotationOfExact(field);
  if (annotation == null) {
    throw StateError('Field ${field.name} has no control annotation.');
  }

  return ConstantReader(annotation);
}
