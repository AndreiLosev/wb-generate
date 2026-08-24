/// Преобразует имя поля из camelCase в snake_case.
String toSnakeCase(String input) {
  if (input.isEmpty) {
    return input;
  }

  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
    if (isUpper && i > 0) {
      buffer.write('_');
    }
    buffer.write(char.toLowerCase());
  }
  return buffer.toString();
}

/// Имя setter-метода для output-поля: `lamp` → `setLamp`.
String toSetterName(String fieldName) =>
    'set${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
