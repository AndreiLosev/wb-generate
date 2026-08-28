import 'package:wb_sdk/wb_sdk.dart';

@VirtualDevice()
class MissingDevice {
  @InputControl(type: WbControlType.switch_)
  bool switchState = false;
}
