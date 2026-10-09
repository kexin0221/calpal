
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/export_service.dart';
import '../services/import_service.dart';
import 'category_manage_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool loading = false;

  Future<void> exportDatabase() async {
    setState(() => loading = true);

    try {
      final file = await ExportService.exportDatabase();

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: "CalPal 热量库备份",
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("导出失败：$e")),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> importDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["json"],
    );

    if (result == null) return;

    setState(() => loading = true);

    try {
      final file = File(result.files.single.path!);
      await ImportService.importDatabase(file);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("热量库导入成功")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("导入失败：$e")),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  Widget item({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: Icon(
            icon,
            color: colorScheme.onSurface,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colorScheme.onSurface.withValues(alpha: 0.55),
        ),
        onTap: loading ? null : onTap,
      ),
    );
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
        centerTitle: true,
        title: Text(
          "设置",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                "数据同步",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              item(
                icon: Icons.ios_share_rounded,
                title: "导出热量库",
                subtitle: "生成 calpal_backup.json",
                onTap: exportDatabase,
              ),
              item(
                icon: Icons.download_rounded,
                title: "导入热量库",
                subtitle: "从 JSON 恢复全部数据",
                onTap: importDatabase,
              ),
              const SizedBox(height: 28),
              Text(
                "管理",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              item(
                icon: Icons.category_outlined,
                title: "分类管理",
                subtitle: "新增、编辑、删除和排序分类",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoryManagePage(),
                    ),
                  );
                },
              ),
            ],
          ),
          if (loading)
            Positioned.fill(
              child: ColoredBox(
                color: colorScheme.scrim.withValues(alpha: 0.25),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}