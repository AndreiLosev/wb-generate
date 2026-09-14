// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reverse_input_device.dart';

mixin ReverseInputDevicePartMixin on IDevice implements PartOfIDevice {
  @override
  late final IDevice device;

  @override
  void setDevice(IDevice device) {
    this.device = device;
  }

  @override
  Set<String> addInputs() => {'feedback/on'};

  @override
  Set<String> addOutputs() => {};

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
  };

  @override
  Map<String, Object?> addRetains() => {};

  @override
  bool updateFields(String control, String payload) {
    final device = this as ReverseInputDevice;
    switch (control) {
      case 'feedback':
        var value =
            WbValueCodec.decode(payload, WbControlType.woSwitch) as bool;
        value = !value;
        device.feedback = value;
        wbPublish(
          '$name/feedback',
          WbValueCodec.encode(value, WbControlType.woSwitch),
        );
        return true;
    }
    return false;
  }
}
