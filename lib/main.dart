import 'package:flutter/material.dart';
import 'database/database_helper.dart';

void main() {
  runApp(const CalPalApp());
}

class Food {
  int? id;
  String name;
  String brand;
  String category;
  int kcal;

  Food({
    this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.kcal,
  });
}

class CalPalApp extends StatelessWidget {
  const CalPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalPal',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xffF5F7F9),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final kcalController = TextEditingController();

  String category = "饮料";

  final List<Food> foods = [];

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    final data = await DatabaseHelper.instance.getFoods();

    setState(() {
      foods.clear();

      for (final item in data) {
        foods.add(
          Food(
            id: item['id'],
            name: item['name'],
            brand: item['brand'],
            category: item['category'],
            kcal: item['calories'],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyword = searchController.text;

    final result = foods.where((f) {
      return f.name.contains(keyword) || f.brand.contains(keyword);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("🍱 宝宝热量库"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "搜索食物 / 品牌",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: result.length,
                itemBuilder: (context, index) {
                  final food = result[index];

                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      title: Text(food.name),
                      subtitle: Text("${food.brand} · ${food.category}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${food.kcal}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text("kcal"),
                        ],
                      ),
                      onLongPress: () {
                        setState(() {
                          foods.remove(food);
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "➕ 添加食物",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "食物名称"),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: kcalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "热量"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: "品牌"),
                  ),
                ),
              ],
            ),

            DropdownButton<String>(
              isExpanded: true,
              value: category,
              items: const [
                DropdownMenuItem(value: "饮料", child: Text("饮料")),
                DropdownMenuItem(value: "主食", child: Text("主食")),
                DropdownMenuItem(value: "蛋类", child: Text("蛋类")),
                DropdownMenuItem(value: "甜品", child: Text("甜品")),
                DropdownMenuItem(value: "其他", child: Text("其他")),
              ],
              onChanged: (v) {
                setState(() {
                  category = v!;
                });
              },
            ),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      kcalController.text.isEmpty) {
                    return;
                  }

                  final name = nameController.text;
                  final brand = brandController.text.isEmpty
                      ? "自定义"
                      : brandController.text;
                  final kcal = int.parse(kcalController.text);

                  await DatabaseHelper.instance.addFood(
                    name: name,
                    brand: brand,
                    category: category,
                    calories: kcal,
                  );

                  await loadFoods();

                  nameController.clear();
                  brandController.clear();
                  kcalController.clear();
                },
                child: const Text("保存到热量库"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}