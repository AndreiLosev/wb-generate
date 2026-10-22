import 'package:wb_sdk/wb_sdk.dart';

@VirtualDevice()
base class ChildVirtualDevice extends PlainDeviceBase {
  ChildVirtualDevice({required this.name}) {
    register(this);
  }

  @override
  final String name;

  @InputControl(type: WbControlType.switch_)
  bool switchState = false;

  @override
  void execute([String? topic]) {}
}

base class PlainDeviceBase extends IDevice {
  PlainDeviceBase({required this.name});

  @override
  final String name;

  @override
  WbLocalizedTitle? get title => null;

  @override
  void execute([String? topic]) {}
}
