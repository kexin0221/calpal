import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food.dart';
import '../widgets/bottom_nav.dart';
import 'brand_page.dart';
import 'add_food_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final search = TextEditingController();

  int categoryIndex = 0;
  int navIndex = 0;

  List<Food> foods = [];

  final categories = [
    "奶茶店",
    "轻食店",
    "甜品店",
    "快餐店",
    "咖啡店",
    "小吃店",
    "其他"
  ];

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    final data = await DatabaseHelper.instance.getFoods();
    foods = data.map((e) => Food.fromMap(e)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final current = categories[categoryIndex];

    final brands = foods
        .where((e) => e.category == current)
        .map((e) => e.brand)
        .toSet()
        .where((b) => b.contains(search.text))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: "搜索品牌...",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 100,
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
                          onTap: () {
                            setState(() => categoryIndex = i);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: selected ? Colors.black : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                categories[i],
                                style: TextStyle(
                                  color: selected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: brands.length,
                        itemBuilder: (_, i) {
                          final brand = brands[i];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BrandPage(brand: brand),
                                ),
                              );
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
                                    backgroundColor: Colors.grey.shade100,
                                    child: const Icon(Icons.store),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      brand,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
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
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddFoodPage(),
                      ),
                    );

                    if (result == true) loadFoods();
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