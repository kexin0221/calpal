class Food {
  final int? id;
  final String name;
  final String brand;
  final String category;
  final int kcal;

  Food({
    this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.kcal,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      category: map['category'],
      kcal: map['calories'],
    );
  }
}