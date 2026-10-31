
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();

  bool _hasMultiplePortions = false;

  final List<TextEditingController> _portionNameControllers = [];
  final List<TextEditingController> _portionCalorieControllers = [];

  void _addPortion() {
    setState(() {
      _portionNameControllers.add(TextEditingController());
      _portionCalorieControllers.add(TextEditingController());
    });
  }

  void _removePortion(int index) {
    setState(() {
      _portionNameControllers.removeAt(index).dispose();
      _portionCalorieControllers.removeAt(index).dispose();
    });
  }

  void _toggleMultiplePortions(bool value) {
    setState(() {
      _hasMultiplePortions = value;

      if (value && _portionNameControllers.isEmpty) {
        for (int i = 0; i < 2; i++) {
          _portionNameControllers.add(TextEditingController());
          _portionCalorieControllers.add(TextEditingController());
        }
      }

      if (!value) {
        for (final controller in _portionNameControllers) {
          controller.dispose();
        }
        for (final controller in _portionCalorieControllers) {
          controller.dispose();
        }
        _portionNameControllers.clear();
        _portionCalorieControllers.clear();
      }
    });
  }

  Future<void> _saveFood() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入产品名称")),
      );
      return;
    }

    if (!_hasMultiplePortions) {
      final calories = int.tryParse(_calorieController.text);

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

      for (int i = 0; i < _portionNameControllers.length; i++) {
        final portionName = _portionNameControllers[i].text.trim();
        final calories = int.tryParse(
          _portionCalorieControllers[i].text.trim(),
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

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();

    for (final controller in _portionNameControllers) {
      controller.dispose();
    }

    for (final controller in _portionCalorieControllers) {
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
                      controller: _nameController,
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
                      value: _hasMultiplePortions,
                      onChanged: _toggleMultiplePortions,
                    ),
                    const SizedBox(height: 8),
                    if (!_hasMultiplePortions) ...[
                      Text(
                        "热量（kcal）",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _calorieController,
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
                      i < _portionNameControllers.length;
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
                            if (_portionNameControllers.length > 2)
                              IconButton(
                                onPressed: () => _removePortion(i),
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
                                controller: _portionNameControllers[i],
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
                                controller: _portionCalorieControllers[i],
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
                          onPressed: _addPortion,
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
                onPressed: _saveFood,
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