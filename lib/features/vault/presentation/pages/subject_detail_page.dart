import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lecturio/injection_container.dart';
import 'package:lecturio/core/data/repositories/vault_repository.dart';
import 'package:lecturio/features/vault/domain/models/vault_item.dart';
import 'package:lecturio/core/constants/colors.dart';
import 'package:lecturio/features/vault/presentation/pages/pdf_viewer_page.dart';
import 'package:open_file/open_file.dart';

class SubjectDetailPage extends StatelessWidget {
  final String subjectName;
  final Color subjectColor;
  final String subjectId;

  const SubjectDetailPage({
    super.key,
    required this.subjectName,
    required this.subjectColor,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    final vaultItems = sl<VaultRepository>().getItemsBySubject(subjectId);
    final notes = vaultItems
        .where((item) => item.type == 'pdf')
        .toList(); // Placeholder logic
    final files = vaultItems.where((item) => item.type != 'pdf').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(subjectName),
          bottom: TabBar(
            indicatorColor: subjectColor,
            labelColor: subjectColor,
            tabs: const [
              Tab(text: 'Files', icon: Icon(Icons.folder)),
              Tab(text: 'Photos/Other', icon: Icon(Icons.image)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemsList(
              vaultItems.where((i) => i.type == 'pdf').toList(),
              Icons.picture_as_pdf,
              'pdf',
            ),
            _buildItemsList(
              vaultItems.where((i) => i.type == 'image').toList(),
              Icons.image,
              'image',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(List<VaultItem> items, IconData icon, String type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type == 'pdf' ? 'PDFs' : 'Images'} found',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: AppColors.secondaryNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: type == 'image'
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(item.filePath),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(icon, color: subjectColor),
                    ),
                  )
                : Icon(icon, color: subjectColor),
            title: Text(
              item.fileName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Lec #${item.lectureNumber} • ${item.topic}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.open_in_new,
                color: AppColors.textSecondary,
              ),
              onPressed: () => OpenFile.open(item.filePath),
            ),
            onTap: () {
              if (item.type == 'pdf') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerPage(
                      filePath: item.filePath,
                      title: item.fileName,
                    ),
                  ),
                );
              } else {
                // Show image in a full screen dialog
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: Stack(
                      children: [
                        InteractiveViewer(
                          child: Image.file(File(item.filePath)),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
