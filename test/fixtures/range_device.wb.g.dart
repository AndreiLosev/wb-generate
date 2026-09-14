// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'range_device.dart';

mixin RangeDevicePartMixin on IDevice implements PartOfIDevice {
  @override
  late final IDevice device;

  @override
  void setDevice(IDevice device) {
    this.device = device;
  }

  @override
  Set<String> addInputs() => {'brightness/on', 'level/on'};

  @override
  Set<String> addOutputs() => {};

  @override
  Set<String> addDependencies() => {};

  @override
  Map<String, ControlMeta> addMeta() => {
    'brightness': ControlMeta(
      type: WbControlType.range,
      title: const WbLocalizedTitle(en: 'Brightness', ru: 'Яркость'),
      order: 1,
      min: 0,
      max: 255,
      readonly: false,
      hidden: false,
    ),
    'level': ControlMeta(
      type: WbControlType.range,
      title: const WbLocalizedTitle(en: 'Level', ru: 'Уровень'),
      order: 2,
      min: 0,
      max: 100,
      precision: 0.1,
      readonly: false,
      hidden: false,
    ),
  };

  @override
  Map<String, Object?> addRetains() => {};

  @override
  bool updateFields(String control, String payload) {
    final device = this as RangeDevice;
    switch (control) {
      case 'brightness':
        var value = WbValueCodec.decodeIntValue(payload);
        value = WbNumericBounds.normalizeInt(value, min: 0.0, max: 255.0);
        device.brightness = value;
        wbPublish(
          '$name/brightness',
          WbValueCodec.encode(value, WbControlType.range),
        );
        return true;
      case 'level':
        var value = WbValueCodec.decodeDoubleValue(payload);
        value = WbNumericBounds.normalizeDouble(
          value,
          min: 0.0,
          max: 100.0,
          precision: 0.1,
        );
        device.level = value;
        wbPublish(
          '$name/level',
          WbValueCodec.encode(value, WbControlType.range),
        );
        return true;
    }
    return false;
  }
}
