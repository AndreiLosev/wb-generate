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

/// Имя геттера топика контрола: `lamp` → `lampControl`.
String toControlGetterName(String fieldName) => '${fieldName}Control';

/// Преобразует snake_case (YAML) в camelCase (Dart): `client_id` → `clientId`.
String toCamelCase(String snakeCase) {
  final parts = snakeCase.split('_');
  if (parts.isEmpty) {
    return snakeCase;
  }

  final buffer = StringBuffer(parts.first);
  for (final part in parts.skip(1)) {
    if (part.isEmpty) {
      continue;
    }
    buffer.write(part[0].toUpperCase());
    if (part.length > 1) {
      buffer.write(part.substring(1));
    }
  }
  return buffer.toString();
}
