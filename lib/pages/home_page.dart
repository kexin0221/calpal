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

  final List<String> categories = [
    "奶茶店",
    "轻食店",
    "甜品店",
    "快餐店",
    "咖啡店",
    "小吃店",
    "其他",
  ];

  List<Map<String, dynamic>> brands = [];

  @override
  void initState() {
    super.initState();
    loadBrands();
  }

  Future<void> loadBrands() async {
    final data = await DatabaseHelper.instance.getBrands(
      categories[categoryIndex],
    );

    setState(() {
      brands = data;
    });
  }

  Future<void> deleteBrand(int id) async {
    await DatabaseHelper.instance.deleteBrand(id);
    loadBrands();
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 96,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (_, i) {
                        final selected = i == categoryIndex;

                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              categoryIndex = i;
                            });

                            await loadBrands();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                categories[i],
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
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
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
                                  style: const TextStyle(color: Colors.grey),
                                ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: result.length,
                              itemBuilder: (_, i) {
                                final brand = result[i];

                                return Dismissible(
                                  key: ValueKey(brand["id"]),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(18),
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
                                          builder: (_) => BrandPage(
                                            brandId: brand["id"],
                                            brandName: brand["name"],
                                          ),
                                        ),
                                      );

                                      loadBrands();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: Colors.grey.shade100,
                                            child: const Icon(
                                              Icons.storefront_outlined,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              brand["name"],
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.grey,
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
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: BottomNav(
                index: navIndex,
                onTap: (i) async {
                  setState(() => navIndex = i);

                  if (i == 1) {
                    final ok = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddFoodPage(
                          category: categories[categoryIndex],
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
            ),
          ],
        ),
      ),
    );
  }
}