import 'dart:io';

import 'package:build/build.dart';
import 'package:test/test.dart';
import 'package:wb_generate/src/generator/dart_config_codegen.dart';
import 'package:wb_generate/src/generator/wb_config_builder.dart';
import 'package:wb_generate/src/generator/yaml_config_parser.dart';

void main() {
  late String fixturePubspec;

  setUp(() {
    fixturePubspec = File(
      'test/fixtures/wb_config_pubspec.yaml',
    ).readAsStringSync();
  });

  test('генерирует WbConfig только из активного окружения', () {
    final model = YamlConfigParser.parse(fixturePubspec, currentEnv: 'dev');
    final output = DartConfigCodegen.generate(model);

    final golden = File('test/goldens/wb_config.golden').readAsStringSync().trim();
    expect(output.trim(), golden);
  });

  test('не включает prod в WbConfig при currentEnv dev', () {
    final model = YamlConfigParser.parse(fixturePubspec, currentEnv: 'dev');

    expect(model.fields.map((f) => f.name), [
      'host',
      'port',
      'clientId',
      'username',
      'password',
      'dataPath',
    ]);
    expect(model.fields.singleWhere((f) => f.name == 'host').value,
        '192.168.1.24');
  });

  test('использует prod при currentEnv prod', () {
    final model = YamlConfigParser.parse(fixturePubspec, currentEnv: 'prod');

    expect(model.fields.map((f) => f.name), [
      'host',
      'port',
      'clientId',
      'dataPath',
    ]);
    expect(model.fields.singleWhere((f) => f.name == 'host').value,
        'localhost');
  });

  test('currentEnv по умолчанию dev', () {
    final model = YamlConfigParser.parse(fixturePubspec);

    expect(model.fields.singleWhere((f) => f.name == 'host').value,
        '192.168.1.24');
  });

  test('WbConfigBuilder отклоняет не-string current_env', () {
    expect(
      () => WbConfigBuilder(BuilderOptions({'current_env': 1})),
      throwsA(
        isA<YamlConfigException>().having(
          (e) => e.message,
          'message',
          contains('current_env'),
        ),
      ),
    );
  });

  test('без wirenboard tryParse возвращает null', () {
    expect(YamlConfigParser.tryParse('name: test\n'), isNull);
  });

  test('parse требует секцию wirenboard', () {
    expect(
      () => YamlConfigParser.parse('name: test\n'),
      throwsA(
        isA<YamlConfigException>().having(
          (e) => e.message,
          'message',
          contains('wirenboard'),
        ),
      ),
    );
  });

  test('current_env должен совпадать с env-блоком', () {
    expect(
      () => YamlConfigParser.parse(
        'wirenboard:\n'
        '  dev:\n'
        '    host: x\n',
        currentEnv: 'staging',
      ),
      throwsA(
        isA<YamlConfigException>().having(
          (e) => e.message,
          'message',
          contains('staging'),
        ),
      ),
    );
  });

  test('отклоняет вложенные map в env-блоке', () {
    expect(
      () => YamlConfigParser.parse(
        'wirenboard:\n'
        '  dev:\n'
        '    mqtt:\n'
        '      host: x\n',
        currentEnv: 'dev',
      ),
      throwsA(isA<YamlConfigException>()),
    );
  });
}
