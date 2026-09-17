import 'dart:io';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:wb_sdk/wb_sdk.dart';
import 'package:wb_generate/src/generator/wb_device_generator.dart';

import 'support/analysis.dart';

void main() {
  test('генерирует RoomLightPartMixin', () async {
    final clazz = await resolveFixtureClass('RoomLight');
    final annotation = ConstantReader(
      const TypeChecker.typeNamed(
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

  test('генерирует addDependencies из @VirtualDevice(dependencies: ...)', () async {
    final clazz = await resolveFixtureClass('RoomLightWithDeps');
    final annotation = ConstantReader(
      const TypeChecker.typeNamed(
        VirtualDevice,
      ).firstAnnotationOfExact(clazz)!,
    );

    final generator = WbDeviceGenerator();
    final output = await generator.generateForAnnotatedElement(
      clazz,
      annotation,
      _FakeBuildStep(path: 'test/fixtures/room_light_with_deps.dart'),
    );

    final golden = normalizeGenerated(
      File('test/goldens/room_light_with_deps.core.golden').readAsStringSync(),
    );
    expect(normalizeGenerated(output!), golden);
  });

  test('генерирует RangeDevicePartMixin с int и double range', () async {
    final clazz = await resolveFixtureClass('RangeDevice');
    final annotation = ConstantReader(
      const TypeChecker.typeNamed(
        VirtualDevice,
      ).firstAnnotationOfExact(clazz)!,
    );

    final generator = WbDeviceGenerator();
    final output = await generator.generateForAnnotatedElement(
      clazz,
      annotation,
      _FakeBuildStep(path: 'test/fixtures/range_device.dart'),
    );

    final golden = normalizeGenerated(
      File('test/goldens/range_device.core.golden').readAsStringSync(),
    );
    expect(normalizeGenerated(output!), golden);
  });

  test('генерирует ReverseInputDevicePartMixin с reverse', () async {
    final clazz = await resolveFixtureClass('ReverseInputDevice');
    final annotation = ConstantReader(
      const TypeChecker.typeNamed(
        VirtualDevice,
      ).firstAnnotationOfExact(clazz)!,
    );

    final generator = WbDeviceGenerator();
    final output = await generator.generateForAnnotatedElement(
      clazz,
      annotation,
      _FakeBuildStep(path: 'test/fixtures/reverse_input_device.dart'),
    );

    final golden = normalizeGenerated(
      File('test/goldens/reverse_input_device.core.golden').readAsStringSync(),
    );
    expect(normalizeGenerated(output!), golden);
  });

  test('reverse только для switch, wo-switch и alarm', () async {
    final clazz = await resolveFixtureClass('ReverseInputInvalid');
    final annotation = ConstantReader(
      const TypeChecker.typeNamed(
        VirtualDevice,
      ).firstAnnotationOfExact(clazz)!,
    );

    final generator = WbDeviceGenerator();
    expect(
      () => generator.generateForAnnotatedElement(
        clazz,
        annotation,
        _FakeBuildStep(path: 'test/fixtures/reverse_input_invalid.dart'),
      ),
      throwsA(isA<InvalidGenerationSourceError>()),
    );
  });

  test('генерирует DeviceBasePartMixin на IDevice', () async {
    final clazz = await resolveFixtureClass('DeviceBase');
    final annotation = ConstantReader(
      const TypeChecker.typeNamed(
        VirtualDevice,
      ).firstAnnotationOfExact(clazz)!,
    );

    final generator = WbDeviceGenerator();
    final output = await generator.generateForAnnotatedElement(
      clazz,
      annotation,
      _FakeBuildStep(path: 'test/fixtures/device_via_base.dart'),
    );

    final golden = normalizeGenerated(
      File('test/goldens/device_base.core.golden').readAsStringSync(),
    );
    expect(normalizeGenerated(output!), golden);
  });

  test('генерирует DeviceViaBasePartMixin через базовый класс', () async {
    final clazz = await resolveFixtureClass('DeviceViaBase');
    final annotation = ConstantReader(
      const TypeChecker.typeNamed(
        VirtualDevice,
      ).firstAnnotationOfExact(clazz)!,
    );

    final generator = WbDeviceGenerator();
    final output = await generator.generateForAnnotatedElement(
      clazz,
      annotation,
      _FakeBuildStep(path: 'test/fixtures/device_via_base.dart'),
    );

    final golden = normalizeGenerated(
      File('test/goldens/device_via_base.core.golden').readAsStringSync(),
    );
    expect(normalizeGenerated(output!), golden);
  });

  test('требует @VirtualDevice у родителя при непрямом extends IDevice', () async {
    final clazz = await resolveFixtureClass('ChildVirtualDevice');
    final annotation = ConstantReader(
      const TypeChecker.typeNamed(
        VirtualDevice,
      ).firstAnnotationOfExact(clazz)!,
    );

    final generator = WbDeviceGenerator();
    expect(
      () => generator.generateForAnnotatedElement(
        clazz,
        annotation,
        _FakeBuildStep(path: 'test/fixtures/device_child_invalid_parent.dart'),
      ),
      throwsA(isA<InvalidGenerationSourceError>()),
    );
  });

  test('требует extends IDevice', () async {
    final clazz = await resolveFixtureClass('MissingDevice');
    final annotation = ConstantReader(
      const TypeChecker.typeNamed(
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
