import 'package:wb_annatation/wb_annatation.dart';

part 'wo_switch_device.wb.g.dart';

@VirtualDevice(
  name: 'wo_switch_device',
  title: WbLocalizedTitle(en: 'WO Switch Device'),
)
class WoSwitchDevice with WoSwitchDeviceWbMixin implements IDevice {
  WoSwitchDevice();

  @InputControl(type: WbControlType.woSwitch)
  bool feedback = false;

  @OutputControl(type: WbControlType.woSwitch)
  bool relay = false;

  @override
  void execute() {}
}
