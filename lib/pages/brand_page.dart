import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class BrandPage extends StatefulWidget {
  final int brandId;
  final String brandName;

  const BrandPage({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> foods = [];

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    foods = await DatabaseHelper.instance.getFoods(widget.brandId);
    setState(() {});
  }

  Future<void> deleteFood(int id) async {
    await DatabaseHelper.instance.deleteFood(id);
    loadFoods();
  }

  // 添加产品
  Future<void> addFood() async {
    final nameController = TextEditingController();
    final kcalController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffF5F5F7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            20,
            22,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "添加产品",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 22),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "产品名称",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: kcalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "热量（kcal）",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final kcal = int.tryParse(kcalController.text.trim());

                    if (name.isEmpty || kcal == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("请填写正确的产品名称和热量")),
                      );
                      return;
                    }

                    try {
                      await DatabaseHelper.instance.addFood(
                        brandId: widget.brandId,
                        name: name,
                        calories: kcal,
                      );

                      Navigator.pop(sheetContext, true);
                    } catch (e) {
                      debugPrint(e.toString());

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("保存失败：$e")),
                      );
                    }
                  },
                  child: const Text("保存产品"),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      await loadFoods();
    }
  }

  // 编辑产品（长按）
  Future<void> editFood(Map<String, dynamic> food) async {
    final name = TextEditingController(text: food["name"]);
    final kcal = TextEditingController(text: food["calories"].toString());

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffF5F5F7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            22,
            20,
            22,
            MediaQuery.of(context).viewInsets.bottom + 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "编辑产品",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: name,
                decoration: _input("产品名称"),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: kcal,
                keyboardType: TextInputType.number,
                decoration: _input("热量 (kcal)"),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    await DatabaseHelper.instance.updateFood(
                      id: food["id"],
                      name: name.text.trim(),
                      calories: int.parse(kcal.text),
                    );

                    Navigator.pop(context, true);
                  },
                  child: const Text("保存修改"),
                ),
              )
            ],
          ),
        );
      },
    );

    if (ok == true) loadFoods();
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyword = searchController.text.trim();

    final result = foods.where((e) {
      return e["name"].toString().contains(keyword);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F7),
        centerTitle: true,
        title: Text(
          widget.brandName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: addFood,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
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
                  hintText: "搜索产品...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: result.isEmpty
                ? const Center(
              child: Text(
                "暂无产品\n点击右上角 + 添加",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  height: 1.6,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: result.length,
              itemBuilder: (_, i) {
                final food = result[i];

                return Dismissible(
                  key: ValueKey(food["id"]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => deleteFood(food["id"]),
                  child: GestureDetector(
                    onLongPress: () => editFood(food),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              food["name"],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${food["calories"]}",
                                style: const TextStyle(
                                  color: Color(0xff16A34A),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                "kcal",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
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