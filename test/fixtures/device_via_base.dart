import 'package:wb_sdk/wb_sdk.dart';

part 'device_via_base.wb.g.dart';

base class DeviceBase extends IDevice {
  DeviceBase({required this.name, this.title});

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

  @override
  void execute() {}
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
