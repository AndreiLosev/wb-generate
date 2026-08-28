import 'dart:async';

import 'package:wb_sdk/wb_sdk.dart';

class MockWbMqttClient implements WbMqttClient {
  final _messagesController = StreamController<WbMqttMessage>.broadcast();

  final List<MockPublish> publishes = <MockPublish>[];
  final List<String> subscribedTopics = <String>[];
  final List<String> unsubscribedTopics = <String>[];

  @override
  Stream<WbMqttMessage> get messages => _messagesController.stream;

  @override
  void publish(String topic, String payload, {bool retained = false}) {
    publishes.add(MockPublish(topic: topic, payload: payload, retained: retained));
  }

  @override
  void subscribe(String topic) {
    subscribedTopics.add(topic);
  }

  @override
  void unsubscribe(String topic) {
    unsubscribedTopics.add(topic);
  }

  void emit(WbMqttMessage message) {
    _messagesController.add(message);
  }

  Future<void> close() async {
    await _messagesController.close();
  }
}

class MockPublish {
  const MockPublish({
    required this.topic,
    required this.payload,
    required this.retained,
  });

  final String topic;
  final String payload;
  final bool retained;
}
