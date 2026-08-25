import 'dart:async';
import 'dart:io';

/// Минимальный MQTT-брокер для unit-тестов: принимает CONNECT, отвечает CONNACK.
class FakeMqttBroker {
  FakeMqttBroker._(this._server);

  final ServerSocket _server;
  final _subscriptions = <StreamSubscription<Socket>>[];

  static Future<FakeMqttBroker> start() async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final broker = FakeMqttBroker._(server);
    broker._subscriptions.add(
      server.listen((socket) {
        unawaited(broker._handleClient(socket));
      }),
    );
    return broker;
  }

  int get port => _server.port;

  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _server.close();
  }

  Future<void> _handleClient(Socket socket) async {
    try {
      await for (final chunk in socket) {
        if (chunk.isEmpty) {
          continue;
        }

        final messageType = chunk[0] >> 4;
        if (messageType == 1) {
          // CONNECT
          socket.add(const [0x20, 0x02, 0x00, 0x00]);
        }
      }
    } on Object {
      // Клиент закрыл соединение.
    } finally {
      await socket.close();
    }
  }
}
