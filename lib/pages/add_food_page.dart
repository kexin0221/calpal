
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddFoodPage extends StatefulWidget {
  final int brandId;
  final String category;

  const AddFoodPage({
    super.key,
    required this.brandId,
    required this.category,
  });

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController calorieController = TextEditingController();

  Future<void> saveFood() async {
    final name = nameController.text.trim();
    final calories = int.tryParse(calorieController.text);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入产品名称")),
      );
      return;
    }

    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入正确的热量")),
      );
      return;
    }

    await DatabaseHelper.instance.addFood(
      brandId: widget.brandId,
      name: name,
      calories: calories,
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    calorieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "添加产品",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "产品名称",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "热量（kcal）",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: calorieController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: saveFood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                child: const Text(
                  "保存产品",
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