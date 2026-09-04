import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    foods = await DatabaseHelper.instance.getFoods(widget.brandId);
    applyFilterAndSort();
  }

  //==========================
  // 热量颜色
  //==========================
  Color calorieColor(int calories) {
    if (calories < 300) {
      return const Color(0xFF22C55E);
    } else if (calories < 400) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  //==========================
  // 排序 + 筛选 + 搜索
  //==========================
  void applyFilterAndSort() {
    displayFoods = List<Map<String, dynamic>>.from(foods);

    // 搜索
    if (searchText.isNotEmpty) {
      displayFoods = displayFoods.where((food) {
        return food["name"]
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase());
      }).toList();
    }

    // 筛选
    if (selectedFilters.isNotEmpty) {
      displayFoods = displayFoods.where((food) {
        final c = food["calories"] as int;

        if (selectedFilters.contains("0-300") && c < 300) return true;
        if (selectedFilters.contains("300-400") &&
            c >= 300 &&
            c < 400) return true;
        if (selectedFilters.contains("400-500") &&
            c >= 400 &&
            c < 500) return true;
        if (selectedFilters.contains("500+") && c >= 500) return true;

        return false;
      }).toList();
    }

    // 排序
    displayFoods.sort((a, b) {
      final result = a["calories"].compareTo(b["calories"]);
      return sortAscending ? result : -result;
    });

    setState(() {});
  }

  //==========================
  // 新增产品
  //==========================
  Future<void> addFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddFoodPage(
          brandId: widget.brandId,
          category: widget.category,
        ),
      ),
    );

    if (result == true) {
      loadFoods();
    }
  }

  //==========================
  // 编辑产品
  //==========================
  Future<void> editFood(Map<String, dynamic> food) async {
    final nameController = TextEditingController(text: food["name"]);
    final calorieController =
    TextEditingController(text: food["calories"].toString());

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
              decoration: const InputDecoration(labelText: "热量"),
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

    await DatabaseHelper.instance.updateFood(
      id: food["id"],
      name: nameController.text.trim(),
      calories: int.tryParse(calorieController.text) ?? 0,
    );

    loadFoods();
  }

  //==========================
  // 删除产品
  //==========================
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

  //==========================
  // CSV 导入
  //==========================
  Future<void> importCsv() async {
    final list = await CsvService.pickCsv();

    if (list == null) return;

    await DatabaseHelper.instance.addFoodsBatch(
      brandId: widget.brandId,
      foods: list,
    );

    await loadFoods();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("成功导入 ${list.length} 个产品")),
      );
    }
  }

  //==========================
  // 筛选弹窗
  //==========================
  Future<void> showFilterSheet() async {
    Set<String> temp = Set.from(selectedFilters);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return StatefulBuilder(
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () {
                              selectedFilters = temp;
                              Navigator.pop(context);
                              applyFilterAndSort();
                            },
                            child: const Text("完成"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  //==========================
  // UI
  //==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.brandName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              sortAscending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              sortAscending = !sortAscending;
              applyFilterAndSort();
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_rounded, color: Colors.black),
                if (selectedFilters.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: addFood,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == "csv") importCsv();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "csv",
                child: Row(
                  children: [
                    Icon(Icons.table_chart_outlined),
                    SizedBox(width: 8),
                    Text("导入 CSV"),
                  ],
                ),
              )
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          //==========================
          // 搜索框（无提示文本）
          //==========================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(23),
              ),
              child: TextField(
                onChanged: (v) {
                  searchText = v;
                  applyFilterAndSort();
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          //==========================
          // 产品列表
          //==========================
          Expanded(
            child: displayFoods.isEmpty
                ? const Center(
              child: Text(
                "暂无产品",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: displayFoods.length,
              itemBuilder: (context, index) {
                final food = displayFoods[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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

                      const SizedBox(width: 8),

                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) {
                          if (value == "edit") {
                            editFood(food);
                          } else {
                            deleteFood(food);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: "edit",
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined),
                                SizedBox(width: 8),
                                Text("编辑"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "delete",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "删除",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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