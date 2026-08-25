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
| `init()` | retained-публикация meta устройства, meta всех контролов и текущих значений `@OutputControl` через `set<Field>` |
| `inputs()` | топики подписки `@InputControl` (см. таблицу топиков ниже) |
| `outputs()` | топики подписки `@OutputControl` (см. таблицу топиков ниже) |
| `setLamp(value)` | только MQTT publish в output-топик; поле **не меняется** |
| `updateField(mess)` | по `mess.topic` находит `@InputControl` или `@OutputControl`, декодирует `mess.payload` и записывает в поле |

Генератор использует **короткие топики** `{device}/{control}` (с опциональным `/on` или `/meta`). Преобразование в полные пути Wiren Board (`/devices/...`) — задача реализации `WbMqttClient`.

### Топики по типу контрола

| Назначение | Короткий топик |
|---|---|
| meta устройства | `{device}/meta` |
| meta контрола | `{device}/{control}/meta` |

| Направление | Тип | топик подписки | `set<Field>` |
|---|---|---|---|
| `@InputControl` | любой | `{device}/{control}` | — |
| `@OutputControl` | `wo-switch` | `{device}/{control}` | `{device}/{control}/on` |
| `@OutputControl` | `switch`, `alarm`, `pushbutton` | `{device}/{control}/on` | `{device}/{control}/on` |
| `@OutputControl` | остальные (`text`, `range`, `value`, …) | `{device}/{control}` | `{device}/{control}` |

Для `pushbutton` publish выполняется без `retained`.

Поле `driver` в meta устройства всегда `vktmotage`.

Сгенерированный mixin — `part of` исходного файла, использует геттер `mqtt` из `IDevice`.
