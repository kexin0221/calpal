import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'add_brand_page.dart';
import 'brand_page.dart';
import 'settings_page.dart';
import 'wheel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _brands = [];
  List<Map<String, dynamic>> _filteredCategories = [];

  String _selectedCategory = "";
  String _searchText = "";
  int _bottomIndex = 0;
  int _wheelRefreshKey = 0;
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载分类和品牌
  Future<void> _loadData() async {
    final requestId = ++_searchRequestId;
    final categoryData = await _db.getCategories();

    if (!mounted || requestId != _searchRequestId) return;

    if (categoryData.isEmpty) {
      setState(() {
        _categories = [];
        _brands = [];
        _filteredCategories = [];
        _selectedCategory = "";
      });
      return;
    }

    if (_selectedCategory.isEmpty ||
        !categoryData.any((e) => e["name"] == _selectedCategory)) {
      _selectedCategory = categoryData.first["name"];
    }

    final brandData = await _db.getBrands(_selectedCategory);

    if (!mounted || requestId != _searchRequestId) return;

    setState(() {
      _categories = categoryData;
      _filteredCategories = List.from(categoryData);

      _brands = brandData
          .where(
            (e) => e["name"]
                .toString()
                .toLowerCase()
                .contains(_searchText.toLowerCase()),
      )
          .toList();
    });
  }

  Future<void> _refreshWheel() async {
    await _loadData();

    if (!mounted) return;

    setState(() {
      _wheelRefreshKey++;
    });
  }

  Future<void> _loadBrands() async {
    final requestId = ++_searchRequestId;
    final category = _selectedCategory;

    if (category.isEmpty) {
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _brands = [];
        });
      }
      return;
    }

    final brandData = await _db.getBrands(category);

    if (!mounted || requestId != _searchRequestId) return;

    setState(() {
      if (_searchText.isEmpty) {
        _brands = brandData;
      } else {
        _brands = brandData
            .where(
              (e) => e["name"]
                  .toString()
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _searchBrands(String keyword) async {
    final requestId = ++_searchRequestId;
    _searchText = keyword.trim();
    final currentSearchText = _searchText.toLowerCase();

    if (_searchText.isEmpty) {
      _filteredCategories = List.from(_categories);

      if (_filteredCategories.isNotEmpty &&
          !_filteredCategories.any((e) => e["name"] == _selectedCategory)) {
        _selectedCategory = _filteredCategories.first["name"];
      }

      final category = _selectedCategory;

      if (category.isEmpty) {
        if (!mounted || requestId != _searchRequestId) return;

        setState(() {
          _brands = [];
        });
        return;
      }

      final brandData = await _db.getBrands(category);

      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        _brands = brandData;
      });
      return;
    }

    final result = <Map<String, dynamic>>[];

    for (final category in _categories) {
      final list = await _db.getBrands(category["name"] as String);

      if (!mounted || requestId != _searchRequestId) return;

      final matched = list
          .where(
            (e) => e["name"]
                .toString()
                .toLowerCase()
                .contains(currentSearchText),
          )
          .toList();

      if (matched.isNotEmpty) {
        result.add(category);
      }
    }

    if (!mounted || requestId != _searchRequestId) return;

    if (result.isEmpty) {
      setState(() {
        _filteredCategories = [];
        _brands = [];
      });
      return;
    }

    final firstCategory = result.first["name"] as String;
    final firstBrands = await _db.getBrands(firstCategory);

    if (!mounted || requestId != _searchRequestId) return;

    _selectedCategory = firstCategory;

    setState(() {
      _filteredCategories = result;
      _brands = firstBrands
          .where(
            (e) => e["name"]
                .toString()
                .toLowerCase()
                .contains(currentSearchText),
          )
          .toList();
    });
  }

  Future<void> _openAddBrand() async {
    if (_selectedCategory.isEmpty) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddBrandPage(category: _selectedCategory),
      ),
    );

    if (result == true) {
      await _loadBrands();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _bottomIndex == 2 ? 1 : 0,
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
                            onChanged: _searchBrands,
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

                          await _loadData();
                          await _refreshWheel();
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
                          itemCount: _filteredCategories.length,
                          itemBuilder: (_, index) {
                            final category =
                            _filteredCategories[index]["name"];
                            final selected = category == _selectedCategory;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _loadBrands();
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
                                      if (selected && _searchText.isEmpty) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          "${_brands.length}",
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
                          child: _brands.isEmpty
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
                            itemCount: _brands.length,
                            itemBuilder: (_, i) {
                              final brand = _brands[i];

                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                ),
                                child: Material(
                                  color: theme.brightness ==
                                      Brightness.dark
                                      ? const Color(0xFF2C2C2E)
                                      : const Color(0xFFFAFAFA),
                                  borderRadius:
                                  BorderRadius.circular(18),
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
                                            category: _selectedCategory,
                                          ),
                                        ),
                                      );

                                      if (result == true) {
                                        await _loadBrands();
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
          WheelPage(key: ValueKey(_wheelRefreshKey)),
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
              _navItem(Icons.menu_book, "热量库", 0),
              _addButton(),
              _navItem(Icons.casino_outlined, "转盘", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String text, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = _bottomIndex == index;

    return GestureDetector(
      onTap: () async {
        if (index == 2) {
          await _refreshWheel();
        }

        if (!mounted) return;

        setState(() {
          _bottomIndex = index;
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

  Widget _addButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _selectedCategory.isEmpty ? null : _openAddBrand,
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