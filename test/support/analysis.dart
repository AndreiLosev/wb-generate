import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:path/path.dart' as p;

Future<ClassElement> resolveFixtureClass(String className) async {
  final root = p.normalize(Directory.current.path);
  final fixturePath = switch (className) {
    'RoomLight' => p.join(root, 'test', 'fixtures', 'room_light.dart'),
    'ControlTitleSamples' =>
      p.join(root, 'test', 'fixtures', 'control_title_samples.dart'),
    'MissingDevice' =>
      p.join(root, 'test', 'fixtures', 'missing_idevice.dart'),
    'WoSwitchDevice' =>
      p.join(root, 'test', 'fixtures', 'wo_switch_device.dart'),
    'RoomLightWithDeps' =>
      p.join(root, 'test', 'fixtures', 'room_light_with_deps.dart'),
    'RangeDevice' => p.join(root, 'test', 'fixtures', 'range_device.dart'),
    'ReverseInputDevice' =>
      p.join(root, 'test', 'fixtures', 'reverse_input_device.dart'),
    'ReverseInputInvalid' =>
      p.join(root, 'test', 'fixtures', 'reverse_input_invalid.dart'),
    'DeviceViaBase' =>
      p.join(root, 'test', 'fixtures', 'device_via_base.dart'),
    'DeviceBase' => p.join(root, 'test', 'fixtures', 'device_via_base.dart'),
    'ChildVirtualDevice' =>
      p.join(root, 'test', 'fixtures', 'device_child_invalid_parent.dart'),
    _ => throw ArgumentError('Unknown fixture class: $className'),
  };
  final collection = AnalysisContextCollection(
    includedPaths: [root],
  );
  final session = collection.contextFor(fixturePath).currentSession;
  final result = await session.getResolvedUnit(fixturePath);
  if (result is! ResolvedUnitResult) {
    throw StateError('Failed to resolve $fixturePath');
  }

  return result.libraryElement.getClass(className)!;
}

String normalizeGenerated(String source) {
  return source
      .split('\n')
      .where(
        (line) =>
            !line.startsWith('// dart format') &&
            !line.startsWith('// ****') &&
            line.trim() != '// WbDeviceGenerator',
      )
      .join('\n')
      .trim();
}
