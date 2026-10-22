import 'package:wb_sdk/wb_sdk.dart';

part 'range_device.wb.g.dart';

@VirtualDevice()
base class RangeDevice extends IDevice with RangeDevicePartMixin {
  RangeDevice({
    this.name = 'range_device',
    this.title = const WbLocalizedTitle(en: 'Range Device'),
  }) {
    register(this);
  }

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

  @InputControl(
    type: WbControlType.range,
    min: 0,
    max: 255,
    title: WbLocalizedTitle(en: 'Brightness', ru: 'Яркость'),
  )
  int brightness = 0;

  @InputControl(
    type: WbControlType.range,
    min: 0,
    max: 100,
    precision: 0.1,
    title: WbLocalizedTitle(en: 'Level', ru: 'Уровень'),
  )
  double level = 0;

  @override
  void execute([String? topic]) {}
}
