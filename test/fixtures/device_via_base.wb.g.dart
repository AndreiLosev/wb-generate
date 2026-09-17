// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_via_base.dart';

mixin DeviceBasePartMixin on IDevice implements PartOfIDevice {
  @override
  late final IDevice device;

  @override
  void setDevice(IDevice device) {
    this.device = device;
  }

  @override
  Set<String> addInputs() => {
    'base_switch/on',
  };

  @override
  Set<String> addOutputs() => {};

  @override
  Set<String> addDependencies() => {};

  @override
  Map<String, ControlMeta> addMeta() => {
    'base_switch': ControlMeta(
      type: WbControlType.switch_,
      title: const WbLocalizedTitle(en: 'base_switch'),
      order: 1,
      readonly: false,
      hidden: false,
    ),
  };

  @override
  Map<String, Object?> addRetains() => {};

  @override
  bool updateFields(String control, String payload) {
    final device = this as DeviceBase;
    switch (control) {
      case 'base_switch':
        final value = WbValueCodec.decode(payload, WbControlType.switch_) as bool;
        device.baseSwitch = value;
        wbPublish(
          '$name/base_switch',
          WbValueCodec.encode(value, WbControlType.switch_),
        );
        return true;
    }
    return false;
  }

}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_via_base.dart';

mixin DeviceViaBasePartMixin on DeviceBase implements PartOfIDevice {
  @override
  Set<String> addInputs() => super.addInputs()
    ..addAll({
      'switch_state/on',
    });

  @override
  Set<String> addOutputs() => super.addOutputs();

  @override
  Set<String> addDependencies() => super.addDependencies();

  @override
  Map<String, ControlMeta> addMeta() => {
    ...super.addMeta(),
    'switch_state': ControlMeta(
      type: WbControlType.switch_,
      title: const WbLocalizedTitle(en: 'switch_state'),
      order: 1,
      readonly: false,
      hidden: false,
    ),
  };

  @override
  Map<String, Object?> addRetains() => super.addRetains();

  @override
  bool updateFields(String control, String payload) {
    final device = this as DeviceViaBase;
    switch (control) {
      case 'switch_state':
        final value = WbValueCodec.decode(payload, WbControlType.switch_) as bool;
        device.switchState = value;
        wbPublish(
          '$name/switch_state',
          WbValueCodec.encode(value, WbControlType.switch_),
        );
        return true;
    }
    return super.updateFields(control, payload);
  }

}

