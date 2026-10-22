import 'package:wb_sdk/wb_sdk.dart';

part 'wo_switch_device.wb.g.dart';

@VirtualDevice()
base class WoSwitchDevice extends IDevice with WoSwitchDevicePartMixin {
  WoSwitchDevice({
    this.name = 'wo_switch_device',
    this.title = const WbLocalizedTitle(en: 'WO Switch Device'),
  }) {
    register(this);
  }

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

  @InputControl(type: WbControlType.woSwitch)
  bool feedback = false;

  @OutputControl(type: WbControlType.woSwitch)
  bool relay = false;

  @override
  void execute([String? topic]) {}
}
