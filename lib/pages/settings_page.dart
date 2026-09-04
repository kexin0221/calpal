import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/export_service.dart';
import '../services/import_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("热量库管理")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FilledButton(
              onPressed: () async {
                final file =
                await ExportService.exportDatabase();

                await SharePlus.instance.share(
                  ShareParams(files: [XFile(file.path)]),
                );
              },
              child: const Text("导出热量库"),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final result =
                await FilePicker.platform.pickFiles();

                if (result == null) return;

                await ImportService.importDatabase(
                  File(result.files.single.path!),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("导入成功")),
                  );
                }
              },
              child: const Text("导入热量库"),
            ),
          ],
        ),
      ),
    );
  }
}