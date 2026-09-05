import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class CategoryManagePage extends StatefulWidget {
  const CategoryManagePage({super.key});

  @override
  State<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends State<CategoryManagePage> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  /// ⭐ 关键修复：把 QueryRow 转成可修改的 Map
  Future<void> loadCategories() async {
    final data = await DatabaseHelper.instance.getCategories();

    categories = data
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();

    if (mounted) setState(() {});
  }

  // 新增分类
  Future<void> addCategory() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("新增分类"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "请输入分类名称",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text("确定"),
          )
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    await DatabaseHelper.instance.addCategory(name);
    await loadCategories();
  }

  // 编辑分类
  Future<void> editCategory(Map<String, dynamic> item) async {
    final controller = TextEditingController(text: item["name"]);

    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("编辑分类"),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("取消"),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text("保存"),
          )
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    await DatabaseHelper.instance.updateCategory(item["id"], name);
    await loadCategories();
  }

  // 删除分类
  Future<void> deleteCategory(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("删除分类"),
        content: Text(
          "确定删除「${item["name"]}」吗？\n该分类下的品牌和产品也会一起删除。",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("取消"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("删除"),
          )
        ],
      ),
    );

    if (ok != true) return;

    await DatabaseHelper.instance.deleteCategory(item["id"]);
    await loadCategories();
  }

  // ⭐ 排序
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);

    setState(() {});

    await DatabaseHelper.instance.updateCategoryOrder(categories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F5),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "分类管理",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ReorderableListView.builder(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              onReorder: reorder,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final item = categories[index];

                return Container(
                  key: ValueKey(item["id"]),
                  margin:
                  const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading:
                    ReorderableDragStartListener(
                      index: index,
                      child: const Icon(
                        Icons.drag_handle,
                        color: Colors.grey,
                      ),
                    ),
                    title: Text(
                      item["name"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.edit_outlined),
                          onPressed: () =>
                              editCategory(item),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              deleteCategory(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: addCategory,
                icon: const Icon(Icons.add),
                label: const Text("新增分类"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}