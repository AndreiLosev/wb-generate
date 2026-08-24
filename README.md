# wb_generate

`build_runner`-генератор MQTT-драйверов Wiren Board. Подключается только как **dev_dependency**.

Runtime (аннотации, `IDevice`, `WbMqttClient`, `WbValueCodec`) — в пакете [`wb_annatation`](../wb-annatation).

## Зависимости

```yaml
dependencies:
  wb_annatation:
    path: ../wb-annatation

dev_dependencies:
  wb_generate:
    path: ../wb-generate
  build_runner: ^2.4.15
```

## Использование

```dart
import 'package:wb_annatation/wb_annatation.dart';

part 'room_light.wb.g.dart';

@VirtualDevice(
  name: 'room_light',
  title: WbLocalizedTitle(en: 'Room Light', ru: 'Освещение'),
)
class RoomLight with RoomLightWbMixin implements IDevice {
  RoomLight(this.mqtt);

  @override
  final WbMqttClient mqtt;

  @InputControl(
    type: WbControlType.switch_,
    title: WbLocalizedTitle(en: 'Switch'),
  )
  bool switchState = false;

  @OutputControl(
    type: WbControlType.switch_,
    title: WbLocalizedTitle(en: 'Lamp'),
  )
  bool lamp = false;

  @override
  void execute() {
    // логика устройства
  }
}
```

```bash
dart run build_runner build
```

```dart
final device = RoomLight(client);
device.init();
```

## Поведение mixin

| Метод | Поведение |
|---|---|
| `init()` | retained-публикация meta устройства, meta всех контролов и текущих значений `@OutputControl` |
| `inputs()` | value-топики полей `@InputControl`: `/devices/{name}/controls/{name}` |
| `outputs()` | value-топики полей `@OutputControl`: `/devices/{name}/controls/{name}` |
| `setLamp(value)` | присвоение полю + retained publish в output-топик (для каждого `@OutputControl`) |

Поле `driver` в meta устройства всегда `vktmotage`.

Сгенерированный mixin — `part of` исходного файла, использует геттер `mqtt` из `IDevice`.
