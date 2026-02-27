import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:lecturio/core/constants/colors.dart';
import 'package:lecturio/injection_container.dart';
import 'package:lecturio/core/data/repositories/subject_repository.dart';
import 'package:lecturio/core/data/repositories/vault_repository.dart';
import 'package:lecturio/features/vault/domain/models/vault_item.dart';
import 'package:uuid/uuid.dart';

class UploadFileSheet extends StatefulWidget {
  const UploadFileSheet({super.key});

  @override
  State<UploadFileSheet> createState() => _UploadFileSheetState();
}

class _UploadFileSheetState extends State<UploadFileSheet> {
  final _vaultRepository = sl<VaultRepository>();
  final _subjectRepository = sl<SubjectRepository>();

  String? _selectedSubjectId;
  PlatformFile? _pickedFile;
  final _lectureController = TextEditingController();
  final _topicController = TextEditingController();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<void> _upload() async {
    if (_pickedFile == null || _selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a file and select a subject'),
        ),
      );
      return;
    }

    final type = _pickedFile!.extension?.toLowerCase() == 'pdf'
        ? 'pdf'
        : 'image';

    // Permanent storage logic
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${appDir.path}/vault');
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }

    final id = const Uuid().v4();
    final newFileName = '${id}_${_pickedFile!.name}';
    final permanentPath = p.join(vaultDir.path, newFileName);

    // Copy file to permanent storage
    final file = File(_pickedFile!.path!);
    await file.copy(permanentPath);

    final newItem = VaultItem(
      id: id,
      subjectId: _selectedSubjectId!,
      fileName: _pickedFile!.name,
      filePath: permanentPath,
      type: type,
      date: DateTime.now(),
      lectureNumber: int.tryParse(_lectureController.text) ?? 0,
      topic: _topicController.text.isEmpty ? 'General' : _topicController.text,
    );

    await _vaultRepository.addItem(newItem);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = _subjectRepository.getAllSubjects();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.secondaryNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upload Content',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // File Picker Area
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentCoral.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _pickedFile != null
                        ? Icons.check_circle_rounded
                        : Icons.cloud_upload_rounded,
                    size: 48,
                    color: _pickedFile != null
                        ? Colors.greenAccent
                        : AppColors.accentCoral,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _pickedFile?.name ?? 'Tap to pick PDF or Image',
                    style: GoogleFonts.inter(
                      color: _pickedFile != null
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Subject Dropdown
          Text(
            'Select Subject',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSubjectId,
                hint: const Text(
                  'Choose a subject',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                isExpanded: true,
                dropdownColor: AppColors.primaryNavy,
                items: subjects.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text(
                      s.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSubjectId = val),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lecture #',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _lectureController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'e.g. 5',
                        filled: true,
                        fillColor: AppColors.primaryNavy,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topic',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _topicController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Calculus',
                        filled: true,
                        fillColor: AppColors.primaryNavy,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _upload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCoral,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Add to Vault',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
