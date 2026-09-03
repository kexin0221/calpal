import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final name = TextEditingController();
  final brand = TextEditingController();
  final kcal = TextEditingController();

  String category = "奶茶店";

  Future<void> save() async {
    if (name.text.isEmpty || kcal.text.isEmpty) return;

    await DatabaseHelper.instance.addFood(
      name: name.text,
      brand: brand.text,
      category: category,
      calories: int.parse(kcal.text),
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("添加食物")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "食物名称"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: brand,
              decoration: const InputDecoration(labelText: "品牌"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: kcal,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "热量"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: category,
              items: const [
                DropdownMenuItem(value: "奶茶店", child: Text("奶茶店")),
                DropdownMenuItem(value: "轻食店", child: Text("轻食店")),
                DropdownMenuItem(value: "甜品店", child: Text("甜品店")),
                DropdownMenuItem(value: "快餐店", child: Text("快餐店")),
                DropdownMenuItem(value: "咖啡店", child: Text("咖啡店")),
                DropdownMenuItem(value: "小吃店", child: Text("小吃店")),
              ],
              onChanged: (v) => category = v!,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: save,
                child: const Text("保存到热量库"),
              ),
            )
          ],
        ),
      ),
    );
  }
}