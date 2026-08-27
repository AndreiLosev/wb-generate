import 'package:build/build.dart';

import 'dart_config_codegen.dart';
import 'yaml_config_parser.dart';

/// Генерирует [lib/wb_config.g.dart] из секции `wirenboard` в pubspec.yaml.
class WbConfigBuilder implements Builder {
  WbConfigBuilder(BuilderOptions options)
    : _currentEnv = _readCurrentEnv(options);

  final String _currentEnv;

  static String _readCurrentEnv(BuilderOptions options) {
    final value = options.config['current_env'];
    if (value == null) {
      return 'dev';
    }
    if (value is! String) {
      throw YamlConfigException(
        'wb_config builder option "current_env" must be a string, '
        'got ${value.runtimeType}.',
      );
    }
    return value;
  }

  @override
  final buildExtensions = const {
    'pubspec.yaml': ['lib/wb_config.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final content = await buildStep.readAsString(buildStep.inputId);

    try {
      final model = YamlConfigParser.tryParse(content, currentEnv: _currentEnv);
      if (model == null) {
        return;
      }
      final output = DartConfigCodegen.generate(model);
      final outputId = AssetId(
        buildStep.inputId.package,
        'lib/wb_config.g.dart',
      );
      await buildStep.writeAsString(outputId, output);
    } on YamlConfigException catch (error) {
      log.severe(error.message);
      rethrow;
    }
  }
}
