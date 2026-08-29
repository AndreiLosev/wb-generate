import 'package:wb_sdk/wb_sdk.dart';

part 'control_title_samples.wb.g.dart';

@VirtualDevice()
base class ControlTitleSamples extends IDevice with ControlTitleSamplesPartMixin {
  ControlTitleSamples({
    this.name = 'title_samples',
    this.title = const WbLocalizedTitle(en: 'Title Samples'),
  }) {
    register(this);
  }

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
