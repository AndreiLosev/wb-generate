import 'package:wb_annatation/wb_annatation.dart';

@VirtualDevice(
  name: 'invalid',
  title: WbLocalizedTitle(en: 'Invalid'),
)
class MissingDevice {
  @InputControl(type: WbControlType.switch_)
  bool switchState = false;
}
