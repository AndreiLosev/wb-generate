// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// WbDeviceGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_title_samples.dart';

mixin ControlTitleSamplesWbMixin {
  IDevice get _device => this as IDevice;

  final Map<String, Map<String, dynamic>> _controlMetaJson = {
    'wall_switch': {
      'type': 'switch',
      'title': {'en': 'wall_switch'},
      'order': 1,
      'readonly': false,
      'hidden': false,
    },
    'kitchen_switch': {
      'type': 'switch',
      'title': {'en': 'kitchen_switch', 'ru': 'Выключатель'},
      'order': 2,
      'readonly': false,
      'hidden': false,
    },
  };

  /// Публикует retained meta, затем значения output-контролов и вызывает execute().
  void init() {
    final device = this as ControlTitleSamples;

    wbPublish(
      '${_device.name}/meta',
      WbMetaJson.device(_device.title),
      retained: true,
    );

    wbPublish(
      '${_device.name}/wall_switch/meta',
      WbControlType.meta(_controlMetaJson['wall_switch']!),
      retained: true,
    );
    wbPublish(
      '${_device.name}/kitchen_switch/meta',
      WbControlType.meta(_controlMetaJson['kitchen_switch']!),
      retained: true,
    );

    device.execute();
  }

  void updateField(WbMqttMessage mess) {
    final device = this as ControlTitleSamples;
    final namePrefix = '${_device.name}/';
    if (!mess.topic.startsWith(namePrefix)) {
      return;
    }
    switch (mess.topic.substring(namePrefix.length)) {
      case 'wall_switch/on':
        final value =
            WbValueCodec.decode(mess.payload, WbControlType.switch_) as bool;
        device.wallSwitch = value;
        wbPublish(
          '${_device.name}/wall_switch',
          WbValueCodec.encode(value, WbControlType.switch_),
          retained: true,
        );
        return;
      case 'kitchen_switch/on':
        final value =
            WbValueCodec.decode(mess.payload, WbControlType.switch_) as bool;
        device.kitchenSwitch = value;
        wbPublish(
          '${_device.name}/kitchen_switch',
          WbValueCodec.encode(value, WbControlType.switch_),
          retained: true,
        );
        return;
    }
  }

  Set<String> inputs() => {
    '${_device.name}/wall_switch/on',
    '${_device.name}/kitchen_switch/on',
  };

  Set<String> outputs() => {};
}
