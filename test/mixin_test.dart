import 'package:test/test.dart';
import 'package:wb_annatation/wb_annatation.dart';

import 'fixtures/room_light.dart';
import 'support/mock_mqtt_client.dart';
import 'support/test_wb_client.dart';

void main() {
  group('RoomLightWbMixin', () {
    late TestWbClient wbClient;
    late MockWbMqttClient client;
    late RoomLight device;

    setUpAll(() async {
      wbClient = await TestWbClient.create();
      client = wbClient.mock;
    });

    tearDownAll(() async {
      await wbClient.disposeForTest();
    });

    setUp(() {
      client.publishes.clear();
      device = RoomLight();
    });

    test('init публикует meta устройства и контролов', () {
      device.init();

      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/meta')
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
            'room_light/lamp/meta',
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
          'room_light/lamp/on',
          'room_light/mode',
        ]),
      );
      expect(
        client.publishes.map((publish) => publish.topic),
        isNot(contains('room_light/switch_state')),
      );
      expect(
        client.publishes.map((publish) => publish.topic),
        isNot(contains('room_light/power')),
      );
    });

    test('inputs возвращает топики InputControl', () {
      expect(
        device.inputs(),
        {
          'room_light/switch_state',
          'room_light/power',
        },
      );
    });

    test('outputs возвращает топики OutputControl', () {
      expect(
        device.outputs(),
        {
          'room_light/lamp/on',
          'room_light/mode',
        },
      );
    });

    test('setLamp публикует в топик и не меняет поле', () {
      device.setLamp(true);

      expect(device.lamp, isFalse);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/lamp/on')
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });

    test('setMode публикует в топик и не меняет поле', () {
      device.setMode('1');

      expect(device.mode, '0');
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/mode')
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });

    test('updateField записывает значение в input-поле switch_state', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/switch_state',
          payload: '1',
        ),
      );

      expect(device.switchState, isTrue);
    });

    test('updateField записывает значение в input-поле power', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/power',
          payload: '42.5',
        ),
      );

      expect(device.power, 42.5);
    });

    test('updateField записывает значение в output-поле lamp', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/lamp/on',
          payload: '1',
        ),
      );

      expect(device.lamp, isTrue);
    });

    test('updateField игнорирует неизвестный топик', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/unknown',
          payload: '1',
        ),
      );

      expect(device.switchState, isFalse);
      expect(device.power, 0);
      expect(device.lamp, isFalse);
    });
  });
}
