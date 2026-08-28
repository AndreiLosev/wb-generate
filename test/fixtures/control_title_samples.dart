import 'package:wb_sdk/wb_sdk.dart';

part 'control_title_samples.wb.g.dart';

@VirtualDevice()
class ControlTitleSamples with ControlTitleSamplesWbMixin implements IDevice {
  ControlTitleSamples({
    this.name = 'title_samples',
    this.title = const WbLocalizedTitle(en: 'Title Samples'),
  });

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

  @InputControl(type: WbControlType.switch_)
  bool wallSwitch = false;

  @InputControl(
    type: WbControlType.switch_,
    title: WbLocalizedTitle(ru: 'Выключатель'),
  )
  bool kitchenSwitch = false;

  @override
  void execute() {}
}
