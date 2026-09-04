import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../widgets/bottom_nav.dart';
import 'add_food_page.dart';
import 'brand_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();

  int categoryIndex = 0;
  int navIndex = 0;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> brands = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await loadCategories();
    await loadBrands();
  }

  Future<void> loadCategories() async {
    categories = await DatabaseHelper.instance.getCategories();

    if (categories.isNotEmpty && categoryIndex >= categories.length) {
      categoryIndex = 0;
    }

    setState(() {});
  }

  Future<void> loadBrands() async {
    if (categories.isEmpty) return;

    brands = await DatabaseHelper.instance.getBrands(
      categories[categoryIndex]["name"],
    );

    setState(() {});
  }

  Future<void> deleteBrand(int id) async {
    await DatabaseHelper.instance.deleteBrand(id);
    loadBrands();
  }

  Future<void> showCategoryEditor() async {
    final addController = TextEditingController();

    // 弹窗内部使用自己的列表
    List<Map<String, dynamic>> temp = List.from(categories);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffF5F5F7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, sheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "分类管理",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    height: 360,
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: temp.length,
                      onReorder: (oldIndex, newIndex) async {
                        if (newIndex > oldIndex) newIndex--;

                        final item = temp.removeAt(oldIndex);
                        temp.insert(newIndex, item);

                        sheet(() {});

                        await DatabaseHelper.instance
                            .updateCategoryOrder(temp);

                        await loadCategories();
                      },
                      itemBuilder: (_, i) {
                        final item = temp[i];

                        return Container(
                          key: ValueKey(item["id"]),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: ReorderableDragStartListener(
                              index: i,
                              child: const Icon(Icons.drag_indicator),
                            ),
                            title: Text(item["name"]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await DatabaseHelper.instance
                                    .deleteCategory(item["id"]);

                                temp.removeAt(i);

                                await loadCategories();
                                await loadBrands();

                                sheet(() {});
                              },
                            ),
                            onTap: () async {
                              final edit = TextEditingController(
                                text: item["name"],
                              );

                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("编辑分类"),
                                  content: TextField(
                                    controller: edit,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text("取消"),
                                    ),
                                    FilledButton(
                                      onPressed: () async {
                                        await DatabaseHelper.instance
                                            .updateCategory(
                                          item["id"],
                                          edit.text.trim(),
                                        );

                                        Navigator.pop(context);

                                        temp[i]["name"] =
                                            edit.text.trim();

                                        await loadCategories();
                                        await loadBrands();

                                        sheet(() {});
                                      },
                                      child: const Text("保存"),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: addController,
                    decoration: InputDecoration(
                      hintText: "新增分类",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        if (addController.text.trim().isEmpty) return;

                        await DatabaseHelper.instance.addCategory(
                          addController.text.trim(),
                        );

                        addController.clear();

                        await loadCategories();
                        await loadBrands();

                        temp = List.from(categories);

                        sheet(() {});
                      },
                      child: const Text("添加分类"),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyword = searchController.text.trim();

    final result = brands.where((e) {
      return e["name"].toString().contains(keyword);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // 搜索栏 + 设置
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: "搜索品牌...",
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: Row(
                children: [
                  // 左侧分类
                  Container(
                    width: 96,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ListView.builder(
                      itemCount: categories.length + 1,
                      itemBuilder: (_, i) {
                        if (i == categories.length) {
                          return GestureDetector(
                            onTap: showCategoryEditor,
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(height: 4),
                                  Text(
                                    "编辑",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }

                        final selected = i == categoryIndex;

                        return GestureDetector(
                          onTap: () async {
                            setState(() => categoryIndex = i);
                            await loadBrands();
                          },
                          child: AnimatedContainer(
                            duration:
                            const Duration(milliseconds: 180),
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                categories[i]["name"],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 品牌区域
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.fromLTRB(18, 18, 18, 8),
                            child: Row(
                              children: [
                                const Text(
                                  "品牌",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${result.length} 个",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                )
                              ],
                            ),
                          ),

                          Expanded(
                            child: result.isEmpty
                                ? const Center(
                              child: Text(
                                "暂无品牌\n点击下方 + 添加",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  height: 1.6,
                                ),
                              ),
                            )
                                : ListView.builder(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12),
                              itemCount: result.length,
                              itemBuilder: (_, i) {
                                final brand = result[i];

                                return Dismissible(
                                  key: ValueKey(brand["id"]),
                                  direction:
                                  DismissDirection.endToStart,
                                  background: Container(
                                    margin:
                                    const EdgeInsets.only(
                                        bottom: 12),
                                    alignment:
                                    Alignment.centerRight,
                                    padding:
                                    const EdgeInsets.only(
                                        right: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                      BorderRadius.circular(
                                          18),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (_) =>
                                      deleteBrand(brand["id"]),
                                  child: GestureDetector(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BrandPage(
                                                brandId:
                                                brand["id"],
                                                brandName:
                                                brand["name"],
                                              ),
                                        ),
                                      );

                                      loadBrands();
                                    },
                                    child: Container(
                                      margin:
                                      const EdgeInsets.only(
                                          bottom: 12),
                                      padding:
                                      const EdgeInsets.all(
                                          14),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            18),
                                        border: Border.all(
                                          color: Colors
                                              .grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor:
                                            Colors.grey
                                                .shade100,
                                            child: const Icon(
                                              Icons
                                                  .storefront_outlined,
                                              color:
                                              Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(
                                              width: 14),
                                          Expanded(
                                            child: Text(
                                              brand["name"],
                                              style:
                                              const TextStyle(
                                                fontSize: 17,
                                                fontWeight:
                                                FontWeight
                                                    .w600,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons
                                                .chevron_right_rounded,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

            // 底部导航
            Padding(
              padding:
              const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: BottomNav(
                index: navIndex,
                onTap: (i) async {
                  setState(() => navIndex = i);

                  if (i == 1 && categories.isNotEmpty) {
                    final ok = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddFoodPage(
                          category:
                          categories[categoryIndex]["name"],
                        ),
                      ),
                    );

                    if (ok == true) {
                      loadBrands();
                    }

                    setState(() => navIndex = 0);
                  }

                  if (i == 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("吃什么转盘开发中"),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    setState(() => navIndex = 0);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}