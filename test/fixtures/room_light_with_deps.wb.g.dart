// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_light_with_deps.dart';

mixin RoomLightWithDepsPartMixin on IDevice implements PartOfIDevice {
  @override
  late final IDevice device;

  @override
  void setDevice(IDevice device) {
    this.device = device;
  }

  String get switchStateControl => '$name/switch_state';

  @override
  Set<String> addInputs() => {'switch_state/on'};

  @override
  Set<String> addOutputs() => {};

  @override
  Set<String> addDependencies() => {'sensor/temp/on', '+/meta'};

  @override
  Map<String, ControlMeta> addMeta() => {
    'switch_state': ControlMeta(
      type: WbControlType.switch_,
      title: const WbLocalizedTitle(en: 'Switch', ru: 'Выключатель'),
      order: 1,
      readonly: false,
      hidden: false,
    ),
  };

  @override
  Map<String, Object?> addRetains() => {};

  @override
  bool updateFields(String control, String payload) {
    final device = this as RoomLightWithDeps;
    switch (control) {
      case 'switch_state':
        final value =
            WbValueCodec.decode(payload, WbControlType.switch_) as bool;
        device.switchState = value;
        wbPublish(
          '$name/switch_state',
          WbValueCodec.encode(value, WbControlType.switch_),
        );
        return true;
    }
    return false;
  }
}
