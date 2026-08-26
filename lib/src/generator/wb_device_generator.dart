import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:wb_annatation/wb_annatation.dart';

import 'meta_builder.dart';
import 'naming.dart';

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

    final className = element.name;
    final mixinName = '${className}WbMixin';
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
      ..writeln('  IDevice get _device => this as IDevice;')
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
      ..writeln(
        '  /// Публикует retained meta устройства, контролов и output values.',
      )
      ..writeln('  void init() {')
      ..writeln(
        "    WbClient.getInstanse().publish('\${_device.name}/meta', WbMetaJson.device(_device.title), retained: true);",
      )
      ..writeln()
      ..writeln('    for (final entry in _controlMetaJson.entries) {')
      ..writeln("      final topic = '\${_device.name}/\${entry.key}/meta';")
      ..writeln(
        '      WbClient.getInstanse().publish(topic, entry.value, retained: true);',
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
        ..writeln('    final device = this as $className;');
      if (control.hasAnyNormalization) {
        buffer.writeln('    var normalized = value;');
        _writeValueNormalization(buffer, control, '    ', 'normalized');
        buffer
          ..writeln('    device.${control.fieldName} = normalized;')
          ..writeln('    WbClient.getInstanse().publish(')
          ..writeln("      '\${_device.name}/${control.mqttName}',")
          ..writeln(
            '      WbValueCodec.encode(normalized, WbControlType.${control.typeEnumName}),',
          )
          ..writeln('      retained: ${control.retainedPublish},')
          ..writeln('    );')
          ..writeln('  }')
          ..writeln();
      } else {
        buffer
          ..writeln('    device.${control.fieldName} = value;')
          ..writeln('    WbClient.getInstanse().publish(')
          ..writeln("      '\${_device.name}/${control.mqttName}',")
          ..writeln(
            '      WbValueCodec.encode(value, WbControlType.${control.typeEnumName}),',
          )
          ..writeln('      retained: ${control.retainedPublish},')
          ..writeln('    );')
          ..writeln('  }')
          ..writeln();
      }
    }

    buffer
      ..writeln('  void updateField(WbMqttMessage mess) {')
      ..writeln('    final device = this as $className;')
      ..writeln("    final namePrefix = '\${_device.name}/';")
      ..writeln('    if (!mess.topic.startsWith(namePrefix)) {')
      ..writeln('      return;')
      ..writeln('    }')
      ..writeln('    switch (mess.topic.substring(namePrefix.length)) {');

    for (final control in controls) {
      final valueKeyword = control.needsMutableValue ? 'var' : 'final';
      buffer.writeln("      case '${control.mqttName}/on':");
      buffer.writeln(
        '        $valueKeyword value = '
        'WbValueCodec.decode(mess.payload, WbControlType.${control.typeEnumName}) '
        'as ${control.dartTypeName};',
      );
      _writeValueNormalization(buffer, control, '        ', 'value');
      buffer
        ..writeln('        device.${control.fieldName} = value;')
        ..writeln('        WbClient.getInstanse().publish(')
        ..writeln("          '\${_device.name}/${control.mqttName}',")
        ..writeln(
          '          WbValueCodec.encode(value, WbControlType.${control.typeEnumName}),',
        )
        ..writeln('          retained: ${control.retainedPublish},')
        ..writeln('        );')
        ..writeln('        return;');
    }

    buffer
      ..writeln('    }')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Set<String> inputs() => {');

    for (final control in inputControls) {
      buffer.writeln("    '\${_device.name}/${control.mqttName}/on',");
    }

    buffer
      ..writeln('  };')
      ..writeln()
      ..writeln('  Set<String> outputs() => {');

    for (final control in outputControls) {
      buffer.writeln("    '\${_device.name}/${control.mqttName}/on',");
    }

    buffer.writeln('  };');
    buffer.writeln('}');

    return buffer.toString();
  }

  List<_ControlInfo> _readControls(ClassElement classElement) {
    final controls = <_ControlInfo>[];
    var order = 0;

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

      order++;
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
          retainedPublish: controlType != WbControlType.pushbutton,
          min: reader.peek('min')?.doubleValue,
          max: reader.peek('max')?.doubleValue,
          precision: reader.peek('precision')?.doubleValue,
          enumAllowedKeys: _readEnumAllowedKeys(reader),
          metaJson: MetaBuilder.controlMetaJson(
            reader,
            fieldName: field.name,
            order: order,
          ),
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

  List<String>? _readEnumAllowedKeys(ConstantReader reader) {
    final enumTitles = reader.peek('enumTitles');
    if (enumTitles == null || enumTitles.isNull) {
      return null;
    }

    return enumTitles.mapValue.keys
        .map((key) => key!.toStringValue()!)
        .toList();
  }

  void _writeValueNormalization(
    StringBuffer buffer,
    _ControlInfo control,
    String indent,
    String valueVar,
  ) {
    if (control.enumAllowedKeys != null) {
      final keys = control.enumAllowedKeys!
          .map((key) => "'${_escapeDartString(key)}'")
          .join(', ');
      buffer.writeln(
        '$indent if (!const {$keys}.contains($valueVar)) return;',
      );
    }

    if (!control.hasNumericNormalization) {
      return;
    }

    final method =
        control.dartTypeName == 'int' ? 'normalizeInt' : 'normalizeDouble';
    final params = <String>[];
    if (control.min != null) {
      params.add('min: ${control.min}');
    }
    if (control.max != null) {
      params.add('max: ${control.max}');
    }
    if (control.precision != null) {
      params.add('precision: ${control.precision}');
    }

    buffer.writeln(
      '$indent $valueVar = WbNumericBounds.$method($valueVar, ${params.join(', ')});',
    );
  }
}

class _ControlInfo {
  const _ControlInfo({
    required this.direction,
    required this.fieldName,
    required this.mqttName,
    required this.typeEnumName,
    required this.dartTypeName,
    required this.retainedPublish,
    this.min,
    this.max,
    this.precision,
    this.enumAllowedKeys,
    required this.metaJson,
  });

  final _ControlDirection direction;
  final String fieldName;
  final String mqttName;
  final String typeEnumName;
  final String dartTypeName;
  final bool retainedPublish;
  final double? min;
  final double? max;
  final double? precision;
  final List<String>? enumAllowedKeys;
  final String metaJson;

  bool get hasNumericNormalization {
    if (dartTypeName != 'int' && dartTypeName != 'double') {
      return false;
    }

    return min != null || max != null || precision != null;
  }

  bool get hasAnyNormalization =>
      enumAllowedKeys != null || hasNumericNormalization;

  bool get needsMutableValue => hasNumericNormalization;
}
