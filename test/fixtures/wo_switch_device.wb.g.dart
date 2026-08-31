// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wo_switch_device.dart';

mixin WoSwitchDevicePartMixin on IDevice implements PartOfIDevice {
  @override
  late final IDevice device;

  @override
  void setDevice(IDevice device) {
    this.device = device;
  }

  @override
  Set<String> addInputs() => {'feedback/on'};

  @override
  Set<String> addOutputs() => {'relay/on'};

  @override
  Map<String, Map<String, dynamic>> addMeta() => {
    'feedback': {
      'type': 'wo-switch',
      'title': {'en': 'feedback'},
      'order': 1,
      'readonly': false,
      'hidden': false,
    },
    'relay': {
      'type': 'wo-switch',
      'title': {'en': 'relay'},
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
    final device = this as WoSwitchDevice;
    switch (control) {
      case 'feedback':
        final value =
            WbValueCodec.decode(payload, WbControlType.woSwitch) as bool;
        device.feedback = value;
        wbPublish(
          '$name/feedback',
          WbValueCodec.encode(value, WbControlType.woSwitch),
          retained: true,
        );
        return true;
      case 'relay':
        final value =
            WbValueCodec.decode(payload, WbControlType.woSwitch) as bool;
        device.relay = value;
        wbPublish(
          '$name/relay',
          WbValueCodec.encode(value, WbControlType.woSwitch),
          retained: true,
        );
        return true;
    }
    return false;
  }

  void setRelay(bool value) {
    final device = this as WoSwitchDevice;
    device.relay = value;
    wbPublish(
      '$name/relay',
      WbValueCodec.encode(value, WbControlType.woSwitch),
      retained: true,
    );
  }
}
