
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'brand_page.dart';
import 'add_brand_page.dart';
import 'settings_page.dart';
import 'category_manage_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper db = DatabaseHelper.instance;

  final List<String> categories = [
    "奶茶",
    "果茶",
    "咖啡",
    "甜品",
    "糖水",
    "轻食",
    "烘焙",
    "三明治",
    "西式快餐",
    "中式快餐",
  ];

  String selectedCategory = "奶茶";
  String searchText = "";
  int bottomIndex = 0;

  List<Map<String, dynamic>> brands = [];

  @override
  void initState() {
    super.initState();
    loadBrands();
  }

  Future<void> loadBrands() async {
    final data = await db.getBrands(selectedCategory);

    setState(() {
      brands = data.where((e) {
        return e["name"].toString().contains(searchText);
      }).toList();
    });
  }

  Future<void> openAddBrand() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddBrandPage(
          category: selectedCategory,
        ),
      ),
    );

    if (result == true) {
      await loadBrands();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ================= 搜索栏 + 设置 =================
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
                        onChanged: (v) {
                          searchText = v;
                          loadBrands();
                        },
                        decoration: const InputDecoration(
                          hintText: "",
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 22,
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
                  // ================= 左侧分类 =================
                  Container(
                    width: 96,
                    margin: const EdgeInsets.only(left: 14, bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      itemCount: categories.length + 1,
                      itemBuilder: (_, index) {
                        // 编辑按钮
                        if (index == categories.length) {
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const CategoryManagePage(),
                                  ),
                                );

                                await loadBrands();
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text(""),
                            ),
                          );
                        }

                        final c = categories[index];
                        final selected = c == selectedCategory;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = c;
                            });

                            loadBrands();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            height: 52,
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                c,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ================= 品牌区域 =================
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 14, bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                "品牌",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${brands.length} 个",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Expanded(
                            child: brands.isEmpty
                                ? const Center(
                              child: Text(
                                "暂无品牌\n点击下方 + 添加",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            )
                                : ListView.builder(
                              itemCount: brands.length,
                              itemBuilder: (_, i) {
                                final brand = brands[i];

                                return Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 10),
                                  child: Material(
                                    color: const Color(0xffFAFAFA),
                                    borderRadius:
                                    BorderRadius.circular(18),
                                    child: InkWell(
                                      borderRadius:
                                      BorderRadius.circular(18),
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BrandPage(
                                              brandId:
                                              brand["id"] as int,
                                              brandName:
                                              brand["name"] as String,
                                              category:
                                              selectedCategory,
                                            ),
                                          ),
                                        );

                                        loadBrands();
                                      },
                                      child: Container(
                                        padding:
                                        const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 46,
                                              height: 46,
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .grey.shade200,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.store,
                                                size: 22,
                                              ),
                                            ),

                                            const SizedBox(width: 14),

                                            Expanded(
                                              child: Text(
                                                brand["name"],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                  FontWeight.w600,
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ================= 底部导航 =================
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
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
    final selected = bottomIndex == index;

    return GestureDetector(
      onTap: () {
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
            Icon(
              icon,
              color: selected ? Colors.white : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: openAddBrand,
      child: Container(
        width: 58,
        height: 58,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}