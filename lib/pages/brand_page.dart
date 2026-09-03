import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food.dart';

class BrandPage extends StatefulWidget {
  final String brand;

  const BrandPage({super.key, required this.brand});

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  List<Food> foods = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await DatabaseHelper.instance.getFoods();

    foods = data
        .map((e) => Food.fromMap(e))
        .where((e) => e.brand == widget.brand)
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.brand)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: foods.length,
        itemBuilder: (_, i) {
          final f = foods[i];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    f.name,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                Text(
                  "${f.kcal}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Text("kcal"),
              ],
            ),
          );
        },
      ),
    );
  }
}