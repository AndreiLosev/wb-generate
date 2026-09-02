// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

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
  Set<String> addDependencies() => {};

  @override
  Map<String, ControlMeta> addMeta() => {
    'feedback': ControlMeta(
      type: WbControlType.woSwitch,
      title: const WbLocalizedTitle(en: 'feedback'),
      order: 1,
      readonly: false,
      hidden: false,
    ),
    'relay': ControlMeta(
      type: WbControlType.woSwitch,
      title: const WbLocalizedTitle(en: 'relay'),
      order: 2,
      readonly: false,
      hidden: false,
    ),
  };

  @override
  Map<String, Object?> addRetains() => {};

  @override
  bool updateFields(String control, String payload) {
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
