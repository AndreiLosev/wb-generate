import 'package:wb_annatation/wb_annatation.dart';

part 'room_light.wb.g.dart';

@VirtualDevice(
  name: 'room_light',
  title: WbLocalizedTitle(en: 'Room Light', ru: 'Освещение комнаты'),
)
class RoomLight with RoomLightWbMixin implements IDevice {
  RoomLight(this.mqtt);

  @override
  final WbMqttClient mqtt;

  bool executeCalled = false;

  @InputControl(
    type: WbControlType.switch_,
    title: WbLocalizedTitle(en: 'Switch', ru: 'Выключатель'),
  )
  bool switchState = false;

  @OutputControl(
    type: WbControlType.switch_,
    title: WbLocalizedTitle(en: 'Lamp', ru: 'Лампа'),
    order: 1,
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
      '0': {'en': 'Off', 'ru': 'Выкл'},
      '1': {'en': 'On', 'ru': 'Вкл'},
    },
    title: WbLocalizedTitle(en: 'Mode', ru: 'Режим'),
  )
  String mode = '0';

  @override
  void execute() {
    executeCalled = true;
  }
}
