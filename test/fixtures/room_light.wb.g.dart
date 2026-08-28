// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_light.dart';

mixin RoomLightWbMixin {
  IDevice get _device => this as IDevice;

  static const Map<String, String> _controlMetaJson = {
    'switch_state':
        '{"type":"switch","title":{"en":"Switch","ru":"Выключатель"},"order":1,"readonly":false,"hidden":false}',
    'lamp':
        '{"type":"switch","title":{"en":"Lamp","ru":"Лампа"},"order":2,"readonly":false,"hidden":false}',
    'power':
        '{"type":"value","title":{"en":"Power","ru":"Мощность"},"order":3,"readonly":true,"hidden":false,"units":"W","min":0.0,"max":5000.0,"precision":0.1}',
    'mode':
        '{"type":"text","title":{"en":"Mode","ru":"Режим"},"order":4,"readonly":false,"hidden":false,"enum":{"0":{"en":"Off","ru":"Выкл"},"1":{"en":"On","ru":"Вкл"}}}',
  };

  /// Публикует retained meta устройства, контролов и output values.
  void init() {
    final device = this as RoomLight;
    device.mode =
        WbHiveStorage.getInstanse().get('${_device.name}.mode', '0') as String;

    wbPublish(
      '${_device.name}/mode',
      WbValueCodec.encode(device.mode, WbControlType.text),
      retained: true,
    );

    wbPublish(
      '${_device.name}/meta',
      WbMetaJson.device(_device.title),
      retained: true,
    );

    for (final entry in _controlMetaJson.entries) {
      final topic = '${_device.name}/${entry.key}/meta';
      wbPublish(topic, entry.value, retained: true);
    }

    setLamp(device.lamp);
  }

  void setLamp(bool value) {
    final device = this as RoomLight;
    device.lamp = value;
    wbPublish(
      '${_device.name}/lamp',
      WbValueCodec.encode(value, WbControlType.switch_),
      retained: true,
    );
  }

  void setMode(String value) {
    final device = this as RoomLight;
    var normalized = value;
    if (!const {'0', '1'}.contains(normalized)) return;
    device.mode = normalized;
    wbPublish(
      '${_device.name}/mode',
      WbValueCodec.encode(normalized, WbControlType.text),
      retained: true,
    );
  }

  void updateField(WbMqttMessage mess) {
    final device = this as RoomLight;
    final namePrefix = '${_device.name}/';
    if (!mess.topic.startsWith(namePrefix)) {
      return;
    }
    switch (mess.topic.substring(namePrefix.length)) {
      case 'switch_state/on':
        final value =
            WbValueCodec.decode(mess.payload, WbControlType.switch_) as bool;
        device.switchState = value;
        wbPublish(
          '${_device.name}/switch_state',
          WbValueCodec.encode(value, WbControlType.switch_),
          retained: true,
        );
        return;
      case 'lamp/on':
        final value =
            WbValueCodec.decode(mess.payload, WbControlType.switch_) as bool;
        device.lamp = value;
        wbPublish(
          '${_device.name}/lamp',
          WbValueCodec.encode(value, WbControlType.switch_),
          retained: true,
        );
        return;
      case 'power/on':
        var value =
            WbValueCodec.decode(mess.payload, WbControlType.value) as double;
        value = WbNumericBounds.normalizeDouble(
          value,
          min: 0.0,
          max: 5000.0,
          precision: 0.1,
        );
        device.power = value;
        wbPublish(
          '${_device.name}/power',
          WbValueCodec.encode(value, WbControlType.value),
          retained: true,
        );
        return;
      case 'mode/on':
        final value =
            WbValueCodec.decode(mess.payload, WbControlType.text) as String;
        if (!const {'0', '1'}.contains(value)) return;
        if (device.mode != value) {
          WbHiveStorage.getInstanse().put('${_device.name}.mode', value);
        }
        device.mode = value;
        wbPublish(
          '${_device.name}/mode',
          WbValueCodec.encode(value, WbControlType.text),
          retained: true,
        );
        return;
    }
  }

  Set<String> inputs() => {
    '${_device.name}/switch_state/on',
    '${_device.name}/power/on',
  };

  Set<String> outputs() => {
    '${_device.name}/lamp/on',
    '${_device.name}/mode/on',
  };
}
