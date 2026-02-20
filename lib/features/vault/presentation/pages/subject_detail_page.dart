import 'package:flutter/material.dart';
import 'package:lecturio/injection_container.dart';
import 'package:lecturio/core/data/repositories/vault_repository.dart';
import 'package:lecturio/features/vault/domain/models/vault_item.dart';
import 'package:lecturio/core/constants/colors.dart';
import 'package:lecturio/features/vault/presentation/pages/pdf_viewer_page.dart';

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
            ),
            _buildItemsList(
              vaultItems.where((i) => i.type == 'image').toList(),
              Icons.image,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(List<VaultItem> items, IconData icon) {
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
            const Text(
              'No items found',
              style: TextStyle(color: AppColors.textSecondary),
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
            leading: Icon(icon, color: subjectColor),
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
            trailing: const Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${item.type} is not supported yet'),
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
