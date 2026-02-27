import 'package:flutter/material.dart';
import 'package:lecturio/core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecturio/features/vault/presentation/pages/subject_detail_page.dart';
import 'package:lecturio/features/vault/presentation/widgets/upload_file_sheet.dart';
import 'package:lecturio/features/vault/presentation/widgets/add_subject_sheet.dart';
import 'package:lecturio/injection_container.dart';
import 'package:lecturio/core/data/repositories/subject_repository.dart';
import 'package:lecturio/core/data/repositories/note_repository.dart';
import 'package:lecturio/core/data/repositories/vault_repository.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddSubjectSheet(),
              ).then((value) {
                if (value == true) setState(() {});
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVaultStats(),
            const SizedBox(height: 32),
            Text(
              'Subject Folders',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  final subjects = sl<SubjectRepository>().getAllSubjects();
                  if (subjects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No subjects created yet',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const AddSubjectSheet(),
                              ).then((value) {
                                if (value == true) setState(() {});
                              });
                            },
                            child: const Text('Create your first folder'),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return _buildSubjectFolderCard(
                        context,
                        id: subject.id,
                        name: subject.name,
                        fileCount: sl<VaultRepository>()
                            .getItemsBySubject(subject.id)
                            .length,
                        color: Color(int.parse(subject.color)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'vault_fab',
        onPressed: () {
          final subjects = sl<SubjectRepository>().getAllSubjects();
          if (subjects.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please create a subject folder first!'),
              ),
            );
            return;
          }
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const UploadFileSheet(),
          ).then((value) {
            if (value == true) setState(() {});
          });
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
    );
  }

  Widget _buildVaultStats() {
    final noteCount = sl<NoteRepository>().getAllNotes().length;
    final vaultItems = sl<VaultRepository>().getAllItems();
    final pdfCount = vaultItems.where((item) => item.type == 'pdf').length;
    final imageCount = vaultItems.where((item) => item.type == 'image').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryNavy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
            'PDFs',
            pdfCount.toString(),
            Icons.picture_as_pdf,
            Colors.redAccent,
          ),
          _buildDivider(),
          _buildStatColumn(
            'Images',
            imageCount.toString(),
            Icons.image,
            Colors.blueAccent,
          ),
          _buildDivider(),
          _buildStatColumn(
            'Notes',
            noteCount.toString(),
            Icons.notes,
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.textSecondary.withOpacity(0.2),
    );
  }

  Widget _buildSubjectFolderCard(
    BuildContext context, {
    required String id,
    required String name,
    required int fileCount,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailPage(
              subjectName: name,
              subjectColor: color,
              subjectId: id,
            ), // Fixed constructor
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondaryNavy,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.folder, color: color, size: 48),
            const Spacer(),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$fileCount Files',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
