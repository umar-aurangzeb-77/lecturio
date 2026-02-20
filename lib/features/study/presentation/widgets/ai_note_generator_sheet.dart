import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';
import '../../../../core/network/gemini_service.dart';
import '../../../../core/data/repositories/note_repository.dart';
import '../../../../core/data/repositories/subject_repository.dart';
import '../../../../core/models/subject.dart';

class AiNoteGeneratorSheet extends StatefulWidget {
  const AiNoteGeneratorSheet({super.key});

  @override
  State<AiNoteGeneratorSheet> createState() => _AiNoteGeneratorSheetState();
}

class _AiNoteGeneratorSheetState extends State<AiNoteGeneratorSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isGenerating = false;
  final _geminiService = sl<GeminiService>();
  final _noteRepository = sl<NoteRepository>();
  final _subjectRepository = sl<SubjectRepository>();

  String? _selectedSubjectId;
  List<Subject> _subjects = [];

  @override
  void initState() {
    super.initState();
    _subjects = _subjectRepository.getAllSubjects();
    if (_subjects.isNotEmpty) {
      _selectedSubjectId = _subjects.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
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
                'AI Note Generator',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_subjects.isNotEmpty) ...[
            Text(
              'Select Subject',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSubjectId,
                  isExpanded: true,
                  dropdownColor: AppColors.secondaryNavy,
                  items: _subjects.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        s.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedSubjectId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Paste your lecture text or transcription here...',
              fillColor: AppColors.primaryNavy,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generateNote,
              child: _isGenerating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Generate Smart Note'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _generateNote() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isGenerating = true);

    try {
      // 1. Generate the note using Gemini
      final note = await _geminiService.generateNoteFromText(
        _controller.text,
        _selectedSubjectId ?? 'default_subject',
      );

      // 2. Save the note to Hive via Repository
      await _noteRepository.addNote(note);

      if (mounted) {
        setState(() => _isGenerating = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note generated and saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
