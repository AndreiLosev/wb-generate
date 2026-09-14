import 'package:wb_sdk/wb_sdk.dart';

@VirtualDevice()
base class ReverseInputInvalid extends IDevice with ReverseInputInvalidPartMixin {
  ReverseInputInvalid({
    this.name = 'reverse_input_invalid',
  }) {
    register(this);
  }

  @override
  final String name;

  @override
  final WbLocalizedTitle? title = null;

  @InputControl(type: WbControlType.pushbutton, reverse: true)
  bool button = false;

  @override
  void execute() {}
}
