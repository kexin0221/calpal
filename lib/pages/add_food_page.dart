
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

  bool hasMultiplePortions = false;

  final List<TextEditingController> portionNameControllers = [];
  final List<TextEditingController> portionCalorieControllers = [];

  void addPortion() {
    setState(() {
      portionNameControllers.add(TextEditingController());
      portionCalorieControllers.add(TextEditingController());
    });
  }

  void removePortion(int index) {
    setState(() {
      portionNameControllers.removeAt(index).dispose();
      portionCalorieControllers.removeAt(index).dispose();
    });
  }

  void toggleMultiplePortions(bool value) {
    setState(() {
      hasMultiplePortions = value;

      if (value && portionNameControllers.isEmpty) {
        for (int i = 0; i < 2; i++) {
          portionNameControllers.add(TextEditingController());
          portionCalorieControllers.add(TextEditingController());
        }
      }

      if (!value) {
        for (final controller in portionNameControllers) {
          controller.dispose();
        }
        for (final controller in portionCalorieControllers) {
          controller.dispose();
        }
        portionNameControllers.clear();
        portionCalorieControllers.clear();
      }
    });
  }

  Future<void> saveFood() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入产品名称")),
      );
      return;
    }

    if (!hasMultiplePortions) {
      final calories = int.tryParse(calorieController.text);

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
    } else {
      final portions = <Map<String, dynamic>>[];

      for (int i = 0; i < portionNameControllers.length; i++) {
        final portionName = portionNameControllers[i].text.trim();
        final calories = int.tryParse(
          portionCalorieControllers[i].text.trim(),
        );

        if (portionName.isEmpty || calories == null || calories <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("请检查第 ${i + 1} 个规格的名称和热量")),
          );
          return;
        }

        portions.add({
          "name": portionName,
          "calories": calories,
        });
      }

      await DatabaseHelper.instance.saveFoodWithPortions(
        brandId: widget.brandId,
        name: name,
        portions: portions,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    calorieController.dispose();

    for (final controller in portionNameControllers) {
      controller.dispose();
    }

    for (final controller in portionCalorieControllers) {
      controller.dispose();
    }

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
            Expanded(
              child: SingleChildScrollView(
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "有多种规格",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: hasMultiplePortions,
                      onChanged: toggleMultiplePortions,
                    ),
                    const SizedBox(height: 8),
                    if (!hasMultiplePortions) ...[
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
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ] else ...[
                      for (int i = 0;
                      i < portionNameControllers.length;
                      i++) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "规格 ${i + 1}",
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (portionNameControllers.length > 2)
                              IconButton(
                                onPressed: () => removePortion(i),
                                icon: const Icon(Icons.remove_circle_outline),
                                color: colorScheme.error,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: portionNameControllers[i],
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "名称",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: portionCalorieControllers[i],
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "热量",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: addPortion,
                          icon: const Icon(Icons.add),
                          label: const Text("添加规格"),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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