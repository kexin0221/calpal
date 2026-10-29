
class CsvService {
  static List<Map<String, dynamic>> parseText(String input) {
    final text = input.replaceFirst('\uFEFF', '');
    final lines = text.split(RegExp(r'\r\n|\n|\r'));
    final foodsByName = <String, Map<String, dynamic>>{};
    var firstNonEmptyLine = true;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (firstNonEmptyLine) {
        firstNonEmptyLine = false;
        final lower = line.toLowerCase();
        final hasName = lower.contains('名称') ||
            lower.contains('name') ||
            lower.contains('产品') ||
            lower.contains('食品');
        final hasCalories = lower.contains('热量') ||
            lower.contains('卡路里') ||
            lower.contains('calorie') ||
            lower.contains('kcal') ||
            lower.contains('大卡') ||
            lower.contains('千卡');

        if (hasName && hasCalories) continue;
      }

      final parts = line.split(RegExp(r'[,，]'));
      if (parts.length != 2) continue;

      final name = parts[0].trim();
      final calorieText = parts[1]
          .trim()
          .replaceAll(RegExp(r'\s+'), '');

      final match = RegExp(
        r'^(\d+)(?:kcal|千卡|大卡|卡)?$',
        caseSensitive: false,
      ).firstMatch(calorieText);

      final calories = int.tryParse(match?.group(1) ?? '');

      if (name.isEmpty || calories == null || calories <= 0) {
        continue;
      }

      foodsByName[name.toLowerCase()] = {
        'name': name,
        'calories': calories,
      };
    }

    return foodsByName.values.toList();
  }
}
