import 'package:test/test.dart';
import 'package:wb_sdk/wb_sdk.dart';

import 'fixtures/wo_switch_device.dart';
import 'support/mock_mqtt_client.dart';
import 'support/test_wb_client.dart';

void main() {
  group('WoSwitchDevicePartMixin', () {
    late TestWbClient wbClient;
    late MockWbMqttClient client;
    late WoSwitchDevice device;

    setUpAll(() async {
      wbClient = await TestWbClient.create();
      client = wbClient.mock;
    });

    tearDownAll(() async {
      await wbClient.disposeForTest();
    });

    setUp(() {
      client.publishes.clear();
      device = WoSwitchDevice();
    });

    test('inputs для wo-switch возвращает /on топик', () {
      expect(
        device.inputs(),
        {'wo_switch_device/feedback/on'},
      );
    });

    test('outputs для wo-switch возвращает /on топик', () {
      expect(
        device.outputs(),
        {'wo_switch_device/relay/on'},
      );
    });

    test('setRelay публикует в основной топик и меняет поле', () {
      device.setRelay(true);

      expect(device.relay, isTrue);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having(
                (p) => p.topic,
                'topic',
                'wo_switch_device/relay',
              )
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });

    test('updateField публикует в основной топик feedback', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'wo_switch_device/feedback/on',
          payload: '1',
        ),
      );

      expect(device.feedback, isTrue);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'wo_switch_device/feedback')
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });
  });
}
