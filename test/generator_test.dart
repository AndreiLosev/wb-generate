import 'dart:io';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:wb_sdk/wb_sdk.dart';
import 'package:wb_generate/src/generator/wb_device_generator.dart';

import 'support/analysis.dart';

void main() {
  test('генерирует RoomLightWbMixin', () async {
    final clazz = await resolveFixtureClass('RoomLight');
    final annotation = ConstantReader(
      const TypeChecker.fromRuntime(
        VirtualDevice,
      ).firstAnnotationOfExact(clazz)!,
    );

    final generator = WbDeviceGenerator();
    final output = await generator.generateForAnnotatedElement(
      clazz,
      annotation,
      _FakeBuildStep(),
    );

    final golden = normalizeGenerated(
      File('test/goldens/room_light.core.golden').readAsStringSync(),
    );
    expect(normalizeGenerated(output!), golden);
  });

  test('требует implements IDevice', () async {
    final clazz = await resolveFixtureClass('MissingDevice');
    final annotation = ConstantReader(
      const TypeChecker.fromRuntime(
        VirtualDevice,
      ).firstAnnotationOfExact(clazz)!,
    );

    final generator = WbDeviceGenerator();
    expect(
      () => generator.generateForAnnotatedElement(
        clazz,
        annotation,
        _FakeBuildStep(path: 'test/fixtures/missing_idevice.dart'),
      ),
      throwsA(isA<InvalidGenerationSourceError>()),
    );
  });
}

class _FakeBuildStep implements BuildStep {
  _FakeBuildStep({this.path = 'test/fixtures/room_light.dart'});

  final String path;

  @override
  AssetId get inputId => AssetId('wb_generate', path);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
