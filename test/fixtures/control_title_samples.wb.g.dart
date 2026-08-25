// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_title_samples.dart';

mixin ControlTitleSamplesWbMixin {
  static const String deviceName = 'title_samples';

  static const String _deviceMetaTopic = 'title_samples/meta';

  static const String _deviceMetaJson =
      '{"driver":"vktmotage","title":{"en":"Title Samples"}}';

  static const Map<String, String> _controlMetaJson = {
    'wall_switch': '{"type":"switch","title":{"en":"wall_switch"}}',
    'kitchen_switch':
        '{"type":"switch","title":{"en":"kitchen_switch","ru":"Выключатель"}}',
  };

  static const Set<String> _inputTopics = {
    'title_samples/wall_switch',
    'title_samples/kitchen_switch',
  };

  static const Set<String> _outputTopics = {};

  static const Map<String, String> _outputValueTopics = {};

  /// Публикует retained meta устройства, контролов и output values.
  void init() {
    (this as ControlTitleSamples).mqtt.publish(
      _deviceMetaTopic,
      _deviceMetaJson,
      retained: true,
    );

    for (final entry in _controlMetaJson.entries) {
      final topic = 'title_samples/${entry.key}/meta';
      (this as ControlTitleSamples).mqtt.publish(
        topic,
        entry.value,
        retained: true,
      );
    }
  }

  @override
  void updateField(WbMqttMessage mess) {
    final device = this as ControlTitleSamples;
    switch (mess.topic) {
      case 'title_samples/wall_switch':
        device.wallSwitch =
            WbValueCodec.decode(mess.payload, WbControlType.switch_) as bool;
        return;
      case 'title_samples/kitchen_switch':
        device.kitchenSwitch =
            WbValueCodec.decode(mess.payload, WbControlType.switch_) as bool;
        return;
    }
  }

  Set<String> inputs() => _inputTopics;

  Set<String> outputs() => _outputTopics;
}
