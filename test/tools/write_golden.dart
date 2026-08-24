import 'dart:io';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:wb_annatation/wb_annatation.dart';
import 'package:wb_generate/src/generator/wb_device_generator.dart';

import '../support/analysis.dart';

Future<void> main() async {
  final clazz = await resolveFixtureClass('RoomLight');
  final annotation = ConstantReader(
    const TypeChecker.fromRuntime(
      VirtualDevice,
    ).firstAnnotationOfExact(clazz)!,
  );
  final output = await WbDeviceGenerator().generateForAnnotatedElement(
    clazz,
    annotation,
    _Fake(),
  );
  File('test/goldens/room_light.core.golden').writeAsStringSync(output!);
}

class _Fake implements BuildStep {
  @override
  AssetId get inputId => AssetId('wb_generate', 'test/fixtures/room_light.dart');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
