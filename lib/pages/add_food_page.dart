import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final TextEditingController nameController = TextEditingController();

  String category = "奶茶店";

  Future<void> saveBrand() async {
    if (nameController.text.trim().isEmpty) return;

    await DatabaseHelper.instance.addBrand(
      category: category,
      name: nameController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "添加品牌",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "品牌名称",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "例如：瑞幸咖啡",
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "店铺分类",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: category,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "奶茶店", child: Text("奶茶店")),
                    DropdownMenuItem(value: "轻食店", child: Text("轻食店")),
                    DropdownMenuItem(value: "甜品店", child: Text("甜品店")),
                    DropdownMenuItem(value: "快餐店", child: Text("快餐店")),
                    DropdownMenuItem(value: "咖啡店", child: Text("咖啡店")),
                    DropdownMenuItem(value: "小吃店", child: Text("小吃店")),
                    DropdownMenuItem(value: "其他", child: Text("其他")),
                  ],
                  onChanged: (v) {
                    setState(() => category = v!);
                  },
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: saveBrand,
                child: const Text(
                  "保存品牌",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}