import 'package:wb_annatation/wb_annatation.dart';

part 'control_title_samples.wb.g.dart';

@VirtualDevice(
  name: 'title_samples',
  title: WbLocalizedTitle(en: 'Title Samples'),
)
class ControlTitleSamples with ControlTitleSamplesWbMixin implements IDevice {
  ControlTitleSamples();

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
