import 'package:wb_sdk/wb_sdk.dart';

part 'reverse_input_device.wb.g.dart';

@VirtualDevice()
base class ReverseInputDevice extends IDevice with ReverseInputDevicePartMixin {
  ReverseInputDevice({
    this.name = 'reverse_input_device',
    this.title = const WbLocalizedTitle(en: 'Reverse Input Device'),
  }) {
    register(this);
  }

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

  @InputControl(type: WbControlType.woSwitch, reverse: true)
  bool feedback = false;

  @override
  void execute() {}
}
