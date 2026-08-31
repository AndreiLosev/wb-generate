import 'package:test/test.dart';
import 'package:wb_sdk/wb_sdk.dart';

import 'fixtures/room_light.dart';
import 'support/mock_mqtt_client.dart';
import 'support/test_wb_client.dart';
import 'support/test_wb_storage.dart';

void main() {
  group('RoomLightPartMixin', () {
    late TestWbClient wbClient;
    late MockWbMqttClient client;
    late TestWbStorage wbStorage;
    late RoomLight device;

    setUpAll(() async {
      wbClient = await TestWbClient.create();
      client = wbClient.mock;
      wbStorage = await TestWbStorage.create();
    });

    tearDownAll(() async {
      await wbClient.disposeForTest();
      await wbStorage.disposeForTest();
    });

    setUp(() {
      client.publishes.clear();
      wbStorage.mock.values.clear();
      device = RoomLight();
    });

    test('retains возвращает mqttName и Retain(init)', () {
      expect(device.retains(), {'mode': '0'});
    });

    test('register устанавливает device через setDevice', () {
      expect((device as PartOfIDevice).device, same(device));
    });

    test('meta содержит meta контролов', () {
      expect(device.meta(), contains('lamp'));
      expect(device.meta()['lamp']?.type, WbControlType.switch_);
    });

    test('inputs возвращает топики InputControl', () {
      expect(
        device.inputs(),
        {
          'switch_state/on',
          'power/on',
        },
      );
    });

    test('outputs возвращает топики OutputControl', () {
      expect(
        device.outputs(),
        {
          'lamp/on',
          'mode/on',
        },
      );
    });

    test('setLamp публикует в основной топик и меняет поле', () {
      device.setLamp(true);

      expect(device.lamp, isTrue);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/lamp')
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });

    test('setMode публикует в основной топик и меняет поле', () {
      device.setMode('1');

      expect(device.mode, '1');
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
          topic: 'room_light/switch_state/on',
          payload: '1',
        ),
      );

      expect(device.switchState, isTrue);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/switch_state')
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });

    test('updateField записывает значение в input-поле power', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/power/on',
          payload: '42.5',
        ),
      );

      expect(device.power, 42.5);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/power')
              .having((p) => p.payload, 'payload', '42.5')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });

    test('updateField ограничивает power по max', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/power/on',
          payload: '6000',
        ),
      );

      expect(device.power, 5000);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/power')
              .having((p) => p.payload, 'payload', '5000.0'),
        ),
      );
    });

    test('updateField округляет power по precision', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/power/on',
          payload: '42.56',
        ),
      );

      expect(device.power, 42.6);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/power')
              .having((p) => p.payload, 'payload', '42.6'),
        ),
      );
    });

    test('updateField публикует power без float-артефактов', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/power/on',
          payload: '15.698',
        ),
      );

      expect(device.power, 15.7);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/power')
              .having((p) => p.payload, 'payload', '15.7'),
        ),
      );
    });

    test('updateField сохраняет @Retain поле в storage', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/mode/on',
          payload: '1',
        ),
      );

      expect(wbStorage.mock.values['room_light.mode'], '1');
    });

    test('updateField не сохраняет @Retain если значение не изменилось', () {
      device.mode = '1';
      wbStorage.mock.put('room_light.mode', 'stale');

      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/mode/on',
          payload: '1',
        ),
      );

      expect(device.mode, '1');
      expect(wbStorage.mock.values['room_light.mode'], 'stale');
    });

    test('updateField не сохраняет @Retain при недопустимом enum', () {
      wbStorage.mock.put('room_light.mode', '0');

      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/mode/on',
          payload: '2',
        ),
      );

      expect(device.mode, '0');
      expect(wbStorage.mock.values['room_light.mode'], '0');
    });

    test('updateField игнорирует mode вне enumTitles', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/mode/on',
          payload: '2',
        ),
      );

      expect(device.mode, '0');
      expect(
        client.publishes.map((publish) => publish.topic),
        isNot(contains('room_light/mode')),
      );
    });

    test('setMode игнорирует значение вне enumTitles', () {
      device.setMode('2');

      expect(device.mode, '0');
      expect(client.publishes, isEmpty);
    });

    test('setMode принимает допустимое значение enumTitles', () {
      device.setMode('1');

      expect(device.mode, '1');
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/mode')
              .having((p) => p.payload, 'payload', '1'),
        ),
      );
    });

    test('updateField записывает значение в output-поле lamp', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'room_light/lamp/on',
          payload: '1',
        ),
      );

      expect(device.lamp, isTrue);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'room_light/lamp')
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
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
