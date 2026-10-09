
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddBrandPage extends StatefulWidget {
  final String category;

  const AddBrandPage({
    super.key,
    required this.category,
  });

  @override
  State<AddBrandPage> createState() => _AddBrandPageState();
}

class _AddBrandPageState extends State<AddBrandPage> {
  final TextEditingController nameController = TextEditingController();

  Future<void> saveBrand() async {
    final name = nameController.text.trim();

    if (name.isEmpty) return;

    await DatabaseHelper.instance.addBrand(
      category: widget.category,
      name: name,
    );

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "添加品牌",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "品牌名称",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "当前分类",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                widget.category,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: saveBrand,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  "保存品牌",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}