
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

  /// 加载分类和品牌
  Future<void> loadData() async {
    final categoryData = await db.getCategories();

    if (!mounted) return;

    if (categoryData.isEmpty) {
      setState(() {
        categories = [];
        brands = [];
        filteredCategories = [];
        selectedCategory = "";
      });
      return;
    }

    if (selectedCategory.isEmpty ||
        !categoryData.any((e) => e["name"] == selectedCategory)) {
      selectedCategory = categoryData.first["name"];
    }

    final brandData = await db.getBrands(selectedCategory);

    if (!mounted) return;

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

    if (!mounted) return;

    setState(() {
      wheelRefreshKey++;
    });
  }

  Future<void> loadBrands() async {
    if (selectedCategory.isEmpty) {
      if (mounted) {
        setState(() {
          brands = [];
        });
      }
      return;
    }

    final brandData = await db.getBrands(selectedCategory);

    if (!mounted) return;

    setState(() {
      if (searchText.isEmpty) {
        brands = brandData;
      } else {
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

    if (searchText.isEmpty) {
      filteredCategories = List.from(categories);

      if (filteredCategories.isNotEmpty &&
          !filteredCategories.any((e) => e["name"] == selectedCategory)) {
        selectedCategory = filteredCategories.first["name"];
      }

      await loadBrands();
      return;
    }

    final result = <Map<String, dynamic>>[];

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

    if (!mounted) return;

    if (result.isEmpty) {
      setState(() {
        filteredCategories = [];
        brands = [];
      });
      return;
    }

    selectedCategory = result.first["name"];

    final firstBrands = await db.getBrands(selectedCategory);

    if (!mounted) return;

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
    if (selectedCategory.isEmpty) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddBrandPage(category: selectedCategory),
      ),
    );

    if (result == true) {
      await loadBrands();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: bottomIndex == 2 ? 1 : 0,
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // 搜索和设置
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            onChanged: searchBrands,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
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

                          if (!mounted) return;

                          await loadData();
                          await refreshWheel();
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.settings,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: Row(
                    children: [
                      // 左侧分类
                      Container(
                        width: 112,
                        margin: const EdgeInsets.only(
                          left: 14,
                          bottom: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          itemCount: filteredCategories.length,
                          itemBuilder: (_, index) {
                            final category =
                            filteredCategories[index]["name"];
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
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
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
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface
                                                .withValues(alpha: 0.87),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (selected && searchText.isEmpty) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          "${brands.length}",
                                          style: TextStyle(
                                            color: colorScheme.onPrimary
                                                .withValues(alpha: 0.70),
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

                      // 右侧品牌
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(
                            right: 14,
                            bottom: 12,
                          ),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: brands.isEmpty
                              ? Center(
                            child: Text(
                              "暂无品牌\n点击下方 + 添加",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                          )
                              : ListView.builder(
                            itemCount: brands.length,
                            itemBuilder: (_, i) {
                              final brand = brands[i];

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: Material(
                                  color: theme.brightness == Brightness.dark
                                      ? const Color(0xFF2C2C2E)
                                      : const Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(18),
                                  child: InkWell(
                                    borderRadius:
                                    BorderRadius.circular(18),
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
                                            child: Row(
                                              children: [
                                                if ((brand["isTop"] ??
                                                    0) ==
                                                    1)
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                      right: 6,
                                                    ),
                                                    child: Icon(
                                                      Icons.push_pin,
                                                      size: 14,
                                                      color: colorScheme
                                                          .onSurface
                                                          .withValues(
                                                        alpha: 0.55,
                                                      ),
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Text(
                                                    brand["name"],
                                                    style: TextStyle(
                                                      color: colorScheme
                                                          .onSurface,
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                    ),
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.55),
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

          // 转盘页
          WheelPage(key: ValueKey(wheelRefreshKey)),
        ],
      ),

      // 底部导航
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          height: 72,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.92),
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
    final colorScheme = Theme.of(context).colorScheme;
    final selected = bottomIndex == index;

    return GestureDetector(
      onTap: () async {
        if (index == 2) {
          await refreshWheel();
        }

        if (!mounted) return;

        setState(() {
          bottomIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 108,
        height: 54,
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.55),
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: selectedCategory.isEmpty ? null : openAddBrand,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          color: colorScheme.onPrimary,
          size: 30,
        ),
      ),
    );
  }
}