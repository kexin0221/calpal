class CsvService {
  static final _caloriesPattern = RegExp(
    r'^(\d+)(?:kcal|千卡|大卡|卡)?$',
    caseSensitive: false,
  );
  static final _portionPattern = RegExp(
    r'^(.+?)(\d+)\s*(?:kcal|千卡|大卡|卡)?$',
    caseSensitive: false,
  );

  static int? _parseCalories(String text) {
    final value = text.trim().replaceAll(RegExp(r'\s+'), '');
    final match = _caloriesPattern.firstMatch(value);
    final calories = int.tryParse(match?.group(1) ?? '');
    return calories != null && calories > 0 ? calories : null;
  }

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
      if (parts.length < 2) continue;

      final name = parts.first.trim();
      if (name.isEmpty) continue;

      final portions = <Map<String, dynamic>>[];
      var valid = true;

      if (parts.length == 2) {
        final calories = _parseCalories(parts[1]);

        if (calories == null) continue;

        foodsByName[name.toLowerCase()] = {
          'name': name,
          'calories': calories,
        };

        continue;
      }

      for (final part in parts.skip(1)) {
        final match = _portionPattern.firstMatch(part.trim());

        if (match == null) {
          valid = false;
          break;
        }

        final portionName = match.group(1)!.trim();
        final calories = int.tryParse(match.group(2)!);

        if (portionName.isEmpty || calories == null || calories <= 0) {
          valid = false;
          break;
        }

        portions.add({
          'name': portionName,
          'calories': calories,
        });
      }

      if (!valid || portions.length < 2) continue;

      foodsByName[name.toLowerCase()] = {
        'name': name,
        'calories': portions.first['calories'],
        'portions': portions,
      };
    }

    return foodsByName.values.toList();
  }
}