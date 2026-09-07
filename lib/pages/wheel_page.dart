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

  // 所有符合筛选条件的产品
  List<Map<String, dynamic>> candidates = [];

  // 当前这一轮转盘显示的12个产品
  List<Map<String, dynamic>> wheelFoods = [];

  Set<String> selectedCategories = {};
  Set<int> selectedBrands = {};
  Set<String> selectedRanges = {};

  late AnimationController controller;
  Animation<double>? rotationAnimation;

  double angle = 0;
  bool spinning = false;
  bool isLoading = true;
  double pointerOffset = 0;

  String resultBrand = "";
  String resultFood = "";
  int resultCalories = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    loadData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      categories = await db.getCategories();
      brands = await db.getAllBrands();
      foods = await db.getAllFoods();
      filterFoods();
    } catch (e) {
      // 可添加错误处理
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterFoods() {
    final brandMap = {
      for (var b in brands) b["id"]: b,
    };

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
        if (selectedRanges.contains("300-400") &&
            c >= 300 &&
            c < 400) ok = true;
        if (selectedRanges.contains("400-500") &&
            c >= 400 &&
            c < 500) ok = true;
        if (selectedRanges.contains("500+") && c >= 500) ok = true;

        if (!ok) return false;
      }

      return true;
    }).toList();

    candidates.shuffle();

    wheelFoods = candidates.take(min(12, candidates.length)).toList();

    setState(() {});
  }

  Future<void> spinWheel() async {
    if (spinning) return;
    if (candidates.isEmpty) return;
    if (wheelFoods.isEmpty) return;

    setState(() {
      spinning = true;
      resultBrand = "";
      resultFood = "";
      resultCalories = 0;
    });

    // 每一轮重新随机12个产品
    final pool = List<Map<String, dynamic>>.from(candidates);
    pool.shuffle();

    wheelFoods = pool.take(min(12, pool.length)).toList();

    setState(() {});

    final random = Random();

    final winner = random.nextInt(wheelFoods.length);

    final duration = 4 + random.nextDouble() * 3;

    final sweep = 2 * pi / wheelFoods.length;
    final targetAngle = (winner + 0.5) * sweep;

    final endAngle = angle +
        (2 * pi * (8 + random.nextInt(5))) +
        (2 * pi - targetAngle);

    controller.duration =
        Duration(milliseconds: (duration * 1000).round());

    rotationAnimation = Tween<double>(
      begin: angle,
      end: endAngle,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
    );

    controller.removeListener(_updateRotation);
    controller.addListener(_updateRotation);

    await controller.forward(from: 0);

    // 指针咔哒动画
    setState(() => pointerOffset = 8);
    await Future.delayed(const Duration(milliseconds: 70));
    setState(() => pointerOffset = 0);
    final food = wheelFoods[winner];

    final brand = brands.firstWhere(
          (e) => e["id"] == food["brandId"],
    );

    setState(() {
      angle = endAngle % (2 * pi);

      resultBrand = brand["name"];
      resultFood = food["name"];
      resultCalories = food["calories"];

      spinning = false;
    });
  }

  void _updateRotation() {
    if (rotationAnimation == null) return;

    setState(() {
      angle = rotationAnimation!.value;
    });
  }

  Future<void> chooseCategoryBrand() async {
    if (categories.isEmpty) return; // 防止空数据

    String currentCategory = selectedCategories.isEmpty
        ? categories.first["name"]
        : selectedCategories.first;

    final tempBrands = Set<int>.from(selectedBrands);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            final visibleBrands = brands.where((b) {
              return b["category"] == currentCategory;
            }).toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "选择品牌",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 96,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (_, i) {
                                final name = categories[i]["name"];
                                final selected =
                                    name == currentCategory;

                                return GestureDetector(
                                  onTap: () {
                                    setSheet(() {
                                      currentCategory = name;
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.black
                                          : Colors.transparent,
                                      borderRadius:
                                      BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ListView(
                              children: visibleBrands.map((b) {
                                return CheckboxListTile(
                                  value: tempBrands.contains(b["id"]),
                                  activeColor: Colors.black,
                                  title: Text(b["name"]),
                                  controlAffinity:
                                  ListTileControlAffinity.leading,
                                  onChanged: (_) {
                                    setSheet(() {
                                      tempBrands.contains(b["id"])
                                          ? tempBrands.remove(b["id"])
                                          : tempBrands.add(b["id"]);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          selectedBrands = tempBrands;

                          selectedCategories = tempBrands
                              .map((id) => brands.firstWhere(
                                (e) => e["id"] == id,
                          )["category"] as String)
                              .toSet();

                          Navigator.pop(context);
                          filterFoods();
                        },
                        child: const Text("完成"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> chooseRange() async {
    final temp = Set<String>.from(selectedRanges);

    const ranges = [
      "0-300",
      "300-400",
      "400-500",
      "500+",
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "热量区间",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...ranges.map((r) {
                      return CheckboxListTile(
                        value: temp.contains(r),
                        activeColor: Colors.black,
                        title: Text(r),
                        onChanged: (_) {
                          setSheet(() {
                            temp.contains(r)
                                ? temp.remove(r)
                                : temp.add(r);
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          selectedRanges = temp;
                          Navigator.pop(context);
                          filterFoods();
                        },
                        child: const Text("完成"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: chooseCategoryBrand,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.restaurant_menu,
                                size: 18),
                            const SizedBox(width: 6),
                            Text(
                              selectedBrands.isEmpty
                                  ? "分类・品牌"
                                  : "${selectedBrands.length} 个品牌",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: chooseRange,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              selectedRanges.isEmpty
                                  ? "热量区间"
                                  : "${selectedRanges.length} 个区间",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: angle,
                        child: CustomPaint(
                          size: const Size(300, 300),
                          painter: WheelPainter(wheelFoods),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 90),
                          curve: Curves.easeOut,
                          transform: Matrix4.translationValues(0, pointerOffset, 0),
                          child: const Icon(
                            Icons.arrow_drop_down,
                            size: 42,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: spinning ? null : spinWheel,
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              spinning ? "..." : "GO",
                              key: ValueKey(spinning),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                "共 ${candidates.length} 个候选产品",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: resultFood.isEmpty
                    ? const Center(
                  child: Text(
                    "点击 GO 开始",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.storefront,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resultBrand,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resultFood,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$resultCalories kcal",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final radius = size.width / 2;

    final fill = Paint()..style = PaintingStyle.fill;

    final divider = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1;

    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 外圈阴影
    canvas.drawCircle(
      center,
      radius + 4,
      Paint()..color = const Color(0x14000000),
    );

    if (foods.isEmpty) {
      fill.color = Colors.white;
      canvas.drawCircle(center, radius, fill);
      canvas.drawCircle(center, radius, outline);

      final tp = TextPainter(
        text: const TextSpan(
          text: "暂无产品",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
      );
      return;
    }

    final count = foods.length;
    final sweep = 2 * pi / count;

    // 扇区
    for (int i = 0; i < count; i++) {
      fill.color =
      i.isEven ? Colors.white : const Color(0xFFF5F5F5);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + i * sweep,
        sweep,
        true,
        fill,
      );
    }

    // 分割线
    for (int i = 0; i < count; i++) {
      final a = -pi / 2 + i * sweep;

      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(a) * radius,
          center.dy + sin(a) * radius,
        ),
        divider,
      );
    }

    // 文字
    for (int i = 0; i < count; i++) {
      final a = -pi / 2 + i * sweep + sweep / 2;

      final dx = center.dx + cos(a) * radius * 0.72;
      final dy = center.dy + sin(a) * radius * 0.72;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(a + pi / 2);

      final lines = _split(foods[i]["name"].toString());

      final tp = TextPainter(
        text: TextSpan(
          text: lines.join("\n"),
          style: const TextStyle(
            fontSize: 10,
            height: 1.05,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 56);

      tp.paint(
        canvas,
        Offset(-tp.width / 2, -tp.height / 2),
      );

      canvas.restore();
    }

    // 外框
    canvas.drawCircle(center, radius, outline);
  }

  List<String> _split(String name) {
    if (name.length <= 4) return [name];

    if (name.length <= 8) {
      return [
        name.substring(0, 4),
        name.substring(4),
      ];
    }

    return [
      name.substring(0, 4),
      "${name.substring(4, 7)}…",
    ];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}