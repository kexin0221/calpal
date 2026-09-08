import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'add_brand_page.dart';
import 'brand_page.dart';
import 'category_manage_page.dart';
import 'settings_page.dart';
import 'wheel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = DatabaseHelper.instance;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> filteredCategories = [];

  String selectedCategory = "";
  String searchText = "";
  int bottomIndex = 0;
  int wheelRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// 加载分类 + 品牌
  Future<void> loadData() async {
    final categoryData = await db.getCategories();

    if (categoryData.isEmpty) return;

    if (selectedCategory.isEmpty ||
        !categoryData.any((e) => e["name"] == selectedCategory)) {
      selectedCategory = categoryData.first["name"];
    }

    final brandData = await db.getBrands(selectedCategory);

    setState(() {
      categories = categoryData;
      filteredCategories = List.from(categoryData);

      brands = brandData
          .where(
            (e) => e["name"].toString().toLowerCase().contains(
              searchText.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  Future<void> refreshWheel() async {
    await loadData();

    setState(() {
      wheelRefreshKey++;
    });
  }

  Future<void> loadBrands() async {
    final brandData = await db.getBrands(selectedCategory);

    setState(() {
      if (searchText.isEmpty) {
        // 正常状态：显示当前分类全部品牌
        brands = brandData;
      } else {
        // 搜索状态：只显示匹配品牌
        brands = brandData
            .where(
              (e) => e["name"].toString().toLowerCase().contains(
                searchText.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  Future<void> searchBrands(String keyword) async {
    searchText = keyword.trim();

    // 清空搜索：恢复全部分类
    if (searchText.isEmpty) {
      filteredCategories = List.from(categories);

      if (!filteredCategories.any((e) => e["name"] == selectedCategory)) {
        selectedCategory = filteredCategories.first["name"];
      }

      await loadBrands();
      return;
    }

    final result = <Map<String, dynamic>>[];

    // 按原分类顺序查找
    for (final category in categories) {
      final list = await db.getBrands(category["name"] as String);

      final matched = list
          .where(
            (e) => e["name"].toString().toLowerCase().contains(
              searchText.toLowerCase(),
            ),
          )
          .toList();

      if (matched.isNotEmpty) {
        result.add(category);
      }
    }

    if (result.isEmpty) {
      setState(() {
        filteredCategories = [];
        brands = [];
      });
      return;
    }

    selectedCategory = result.first["name"];

    final firstBrands = await db.getBrands(selectedCategory);

    setState(() {
      filteredCategories = result;
      brands = firstBrands
          .where(
            (e) => e["name"].toString().toLowerCase().contains(
              searchText.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  Future<void> openAddBrand() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddBrandPage(category: selectedCategory),
      ),
    );

    if (result == true) {
      loadBrands();
    }
  }

  Future<void> openCategoryManage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryManagePage()),
    );

    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      body: IndexedStack(
        index: bottomIndex == 2 ? 1 : 0,
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // 搜索 + 设置
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
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
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: searchBrands,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );

                          await refreshWheel();
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.settings, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: Row(
                    children: [
                      // ===== 左侧分类 =====
                      Container(
                        width: 112,
                        margin: const EdgeInsets.only(left: 14, bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          itemCount: filteredCategories.length,
                          itemBuilder: (_, index) {
                            final category = filteredCategories[index]["name"];
                            final selected = category == selectedCategory;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                                loadBrands();
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                height: 52,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.black
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          category,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: selected
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (selected && searchText.isEmpty) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          "${brands.length}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ===== 右侧品牌 =====
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 14, bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: brands.isEmpty
                              ? const Center(
                            child: Text(
                              "暂无品牌\n点击下方 + 添加",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                              : ListView.builder(
                            itemCount: brands.length,
                            itemBuilder: (_, i) {
                              final brand = brands[i];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Material(
                                  color: const Color(0xffFAFAFA),
                                  borderRadius: BorderRadius.circular(18),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () async {
                                      final result =
                                      await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BrandPage(
                                            brandId: brand["id"],
                                            brandName: brand["name"],
                                            category: selectedCategory,
                                          ),
                                        ),
                                      );

                                      if (result == true) {
                                        await loadBrands();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 18,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              brand["name"],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== 转盘页 =====
          WheelPage(
            key: ValueKey(wheelRefreshKey),
          ),
        ],
      ),

      // 底部导航
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .92),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              navItem(Icons.menu_book, "热量库", 0),
              addButton(),
              navItem(Icons.casino_outlined, "转盘", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String text, int index) {
    final selected = bottomIndex == index;

    return GestureDetector(
      onTap: () async {
        if (index == 2) {
          await refreshWheel();
        }

        setState(() {
          bottomIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 108,
        height: 54,
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.grey),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addButton() {
    return GestureDetector(
      onTap: selectedCategory.isEmpty ? null : openAddBrand,
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
