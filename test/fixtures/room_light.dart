import 'package:wb_annatation/wb_annatation.dart';

part 'room_light.wb.g.dart';

@VirtualDevice()
class RoomLight with RoomLightWbMixin implements IDevice {
  RoomLight({
    this.name = 'room_light',
    this.title = const WbLocalizedTitle(
      en: 'Room Light',
      ru: 'Освещение комнаты',
    ),
  });

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

  bool executeCalled = false;

  @InputControl(
    type: WbControlType.switch_,
    title: WbLocalizedTitle(en: 'Switch', ru: 'Выключатель'),
  )
  bool switchState = false;

  @OutputControl(
    type: WbControlType.switch_,
    title: WbLocalizedTitle(en: 'Lamp', ru: 'Лампа'),
  )
  bool lamp = false;

  @InputControl(
    type: WbControlType.value,
    units: WbUnits.watt,
    min: 0,
    max: 5000,
    precision: 0.1,
    readonly: true,
    title: WbLocalizedTitle(en: 'Power', ru: 'Мощность'),
  )
  double power = 0;

  @OutputControl(
    type: WbControlType.text,
    enumTitles: {
      '0': WbLocalizedTitle(en: 'Off', ru: 'Выкл'),
      '1': WbLocalizedTitle(en: 'On', ru: 'Вкл'),
    },
    title: WbLocalizedTitle(en: 'Mode', ru: 'Режим'),
  )
  String mode = '0';

  @override
  void execute() {
    executeCalled = true;
  }
}
