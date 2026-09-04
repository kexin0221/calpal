import 'dart:convert';

class CsvService {
  static List<Map<String, dynamic>> parse(
      String csv,
      int brandId,
      ) {
    final lines = const LineSplitter().convert(csv);

    final result = <Map<String, dynamic>>[];

    for (int i = 1; i < lines.length; i++) {
      final row = lines[i].split(",");

      result.add({
        "brandId": brandId,
        "name": row[0],
        "calories": int.parse(row[1]),
      });
    }

    return result;
  }
}