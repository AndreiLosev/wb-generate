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

@VirtualDevice()
class RoomLight with RoomLightWbMixin implements IDevice {
  RoomLight({
    required this.name,
    this.title,
  });

  @override
  final String name;

  @override
  final WbLocalizedTitle? title;

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
final client = WbClient(
  host: 'localhost',
  clientId: 'room-light-driver',
);
await client.connect();

final device = RoomLight(name: 'room_light');
device.init();
```

## Поведение mixin

| Метод | Поведение |
|---|---|
| `init()` | retained-публикация meta устройства, meta всех контролов и текущих значений `@OutputControl` через `set<Field>` |
| `inputs()` | топики подписки `@InputControl`: `{device}/{control}/on` |
| `outputs()` | топики подписки `@OutputControl`: `{device}/{control}/on` |
| `setLamp(value)` | записывает значение в поле и MQTT publish в основной топик `{device}/{control}` |
| `updateField(mess)` | по `mess.topic` (`.../on`) находит контрол, декодирует `mess.payload`, нормализует значение, записывает в поле и публикует в основной топик `{device}/{control}` |

### Нормализация значений

В `updateField` и `set{Field}` генератор применяет:

- **min / max** — ограничение числового значения границами (если указаны в аннотации)
- **precision** — округление до шага `(value / precision).round() * precision`
- **enumTitles** — только значения из ключей map; недопустимые значения игнорируются без assign/publish

Генератор использует **короткие топики** `{device}/{control}` (с опциональным `/on` или `/meta`). Преобразование в полные пути Wiren Board (`/devices/...`) — задача реализации `WbMqttClient`.

### Топики

| Назначение | Короткий топик |
|---|---|
| meta устройства | `{device}/meta` |
| meta контрола | `{device}/{control}/meta` |
| подписка `@InputControl` / `@OutputControl` | `{device}/{control}/on` |
| `set<Field>` (publish) | `{device}/{control}` |

Для `pushbutton` publish выполняется без `retained`.

Поле `driver` в meta устройства всегда `vktmotage`. Поле `order` в meta контрола генерируется автоматически (1, 2, 3, …) по порядку полей в классе. Поля `readonly` и `hidden` всегда присутствуют в meta контрола.

Сгенерированный mixin — `part of` исходного файла, использует `WbClient.getInstanse()`.
