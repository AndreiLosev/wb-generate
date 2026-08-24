import 'package:test/test.dart';

import 'fixtures/room_light.dart';
import 'support/mock_mqtt_client.dart';

void main() {
  group('RoomLightWbMixin', () {
    late MockWbMqttClient client;
    late RoomLight device;

    setUp(() {
      client = MockWbMqttClient();
      device = RoomLight(client);
    });

    tearDown(() async {
      await client.close();
    });

    test('init публикует meta устройства и контролов', () {
      device.init();

      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', '/devices/room_light/meta')
              .having((p) => p.retained, 'retained', isTrue)
              .having(
                (p) => p.payload,
                'payload',
                contains('"driver":"vktmotage"'),
              ),
        ),
      );

      expect(
        client.publishes,
        contains(
          isA<MockPublish>().having(
            (p) => p.topic,
            'topic',
            '/devices/room_light/controls/lamp/meta',
          ),
        ),
      );
    });

    test('init публикует output values', () {
      device
        ..lamp = true
        ..mode = '1';

      device.init();

      expect(
        client.publishes.map((publish) => publish.topic),
        containsAll([
          '/devices/room_light/controls/lamp',
          '/devices/room_light/controls/mode',
        ]),
      );
      expect(
        client.publishes.map((publish) => publish.topic),
        isNot(contains('/devices/room_light/controls/switch_state')),
      );
      expect(
        client.publishes.map((publish) => publish.topic),
        isNot(contains('/devices/room_light/controls/power')),
      );
    });

    test('inputs возвращает топики InputControl', () {
      expect(
        device.inputs(),
        {
          '/devices/room_light/controls/switch_state',
          '/devices/room_light/controls/power',
        },
      );
    });

    test('outputs возвращает топики OutputControl', () {
      expect(
        device.outputs(),
        {
          '/devices/room_light/controls/lamp',
          '/devices/room_light/controls/mode',
        },
      );
    });

    test('setLamp присваивает значение и публикует в топик', () {
      device.setLamp(true);

      expect(device.lamp, isTrue);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', '/devices/room_light/controls/lamp')
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });

    test('setMode присваивает значение и публикует в топик', () {
      device.setMode('1');

      expect(device.mode, '1');
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', '/devices/room_light/controls/mode')
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });
  });
}
