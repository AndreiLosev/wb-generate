import 'dart:async';
import 'dart:io';

import 'package:wb_annatation/wb_annatation.dart';

import 'fake_mqtt_broker.dart';
import 'mock_mqtt_client.dart';

/// [WbClient] для тестов: регистрирует синглтон через [connect] и делегирует
/// MQTT-вызовы в [MockWbMqttClient].
class TestWbClient extends WbClient {
  TestWbClient._({
    required FakeMqttBroker broker,
    required MockWbMqttClient mock,
  }) : _broker = broker,
       _mock = mock,
       super(
         host: InternetAddress.loopbackIPv4.address,
         port: broker.port,
         clientId: 'test-wb-client',
       );

  final FakeMqttBroker _broker;
  final MockWbMqttClient _mock;

  MockWbMqttClient get mock => _mock;

  static Future<TestWbClient> create() async {
    final broker = await FakeMqttBroker.start();
    final mock = MockWbMqttClient();
    final client = TestWbClient._(broker: broker, mock: mock);
    await client.connect();
    return client;
  }

  Future<void> disposeForTest() async {
    await dispose();
    await _broker.close();
    await _mock.close();
  }

  @override
  Stream<WbMqttMessage> get messages => _mock.messages;

  @override
  void publish(String topic, String payload, {bool retained = false}) {
    _mock.publish(topic, payload, retained: retained);
  }

  @override
  void subscribe(String topic) {
    _mock.subscribe(topic);
  }

  @override
  void unsubscribe(String topic) {
    _mock.unsubscribe(topic);
  }
}
