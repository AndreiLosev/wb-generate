import 'package:wb_sdk/wb_sdk.dart';

part 'room_light_with_deps.wb.g.dart';

@VirtualDevice(dependencies: ['sensor/temp/on', '+/meta'])
base class RoomLightWithDeps extends IDevice with RoomLightWithDepsPartMixin {
  new({
    this.name = 'room_light_with_deps',
    this.title = const WbLocalizedTitle(
      en: 'Room Light With Deps',
      ru: 'Освещение с зависимостями',
    ),
  }) {
    register(this);
  }

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

  @InputControl(
    type: WbControlType.switch_,
    title: WbLocalizedTitle(en: 'Switch', ru: 'Выключатель'),
  )
  bool switchState = false;

  @override
  void execute() {}
}
