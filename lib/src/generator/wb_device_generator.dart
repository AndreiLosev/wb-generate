import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:wb_annatation/wb_annatation.dart';

import 'meta_builder.dart';
import 'naming.dart';

const _deviceTopicPrefix = '/devices';

enum _ControlDirection { input, output }

class WbDeviceGenerator extends GeneratorForAnnotation<VirtualDevice> {
  static const _inputChecker = TypeChecker.fromRuntime(InputControl);
  static const _outputChecker = TypeChecker.fromRuntime(OutputControl);
  static const _iDeviceChecker = TypeChecker.fromRuntime(IDevice);

  @override
  FutureOr<String?> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@VirtualDevice can only be applied to classes.',
        element: element,
      );
    }

    if (!_iDeviceChecker.isAssignableFromType(element.thisType)) {
      throw InvalidGenerationSourceError(
        '@VirtualDevice class must implement IDevice.',
        element: element,
      );
    }

    final controls = _readControls(element);
    if (controls.isEmpty) {
      throw InvalidGenerationSourceError(
        '@VirtualDevice class must have at least one '
        '@InputControl or @OutputControl field.',
        element: element,
      );
    }

    final deviceName = annotation.read('name').stringValue;
    final className = element.name;
    final mixinName = '${className}WbMixin';
    final deviceMetaJson = MetaBuilder.deviceMetaJson(annotation);
    final importPath = p.basename(buildStep.inputId.path);

    final inputControls = controls
        .where((c) => c.direction == _ControlDirection.input)
        .toList();
    final outputControls = controls
        .where((c) => c.direction == _ControlDirection.output)
        .toList();

    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln("part of '$importPath';")
      ..writeln()
      ..writeln('mixin $mixinName {')
      ..writeln("  static const String deviceName = '$deviceName';")
      ..writeln()
      ..writeln("  static const String _deviceMetaTopic =")
      ..writeln("      '$_deviceTopicPrefix/$deviceName/meta';")
      ..writeln()
      ..writeln("  static const String _deviceMetaJson =")
      ..writeln("      '${_escapeDartString(deviceMetaJson)}';")
      ..writeln()
      ..writeln('  static const Map<String, String> _controlMetaJson = {');

    for (final control in controls) {
      buffer.writeln(
        "    '${control.mqttName}': '${_escapeDartString(control.metaJson)}',",
      );
    }

    buffer
      ..writeln('  };')
      ..writeln()
      ..writeln('  static const Set<String> _inputTopics = {');

    for (final control in inputControls) {
      buffer.writeln(
        "    '$_deviceTopicPrefix/$deviceName/controls/${control.mqttName}',",
      );
    }

    buffer
      ..writeln('  };')
      ..writeln()
      ..writeln('  static const Set<String> _outputTopics = {');

    for (final control in outputControls) {
      buffer.writeln(
        "    '$_deviceTopicPrefix/$deviceName/controls/${control.mqttName}',",
      );
    }

    buffer
      ..writeln('  };')
      ..writeln()
      ..writeln('  static const Map<String, String> _outputValueTopics = {');

    for (final control in outputControls) {
      buffer.writeln(
        "    '${control.mqttName}': "
        "'$_deviceTopicPrefix/$deviceName/controls/${control.mqttName}',",
      );
    }

    buffer
      ..writeln('  };')
      ..writeln()
      ..writeln(
        '  /// Публикует retained meta устройства, контролов и output values.',
      )
      ..writeln('  void init() {')
      ..writeln(
        '    (this as $className).mqtt.publish(_deviceMetaTopic, _deviceMetaJson, retained: true);',
      )
      ..writeln()
      ..writeln('    for (final entry in _controlMetaJson.entries) {')
      ..writeln(
        "      final topic = "
        "'$_deviceTopicPrefix/$deviceName/controls/\${entry.key}/meta';",
      )
      ..writeln(
        '      (this as $className).mqtt.publish(topic, entry.value, retained: true);',
      )
      ..writeln('    }')
      ..writeln();

    for (final control in outputControls) {
      buffer.writeln(
        '    ${toSetterName(control.fieldName)}((this as $className).${control.fieldName});',
      );
    }

    buffer.writeln('  }');
    buffer.writeln();

    for (final control in outputControls) {
      final setterName = toSetterName(control.fieldName);
      buffer
        ..writeln('  void $setterName(${control.dartTypeName} value) {')
        ..writeln('    final device = this as $className;')
        ..writeln('    device.${control.fieldName} = value;')
        ..writeln('    device.mqtt.publish(')
        ..writeln("      _outputValueTopics['${control.mqttName}']!,")
        ..writeln(
          '      WbValueCodec.encode(value, WbControlType.${control.typeEnumName}),',
        )
        ..writeln('      retained: true,')
        ..writeln('    );')
        ..writeln('  }')
        ..writeln();
    }

    buffer
      ..writeln('  Set<String> inputs() => _inputTopics;')
      ..writeln()
      ..writeln('  Set<String> outputs() => _outputTopics;')
      ..writeln('}');

    return buffer.toString();
  }

  List<_ControlInfo> _readControls(ClassElement classElement) {
    final controls = <_ControlInfo>[];

    for (final field in classElement.fields) {
      if (field.isStatic || field.isSynthetic) {
        continue;
      }

      final direction = _controlDirection(field);
      if (direction == null) {
        continue;
      }

      final annotation = direction == _ControlDirection.input
          ? _inputChecker.firstAnnotationOfExact(field)
          : _outputChecker.firstAnnotationOfExact(field);
      if (annotation == null) {
        continue;
      }

      final reader = ConstantReader(annotation);
      final type = reader.read('type');
      final mqttType = type.peek('mqttValue')!.stringValue;
      final controlType = WbControlType.values.firstWhere(
        (value) => value.mqttValue == mqttType,
      );
      final typeEnumName = controlType.name;
      final dartType = field.type;
      _validateFieldType(field, dartType, controlType);

      final mqttName =
          reader.peek('name')?.stringValue ?? toSnakeCase(field.name);
      final readonly = reader.read('readonly').boolValue;

      if (field.isFinal) {
        throw InvalidGenerationSourceError(
          'Field "${field.name}" is final but must be writable by the driver.',
          element: field,
        );
      }

      controls.add(
        _ControlInfo(
          direction: direction,
          fieldName: field.name,
          mqttName: mqttName,
          typeEnumName: typeEnumName,
          dartTypeName: dartType.getDisplayString(withNullability: false),
          readonly: readonly,
          isFinal: field.isFinal,
          metaJson: MetaBuilder.controlMetaJson(reader, fieldName: field.name),
        ),
      );
    }

    return controls;
  }

  _ControlDirection? _controlDirection(FieldElement field) {
    if (_inputChecker.hasAnnotationOfExact(field)) {
      return _ControlDirection.input;
    }
    if (_outputChecker.hasAnnotationOfExact(field)) {
      return _ControlDirection.output;
    }
    return null;
  }

  void _validateFieldType(
    FieldElement field,
    DartType dartType,
    WbControlType controlType,
  ) {
    final displayType = dartType.getDisplayString(withNullability: false);
    final isValid = switch (controlType) {
      WbControlType.switch_ ||
      WbControlType.woSwitch ||
      WbControlType.alarm ||
      WbControlType.pushbutton => displayType == 'bool',
      WbControlType.range ||
      WbControlType.unixtime ||
      WbControlType.w1Id => displayType == 'int',
      WbControlType.value => displayType == 'int' || displayType == 'double',
      WbControlType.rgb || WbControlType.text => displayType == 'String',
    };

    if (!isValid) {
      throw InvalidGenerationSourceError(
        'Field "${field.name}" has type $displayType which is incompatible '
        'with WbControlType.$controlType.',
        element: field,
      );
    }
  }

  String _escapeDartString(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$');
  }
}

class _ControlInfo {
  const _ControlInfo({
    required this.direction,
    required this.fieldName,
    required this.mqttName,
    required this.typeEnumName,
    required this.dartTypeName,
    required this.readonly,
    required this.isFinal,
    required this.metaJson,
  });

  final _ControlDirection direction;
  final String fieldName;
  final String mqttName;
  final String typeEnumName;
  final String dartTypeName;
  final bool readonly;
  final bool isFinal;
  final String metaJson;
}
