// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_light.dart';

mixin RoomLightPartMixin on IDevice implements PartOfIDevice {
  @override
  late final IDevice device;

  @override
  void setDevice(IDevice device) {
    this.device = device;
  }

  @override
  Set<String> addInputs() => {'switch_state/on', 'power/on'};

  @override
  Set<String> addOutputs() => {'lamp/on', 'mode/on'};

  @override
  Map<String, ControlMeta> addMeta() => {
    'switch_state': ControlMeta(
      type: WbControlType.switch_,
      title: const WbLocalizedTitle(en: 'Switch', ru: 'Выключатель'),
      order: 1,
      readonly: false,
      hidden: false,
    ),
    'lamp': ControlMeta(
      type: WbControlType.switch_,
      title: const WbLocalizedTitle(en: 'Lamp', ru: 'Лампа'),
      order: 2,
      readonly: false,
      hidden: false,
    ),
    'power': ControlMeta(
      type: WbControlType.value,
      title: const WbLocalizedTitle(en: 'Power', ru: 'Мощность'),
      order: 3,
      units: 'W',
      min: 0,
      max: 5000,
      precision: 0.1,
      readonly: true,
      hidden: false,
    ),
    'mode': ControlMeta(
      type: WbControlType.text,
      title: const WbLocalizedTitle(en: 'Mode', ru: 'Режим'),
      order: 4,
      readonly: false,
      hidden: false,
      enumTitles: {
        '0': const WbLocalizedTitle(en: 'Off', ru: 'Выкл'),
        '1': const WbLocalizedTitle(en: 'On', ru: 'Вкл'),
      },
    ),
  };

  @override
  Map<String, Object?> addRetains() => {'mode': '0'};

  @override
  bool updateFields(String control, String payload) {
    final device = this as RoomLight;
    switch (control) {
      case 'switch_state':
        final value =
            WbValueCodec.decode(payload, WbControlType.switch_) as bool;
        device.switchState = value;
        wbPublish(
          '$name/switch_state',
          WbValueCodec.encode(value, WbControlType.switch_),
          retained: true,
        );
        return true;
      case 'lamp':
        final value =
            WbValueCodec.decode(payload, WbControlType.switch_) as bool;
        device.lamp = value;
        wbPublish(
          '$name/lamp',
          WbValueCodec.encode(value, WbControlType.switch_),
          retained: true,
        );
        return true;
      case 'power':
        var value = WbValueCodec.decodeDoubleValue(payload);
        value = WbNumericBounds.normalizeDouble(
          value,
          min: 0.0,
          max: 5000.0,
          precision: 0.1,
        );
        device.power = value;
        wbPublish(
          '$name/power',
          WbValueCodec.encode(value, WbControlType.value),
          retained: true,
        );
        return true;
      case 'mode':
        final value =
            WbValueCodec.decode(payload, WbControlType.text) as String;
        if (!const {'0', '1'}.contains(value)) return true;
        if (device.mode != value) {
          WbHiveStorage.getInstanse().put('$name.mode', value);
        }
        device.mode = value;
        wbPublish(
          '$name/mode',
          WbValueCodec.encode(value, WbControlType.text),
          retained: true,
        );
        return true;
    }
    return false;
  }

  void setLamp(bool value) {
    final device = this as RoomLight;
    device.lamp = value;
    wbPublish(
      '$name/lamp',
      WbValueCodec.encode(value, WbControlType.switch_),
      retained: true,
    );
  }

  void setMode(String value) {
    final device = this as RoomLight;
    var normalized = value;
    if (!const {'0', '1'}.contains(normalized)) return;
    device.mode = normalized;
    wbPublish(
      '$name/mode',
      WbValueCodec.encode(normalized, WbControlType.text),
      retained: true,
    );
  }
}
