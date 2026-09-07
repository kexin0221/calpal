import 'dart:math';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class WheelPage extends StatefulWidget {
  const WheelPage({super.key});

  @override
  State<WheelPage> createState() => _WheelPageState();
}

class _WheelPageState extends State<WheelPage>
    with SingleTickerProviderStateMixin {
  final db = DatabaseHelper.instance;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> foods = [];

  Set<String> selectedCategories = {};
  Set<int> selectedBrands = {};
  Set<String> selectedRanges = {};

  List<Map<String, dynamic>> candidates = [];

  late AnimationController controller;

  double angle = 0;
  String result = "点击开始";

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    categories = await db.getCategories();
    brands = await db.getAllBrands();
    foods = await db.getAllFoods();
    filterFoods();
  }

  void filterFoods() {
    final brandMap = {for (var b in brands) b["id"]: b};

    candidates = foods.where((food) {
      final brand = brandMap[food["brandId"]];
      if (brand == null) return false;

      if (selectedCategories.isNotEmpty &&
          !selectedCategories.contains(brand["category"])) {
        return false;
      }

      if (selectedBrands.isNotEmpty &&
          !selectedBrands.contains(brand["id"])) {
        return false;
      }

      final c = food["calories"] as int;

      if (selectedRanges.isNotEmpty) {
        bool ok = false;
        if (selectedRanges.contains("0-300") && c < 300) ok = true;
        if (selectedRanges.contains("300-400") && c >= 300 && c < 400) ok = true;
        if (selectedRanges.contains("400-500") && c >= 400 && c < 500) ok = true;
        if (selectedRanges.contains("500+") && c >= 500) ok = true;
        if (!ok) return false;
      }

      return true;
    }).toList();

    candidates.shuffle();

    setState(() {});
  }

  Future<void> spin() async {
    if (candidates.isEmpty) return;

    final random = Random();

    final duration = 4 + random.nextDouble() * 3;
    final target = random.nextInt(candidates.length);

    final sweep = 2 * pi / candidates.length;
    final stopAngle = (target + 0.5) * sweep;

    final totalRotation = pi * (8 + random.nextInt(5)) + (2 * pi - stopAngle);

    controller.dispose();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (duration * 1000).round()),
    );

    final animation = Tween<double>(
      begin: angle,
      end: angle + totalRotation,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );

    animation.addListener(() {
      setState(() => angle = animation.value);
    });

    await controller.forward();

    result =
    "${candidates[target]["name"]}【${candidates[target]["calories"]} kcal】";

    setState(() {});
  }

  Future<void> showCategorySheet() async {
    final temp = Set<String>.from(selectedCategories);

    await showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("选择分类",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      children: categories.map((e) {
                        final name = e["name"];
                        return CheckboxListTile(
                          value: temp.contains(name),
                          title: Text(name),
                          activeColor: Colors.black,
                          onChanged: (_) {
                            setSheet(() {
                              temp.contains(name)
                                  ? temp.remove(name)
                                  : temp.add(name);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () {
                      selectedCategories = temp;
                      Navigator.pop(context);
                      filterFoods();
                    },
                    child: const Text("完成"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> showBrandSheet() async {
    final temp = Set<int>.from(selectedBrands);

    final visibleBrands = brands.where((b) {
      if (selectedCategories.isEmpty) return true;
      return selectedCategories.contains(b["category"]);
    }).toList();

    await showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("选择品牌",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      children: visibleBrands.map((b) {
                        return CheckboxListTile(
                          value: temp.contains(b["id"]),
                          title: Text(b["name"]),
                          subtitle: Text(b["category"]),
                          activeColor: Colors.black,
                          onChanged: (_) {
                            setSheet(() {
                              temp.contains(b["id"])
                                  ? temp.remove(b["id"])
                                  : temp.add(b["id"]);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () {
                      selectedBrands = temp;
                      Navigator.pop(context);
                      filterFoods();
                    },
                    child: const Text("完成"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> showRangeSheet() async {
    final temp = Set<String>.from(selectedRanges);
    const ranges = ["0-300", "300-400", "400-500", "500+"];

    await showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("热量区间",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...ranges.map((r) => CheckboxListTile(
                    value: temp.contains(r),
                    title: Text(r),
                    activeColor: Colors.black,
                    onChanged: (_) {
                      setSheet(() {
                        temp.contains(r) ? temp.remove(r) : temp.add(r);
                      });
                    },
                  )),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () {
                      selectedRanges = temp;
                      Navigator.pop(context);
                      filterFoods();
                    },
                    child: const Text("完成"),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("今天吃什么"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: showCategorySheet,
                    child: const Text("分类・品牌"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: showRangeSheet,
                    child: const Text("热量区间"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: spin,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: angle,
                        child: CustomPaint(
                          size: const Size(280, 280),
                          painter: WheelPainter(candidates),
                        ),
                      ),
                      const Positioned(
                        top: 0,
                        child: Icon(Icons.arrow_drop_down,
                            size: 40, color: Colors.black),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "旋转",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "结果",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              result,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> foods;

  WheelPainter(this.foods);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final paint = Paint()..style = PaintingStyle.fill;
    final border = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (foods.isEmpty) {
      paint.color = Colors.white;
      canvas.drawCircle(center, r, paint);
      canvas.drawCircle(center, r, border);

      final tp = TextPainter(
        text: const TextSpan(
          text: "暂无产品",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
      );
      return;
    }

    final sweep = 2 * pi / foods.length;

    for (int i = 0; i < foods.length; i++) {
      paint.color = i.isEven ? Colors.white : const Color(0xFFF3F4F6);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -pi / 2 + i * sweep,
        sweep,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -pi / 2 + i * sweep,
        sweep,
        true,
        border,
      );

      final angle = -pi / 2 + i * sweep + sweep / 2;

      canvas.save();
      canvas.translate(
        center.dx + cos(angle) * r * 0.63,
        center.dy + sin(angle) * r * 0.63,
      );
      canvas.rotate(angle + pi / 2);

      final name = foods[i]["name"].toString();

      final tp = TextPainter(
        text: TextSpan(
          text: name.length > 6 ? "${name.substring(0, 6)}…" : name,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 60);

      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}