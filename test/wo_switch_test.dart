import 'package:test/test.dart';

import 'fixtures/wo_switch_device.dart';
import 'support/mock_mqtt_client.dart';

void main() {
  group('WoSwitchDeviceWbMixin', () {
    late MockWbMqttClient client;
    late WoSwitchDevice device;

    setUp(() {
      client = MockWbMqttClient();
      device = WoSwitchDevice(client);
    });

    tearDown(() async {
      await client.close();
    });

    test('inputs для wo-switch возвращает базовый топик', () {
      expect(
        device.inputs(),
        {'wo_switch_device/feedback'},
      );
    });

    test('outputs для wo-switch возвращает базовый топик', () {
      expect(
        device.outputs(),
        {'wo_switch_device/relay'},
      );
    });

    test('setRelay публикует в /on и не меняет поле', () {
      device.setRelay(true);

      expect(device.relay, isFalse);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having(
                (p) => p.topic,
                'topic',
                'wo_switch_device/relay/on',
              )
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });
  });
}
