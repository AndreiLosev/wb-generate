import 'package:test/test.dart';
import 'package:wb_generate/src/generator/naming.dart';

void main() {
  group('toSnakeCase', () {
    test('оставляет простые имена без изменений', () {
      expect(toSnakeCase('lamp'), 'lamp');
      expect(toSnakeCase('power'), 'power');
    });

    test('преобразует camelCase в snake_case', () {
      expect(toSnakeCase('roomTemperature'), 'room_temperature');
      expect(toSnakeCase('wallSwitch'), 'wall_switch');
    });
  });

  group('toSetterName', () {
    test('добавляет префикс set с заглавной буквой поля', () {
      expect(toSetterName('lamp'), 'setLamp');
      expect(toSetterName('switchState'), 'setSwitchState');
    });
  });
}
