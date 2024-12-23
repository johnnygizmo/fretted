import 'dart:ui';

Map<String, int>? serializeColor(Color? color) {
  if (color == null) return null;
  return {
    'r': (color.r * 255).toInt(),
    'g': (color.g * 255).toInt(),
    'b': (color.b * 255).toInt(),
    'a': (color.a * 255).toInt(),
  };
}

Color deserializeColor(Map<String, int> colorMap) {
  return Color.fromRGBO(
    colorMap['r'] ?? 0,
    colorMap['g'] ?? 0,
    colorMap['b'] ?? 0,
    (colorMap['a'] ?? 255) / 255.0,
  );
}
