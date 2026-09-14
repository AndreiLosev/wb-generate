import 'package:test/test.dart';
import 'package:wb_sdk/wb_sdk.dart';

import 'fixtures/reverse_input_device.dart';
import 'support/mock_mqtt_client.dart';
import 'support/test_wb_client.dart';

void main() {
  group('ReverseInputDevicePartMixin', () {
    late TestWbClient wbClient;
    late MockWbMqttClient client;
    late ReverseInputDevice device;

    setUpAll(() async {
      wbClient = await TestWbClient.create();
      client = wbClient.mock;
    });

    tearDownAll(() async {
      await wbClient.disposeForTest();
    });

    setUp(() {
      client.publishes.clear();
      device = ReverseInputDevice();
    });

    test('updateField инвертирует поле и публикует логическое значение в основной топик', () {
      device.updateField(
        const WbMqttMessage(
          topic: 'reverse_input_device/feedback/on',
          payload: '1',
        ),
      );

      expect(device.feedback, isFalse);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'reverse_input_device/feedback')
              .having((p) => p.payload, 'payload', '0')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );

      client.publishes.clear();

      device.updateField(
        const WbMqttMessage(
          topic: 'reverse_input_device/feedback/on',
          payload: '0',
        ),
      );

      expect(device.feedback, isTrue);
      expect(
        client.publishes,
        contains(
          isA<MockPublish>()
              .having((p) => p.topic, 'topic', 'reverse_input_device/feedback')
              .having((p) => p.payload, 'payload', '1')
              .having((p) => p.retained, 'retained', isTrue),
        ),
      );
    });
  });
}
