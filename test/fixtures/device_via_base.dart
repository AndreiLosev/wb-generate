import 'package:wb_sdk/wb_sdk.dart';

part 'device_via_base.wb.g.dart';

@VirtualDevice()
base class DeviceBase extends IDevice with DeviceBasePartMixin {
  DeviceBase({required this.name, this.title}) {
    register(this);
  }

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

  @InputControl(type: WbControlType.switch_)
  bool baseSwitch = false;

  @override
  void execute([String? topic]) {}
}

@VirtualDevice()
base class DeviceViaBase extends DeviceBase with DeviceViaBasePartMixin {
  DeviceViaBase({
    super.name = 'device_via_base',
    super.title = const WbLocalizedTitle(en: 'Device Via Base'),
  }) {
    register(this);
  }

  @InputControl(type: WbControlType.switch_)
  bool switchState = false;
}
