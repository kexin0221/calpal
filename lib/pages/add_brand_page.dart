import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddBrandPage extends StatefulWidget {
  const AddBrandPage({super.key});

  @override
  State<AddBrandPage> createState() => _AddBrandPageState();
}

class _AddBrandPageState extends State<AddBrandPage> {
  final name = TextEditingController();
  String category = "奶茶店";

  Future<void> save() async {
    if (name.text.isEmpty) return;

    await DatabaseHelper.instance.addBrand(
      category: category,
      name: name.text,
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("添加品牌")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "品牌名称"),
            ),
            const SizedBox(height: 16),
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
                child: const Text("保存品牌"),
              ),
            )
          ],
        ),
      ),
    );
  }
}