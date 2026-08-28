import 'package:wb_sdk/wb_sdk.dart';

part 'wo_switch_device.wb.g.dart';

@VirtualDevice()
class WoSwitchDevice with WoSwitchDeviceWbMixin implements IDevice {
  WoSwitchDevice({
    this.name = 'wo_switch_device',
    this.title = const WbLocalizedTitle(en: 'WO Switch Device'),
  });

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

  @InputControl(type: WbControlType.woSwitch)
  bool feedback = false;

  @OutputControl(type: WbControlType.woSwitch)
  bool relay = false;

  @override
  void execute() {}
}
