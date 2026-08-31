// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_title_samples.dart';

mixin ControlTitleSamplesPartMixin on IDevice implements PartOfIDevice {
  @override
  late final IDevice device;

  @override
  void setDevice(IDevice device) {
    this.device = device;
  }

  @override
  Set<String> addInputs() => {'wall_switch/on', 'kitchen_switch/on'};

  @override
  Set<String> addOutputs() => {};

  @override
  Map<String, Map<String, dynamic>> addMeta() => {
    'wall_switch': {
      'type': 'switch',
      'title': {'en': 'wall_switch'},
      'order': 1,
      'readonly': false,
      'hidden': false,
    },
    'kitchen_switch': {
      'type': 'switch',
      'title': {'en': 'kitchen_switch', 'ru': 'Выключатель'},
      'order': 2,
      'readonly': false,
      'hidden': false,
    },
  };

  @override
  Map<String, Object?> addRetains() => {};

  @override
  UpdateFieldFn? addUpdateFields() => _updateField;

  bool _updateField(String control, String payload) {
    final device = this as ControlTitleSamples;
    switch (control) {
      case 'wall_switch':
        final value =
            WbValueCodec.decode(payload, WbControlType.switch_) as bool;
        device.wallSwitch = value;
        wbPublish(
          '$name/wall_switch',
          WbValueCodec.encode(value, WbControlType.switch_),
          retained: true,
        );
        return true;
      case 'kitchen_switch':
        final value =
            WbValueCodec.decode(payload, WbControlType.switch_) as bool;
        device.kitchenSwitch = value;
        wbPublish(
          '$name/kitchen_switch',
          WbValueCodec.encode(value, WbControlType.switch_),
          retained: true,
        );
        return true;
    }
    return false;
  }
}
