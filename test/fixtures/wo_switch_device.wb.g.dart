// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wo_switch_device.dart';

mixin WoSwitchDeviceWbMixin {
  static const String deviceName = 'wo_switch_device';

  static const String _deviceMetaTopic = 'wo_switch_device/meta';

  static const String _deviceMetaJson =
      '{"driver":"vktmotage","title":{"en":"WO Switch Device"}}';

  static const Map<String, String> _controlMetaJson = {
    'feedback': '{"type":"wo-switch","title":{"en":"feedback"}}',
    'relay': '{"type":"wo-switch","title":{"en":"relay"}}',
  };

  static const Set<String> _inputTopics = {'wo_switch_device/feedback'};

  static const Set<String> _outputTopics = {'wo_switch_device/relay'};

  static const Map<String, String> _outputValueTopics = {
    'relay': 'wo_switch_device/relay/on',
  };

  /// Публикует retained meta устройства, контролов и output values.
  void init() {
    (this as WoSwitchDevice).mqtt.publish(
      _deviceMetaTopic,
      _deviceMetaJson,
      retained: true,
    );

    for (final entry in _controlMetaJson.entries) {
      final topic = 'wo_switch_device/${entry.key}/meta';
      (this as WoSwitchDevice).mqtt.publish(topic, entry.value, retained: true);
    }

    setRelay((this as WoSwitchDevice).relay);
  }

  void setRelay(bool value) {
    (this as WoSwitchDevice).mqtt.publish(
      _outputValueTopics['relay']!,
      WbValueCodec.encode(value, WbControlType.woSwitch),
      retained: true,
    );
  }

  @override
  void updateField(WbMqttMessage mess) {
    final device = this as WoSwitchDevice;
    switch (mess.topic) {
      case 'wo_switch_device/feedback':
        device.feedback =
            WbValueCodec.decode(mess.payload, WbControlType.woSwitch) as bool;
        return;
      case 'wo_switch_device/relay':
        device.relay =
            WbValueCodec.decode(mess.payload, WbControlType.woSwitch) as bool;
        return;
    }
  }

  Set<String> inputs() => _inputTopics;

  Set<String> outputs() => _outputTopics;
}
