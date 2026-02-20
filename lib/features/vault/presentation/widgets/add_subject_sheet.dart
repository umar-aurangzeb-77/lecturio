import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lecturio/core/constants/colors.dart';
import 'package:lecturio/injection_container.dart';
import 'package:lecturio/core/data/repositories/subject_repository.dart';
import 'package:lecturio/core/models/subject.dart';
import 'package:uuid/uuid.dart';

class AddSubjectSheet extends StatefulWidget {
  const AddSubjectSheet({super.key});

  @override
  State<AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<AddSubjectSheet> {
  final _nameController = TextEditingController();
  String _selectedColor = '0xFF2196F3'; // Blue default

  final List<String> _colors = [
    '0xFF2196F3', // Blue
    '0xFF4CAF50', // Green
    '0xFFFF9800', // Orange
    '0xFF9C27B0', // Purple
    '0xFFF44336', // Red
    '0xFFFFE74C', // Yellow
  ];

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;

    final newSubject = Subject(
      id: const Uuid().v4(),
      name: _nameController.text,
      icon: 'folder', // Default icon
      color: _selectedColor,
    );

    await sl<SubjectRepository>().addSubject(newSubject);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            'New Subject',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Subject Name',
              hintText: 'e.g. Physics II',
              filled: true,
              fillColor: AppColors.primaryNavy,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Folder Color',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final colorStr = _colors[index];
                final isSelected = _selectedColor == colorStr;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorStr),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Color(int.parse(colorStr)),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCoral,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Create Folder',
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
