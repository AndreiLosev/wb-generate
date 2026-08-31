# wb_generate

`build_runner`-генератор MQTT-драйверов Wiren Board. Подключается только как **dev_dependency**.

Runtime (аннотации, `IDevice`, `WbMqttClient`, `WbValueCodec`) — в пакете [`wb_sdk`](../wb-sdk).

## Зависимости

```yaml
dependencies:
  wb_sdk:
    path: ../wb-sdk

dev_dependencies:
  wb_generate:
    path: ../wb-generate
  build_runner: ^2.4.15
```

## Использование

```dart
import 'package:wb_sdk/wb_sdk.dart';

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
| `init()` | восстановление `@Retain` из `WbStorage`, retained-публикация meta устройства, meta всех контролов и текущих значений `@OutputControl` через `set<Field>` |
| `inputs()` | топики подписки `@InputControl`: `{control}/on` (роутер добавляет `{device}/`) |
| `outputs()` | топики подписки `@OutputControl`: `{control}/on` (роутер добавляет `{device}/`) |
| `setLamp(value)` | записывает значение в поле и MQTT publish в основной топик `{device}/{control}` |
| `updateField(mess)` | по `mess.topic` (`.../on`) находит контрол, декодирует `mess.payload`, нормализует значение, записывает в поле, публикует в основной топик `{device}/{control}` и для `@Retain` сохраняет в `WbStorage` |

### Персистентность `@Retain`

На поле `@InputControl` или `@OutputControl` можно добавить `@Retain(init)` — значение сохраняется между перезапусками драйвера.

- Ключ в storage: `{name}.{fieldName}` (имя устройства и имя поля в Dart).
- `init()` — `WbHiveStorage.getInstanse().get(key, init)` и publish в основной топик `{device}/{control}`.
- `updateField` — `WbHiveStorage.getInstanse().put(key, value)` только если новое значение отличается от текущего в поле.
- Перед `init()` нужно открыть storage: `await WbHiveStorage(directory: ...).open()`.

```dart
@Retain('0')
@OutputControl(
  type: WbControlType.text,
  title: WbLocalizedTitle(en: 'Mode'),
)
String mode = '0';
```

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

Поле `driver` в meta устройства всегда `vktmotage`. Поле `order` в meta контрола генерируется автоматически (1, 2, 3, …) по порядку полей в классе. Поле `sender` выставляется оркестратором при публикации. Поля `readonly` и `hidden` всегда присутствуют в meta контрола.

Сгенерированный mixin — `part of` исходного файла, использует `wbPublish` и `WbHiveStorage.getInstanse()`.

## Конфиг из pubspec.yaml

Секция `wirenboard` в `pubspec.yaml` описывает окружения (`dev`, `prod`, …). Генератор `wb_config` создаёт `lib/wb_config.g.dart` с плоским классом `WbConfig` — **только поля активного окружения**. Окружение задаётся опцией `current_env` при сборке (по умолчанию `dev`).

Секция `wirenboard` **опциональна**: если её нет, `wb_config` не генерирует `lib/wb_config.g.dart` и сборка не падает. Не импортируйте `wb_config.g.dart`, если секция не используется.

```yaml
wirenboard:
  dev:
    host: 192.168.1.24
    port: 1883
    client_id: my-pc-123
    username: user
    password: pass
    data_path: /var/lib/my-driver/state.json
  prod:
    host: localhost
    port: 1883
    client_id: my-pc-123
    data_path: /var/lib/my-driver/state.json
```

```bash
dart run build_runner build
```

Сборка для prod:

```bash
dart run build_runner build --define "wb_generate|wb_config=current_env=prod"
```

Или в `build.yaml` пакета:

```yaml
targets:
  $default:
    builders:
      wb_generate|wb_config:
        enabled: true
        options:
          current_env: prod
```

```dart
import 'package:my_driver/wb_config.g.dart';

final client = WbClient(
  host: wbConfig.host,
  port: wbConfig.port,
  clientId: wbConfig.clientId,
);
```

Смена окружения: передать `current_env` через `--define` или `build.yaml` и пересобрать. Поле `current_env` не попадает в сгенерированный класс.

Пароли и другие секреты из pubspec попадут в сгенерированный файл — не коммитьте их при публикации пакета.
