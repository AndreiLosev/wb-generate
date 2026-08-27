// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wo_switch_device.dart';

mixin WoSwitchDeviceWbMixin {
  IDevice get _device => this as IDevice;

  static const Map<String, String> _controlMetaJson = {
    'feedback':
        '{"type":"wo-switch","title":{"en":"feedback"},"order":1,"readonly":false,"hidden":false}',
    'relay':
        '{"type":"wo-switch","title":{"en":"relay"},"order":2,"readonly":false,"hidden":false}',
  };

  /// Публикует retained meta устройства, контролов и output values.
  void init() {
    final device = this as WoSwitchDevice;
    WbClient.getInstanse().publish(
      '${_device.name}/meta',
      WbMetaJson.device(_device.title),
      retained: true,
    );

    for (final entry in _controlMetaJson.entries) {
      final topic = '${_device.name}/${entry.key}/meta';
      WbClient.getInstanse().publish(topic, entry.value, retained: true);
    }

    setRelay(device.relay);
  }

  void setRelay(bool value) {
    final device = this as WoSwitchDevice;
    device.relay = value;
    WbClient.getInstanse().publish(
      '${_device.name}/relay',
      WbValueCodec.encode(value, WbControlType.woSwitch),
      retained: true,
    );
  }

  void updateField(WbMqttMessage mess) {
    final device = this as WoSwitchDevice;
    final namePrefix = '${_device.name}/';
    if (!mess.topic.startsWith(namePrefix)) {
      return;
    }
    switch (mess.topic.substring(namePrefix.length)) {
      case 'feedback/on':
        final value =
            WbValueCodec.decode(mess.payload, WbControlType.woSwitch) as bool;
        device.feedback = value;
        WbClient.getInstanse().publish(
          '${_device.name}/feedback',
          WbValueCodec.encode(value, WbControlType.woSwitch),
          retained: true,
        );
        return;
      case 'relay/on':
        final value =
            WbValueCodec.decode(mess.payload, WbControlType.woSwitch) as bool;
        device.relay = value;
        WbClient.getInstanse().publish(
          '${_device.name}/relay',
          WbValueCodec.encode(value, WbControlType.woSwitch),
          retained: true,
        );
        return;
    }
  }

  Set<String> inputs() => {'${_device.name}/feedback/on'};

  Set<String> outputs() => {'${_device.name}/relay/on'};
}
