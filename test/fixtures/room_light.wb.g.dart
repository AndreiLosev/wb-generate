// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_light.dart';

mixin RoomLightWbMixin {
  static const String deviceName = 'room_light';

  static const String _deviceMetaTopic = 'room_light/meta';

  static const String _deviceMetaJson =
      '{"driver":"vktmotage","title":{"en":"Room Light","ru":"Освещение комнаты"}}';

  static const Map<String, String> _controlMetaJson = {
    'switch_state':
        '{"type":"switch","title":{"en":"Switch","ru":"Выключатель"}}',
    'lamp': '{"type":"switch","title":{"en":"Lamp","ru":"Лампа"},"order":1}',
    'power':
        '{"type":"value","title":{"en":"Power","ru":"Мощность"},"units":"W","min":0.0,"max":5000.0,"precision":0.1,"readonly":true}',
    'mode':
        '{"type":"text","title":{"en":"Mode","ru":"Режим"},"enum":{"0":{"en":"Off","ru":"Выкл"},"1":{"en":"On","ru":"Вкл"}}}',
  };

  static const Set<String> _inputTopics = {
    'room_light/switch_state',
    'room_light/power',
  };

  static const Set<String> _outputTopics = {
    'room_light/lamp/on',
    'room_light/mode',
  };

  static const Map<String, String> _outputValueTopics = {
    'lamp': 'room_light/lamp/on',
    'mode': 'room_light/mode',
  };

  /// Публикует retained meta устройства, контролов и output values.
  void init() {
    WbClient.getInstanse().publish(
      _deviceMetaTopic,
      _deviceMetaJson,
      retained: true,
    );

    for (final entry in _controlMetaJson.entries) {
      final topic = 'room_light/${entry.key}/meta';
      WbClient.getInstanse().publish(topic, entry.value, retained: true);
    }

    setLamp((this as RoomLight).lamp);
    setMode((this as RoomLight).mode);
  }

  void setLamp(bool value) {
    WbClient.getInstanse().publish(
      _outputValueTopics['lamp']!,
      WbValueCodec.encode(value, WbControlType.switch_),
      retained: true,
    );
  }

  void setMode(String value) {
    WbClient.getInstanse().publish(
      _outputValueTopics['mode']!,
      WbValueCodec.encode(value, WbControlType.text),
      retained: true,
    );
  }

  void updateField(WbMqttMessage mess) {
    final device = this as RoomLight;
    switch (mess.topic) {
      case 'room_light/switch_state':
        device.switchState =
            WbValueCodec.decode(mess.payload, WbControlType.switch_) as bool;
        return;
      case 'room_light/power':
        device.power =
            WbValueCodec.decode(mess.payload, WbControlType.value) as double;
        return;
      case 'room_light/lamp/on':
        device.lamp =
            WbValueCodec.decode(mess.payload, WbControlType.switch_) as bool;
        return;
      case 'room_light/mode':
        device.mode =
            WbValueCodec.decode(mess.payload, WbControlType.text) as String;
        return;
    }
  }

  Set<String> inputs() => _inputTopics;

  Set<String> outputs() => _outputTopics;
}
