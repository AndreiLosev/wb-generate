// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_light.dart';

mixin RoomLightWbMixin {
  static const String deviceName = 'room_light';

  static const String _deviceMetaTopic = '/devices/room_light/meta';

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
    '/devices/room_light/controls/switch_state',
    '/devices/room_light/controls/power',
  };

  static const Set<String> _outputTopics = {
    '/devices/room_light/controls/lamp',
    '/devices/room_light/controls/mode',
  };

  static const Map<String, String> _outputValueTopics = {
    'lamp': '/devices/room_light/controls/lamp',
    'mode': '/devices/room_light/controls/mode',
  };

  /// Публикует retained meta устройства, контролов и output values.
  @override
  void init() {
    (this as RoomLight).mqtt.publish(
      _deviceMetaTopic,
      _deviceMetaJson,
      retained: true,
    );

    for (final entry in _controlMetaJson.entries) {
      final topic = '/devices/room_light/controls/${entry.key}/meta';
      (this as RoomLight).mqtt.publish(topic, entry.value, retained: true);
    }

    setLamp((this as RoomLight).lamp);
    setMode((this as RoomLight).mode);
  }

  void setLamp(bool value) {
    final device = this as RoomLight;
    device.lamp = value;
    device.mqtt.publish(
      _outputValueTopics['lamp']!,
      WbValueCodec.encode(value, WbControlType.switch_),
      retained: true,
    );
  }

  void setMode(String value) {
    final device = this as RoomLight;
    device.mode = value;
    device.mqtt.publish(
      _outputValueTopics['mode']!,
      WbValueCodec.encode(value, WbControlType.text),
      retained: true,
    );
  }

  @override
  Set<String> inputs() => _inputTopics;

  @override
  Set<String> outputs() => _outputTopics;
}
