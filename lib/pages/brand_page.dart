import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../database/database_helper.dart';
import '../services/csv_service.dart';
import 'add_food_page.dart';

class BrandPage extends StatefulWidget {
  final int brandId;
  final String brandName;
  final String category;

  const BrandPage({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.category,
  });

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  List<Map<String, dynamic>> foods = [];
  List<Map<String, dynamic>> displayFoods = [];

  bool sortAscending = true;
  Set<String> selectedFilters = {};
  String searchText = "";

  String brandRemark = "";

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    foods = await DatabaseHelper.instance.getFoods(widget.brandId);
    brandRemark = await DatabaseHelper.instance.getBrandRemark(widget.brandId);
    applyFilterAndSort();
  }

  Color calorieColor(int calories) {
    if (calories < 300) return const Color(0xFF22C55E);
    if (calories < 400) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  void applyFilterAndSort() {
    displayFoods = List<Map<String, dynamic>>.from(foods);

    if (searchText.isNotEmpty) {
      displayFoods = displayFoods.where((food) {
        return food["name"].toString().toLowerCase().contains(
          searchText.toLowerCase(),
        );
      }).toList();
    }

    if (selectedFilters.isNotEmpty) {
      displayFoods = displayFoods.where((food) {
        final c = food["calories"] as int;
        if (selectedFilters.contains("0-300") && c < 300) return true;
        if (selectedFilters.contains("300-400") && c >= 300 && c < 400) {
          return true;
        }
        if (selectedFilters.contains("400-500") && c >= 400 && c < 500) {
          return true;
        }
        if (selectedFilters.contains("500+") && c >= 500) return true;
        return false;
      }).toList();
    }

    displayFoods.sort((a, b) {
      final result = a["calories"].compareTo(b["calories"]);
      return sortAscending ? result : -result;
    });

    setState(() {});
  }

  Future<void> addFood() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddFoodPage(brandId: widget.brandId, category: widget.category),
      ),
    );

    if (result == true) {
      await loadFoods();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("产品添加成功")));
    }
  }

  Future<void> editRemark() async {
    final controller = TextEditingController(text: brandRemark);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("品牌备注"),
        content: TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 200,
          decoration: const InputDecoration(
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          if (brandRemark.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, ""),
              child: const Text(
                "删除",
                style: TextStyle(color: Colors.red),
              ),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text("保存"),
          ),
        ],
      ),
    );

    if (result == null) return;

    await DatabaseHelper.instance.updateBrandRemark(
      id: widget.brandId,
      remark: result,
    );

    await loadFoods();
  }

  Future<void> editFood(Map<String, dynamic> food) async {
    final nameController = TextEditingController(text: food["name"]);
    final calorieController = TextEditingController(
      text: food["calories"].toString(),
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("编辑产品"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "产品名称"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: calorieController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "热量(kcal)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("保存"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final name = nameController.text.trim();
    final calories = int.tryParse(calorieController.text);

    if (name.isEmpty || calories == null || calories <= 0) return;

    await DatabaseHelper.instance.updateFood(
      id: food["id"],
      name: name,
      calories: calories,
    );

    await loadFoods();
  }

  Future<void> deleteFood(Map<String, dynamic> food) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("删除产品"),
        content: Text("确定删除「${food["name"]}」吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("删除"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await DatabaseHelper.instance.deleteFood(food["id"]);
    loadFoods();
  }

  Future<void> importCsv() async {
    final list = await CsvService.pickCsv();
    if (list == null || list.isEmpty) return;

    await DatabaseHelper.instance.addFoodsBatch(
      brandId: widget.brandId,
      foods: list,
    );

    await loadFoods();
  }

  Future<void> renameBrand() async {
    final controller = TextEditingController(text: widget.brandName);

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("修改品牌名"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: "品牌名称"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("保存"),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;

    await DatabaseHelper.instance.updateBrand(
      id: widget.brandId,
      name: newName,
    );

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> deleteBrand() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("删除品牌"),
        content: Text("确定删除「${widget.brandName}」吗？\n该品牌下所有产品都会删除。"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("删除"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await DatabaseHelper.instance.deleteBrand(widget.brandId);

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> showFilterSheet() async {
    Set<String> temp = Set.from(selectedFilters);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) {
          Widget item(String label) {
            final checked = temp.contains(label);

            return CheckboxListTile(
              value: checked,
              activeColor: Colors.black,
              title: Text(label),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (_) {
                setSheet(() {
                  checked ? temp.remove(label) : temp.add(label);
                });
              },
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "热量筛选",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  item("0-300"),
                  item("300-400"),
                  item("400-500"),
                  item("500+"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            temp.clear();
                            setSheet(() {});
                          },
                          child: const Text("清空"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            selectedFilters = temp;
                            Navigator.pop(context);
                            applyFilterAndSort();
                          },
                          child: const Text("完成"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.brandName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case "add":
                  addFood();
                  break;
                case "csv":
                  importCsv();
                  break;
                case "rename":
                  renameBrand();
                  break;
                case "remark":
                  editRemark();
                  break;
                case "delete":
                  deleteBrand();
                  break;

              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "add",
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 10),
                    Text("添加产品"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "csv",
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 10),
                    Text("导入 CSV"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "rename",
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text("修改品牌名"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "remark",
                child: Row(
                  children: [
                    Icon(Icons.sticky_note_2_outlined),
                    SizedBox(width: 10),
                    Text("备注"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "delete",
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text("删除品牌", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (value) {
                        searchText = value;
                        applyFilterAndSort();
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    onPressed: () {
                      sortAscending = !sortAscending;
                      applyFilterAndSort();
                    },
                    icon: Icon(
                      sortAscending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    onPressed: showFilterSheet,
                    icon: const Icon(Icons.tune_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
          if (brandRemark.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "注：$brandRemark",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          Expanded(
            child: displayFoods.isEmpty
                ? const Center(
                    child: Text("暂无产品", style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: displayFoods.length,
                    itemBuilder: (context, index) {
                      final food = displayFoods[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Slidable(
                          key: ValueKey(food["id"]),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.50,
                            children: [
                              SlidableAction(
                                onPressed: (_) => editFood(food),
                                backgroundColor: const Color(0xFF2D2D2D),
                                foregroundColor: Colors.white,
                                icon: Icons.edit_outlined,
                                label: "编辑",
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  bottomLeft: Radius.circular(18),
                                ),
                              ),
                              SlidableAction(
                                onPressed: (_) => deleteFood(food),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline,
                                label: "删除",
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(18),
                                  bottomRight: Radius.circular(18),
                                ),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    food["name"],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${food["calories"]}",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: calorieColor(food["calories"]),
                                      ),
                                    ),
                                    const Text(
                                      "kcal",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
