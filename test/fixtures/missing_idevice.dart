import 'package:wb_annatation/wb_annatation.dart';

@VirtualDevice()
class MissingDevice {
  @InputControl(type: WbControlType.switch_)
  bool switchState = false;
}
