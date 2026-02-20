import 'package:flutter/material.dart';
import 'package:lecturio/core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lecturio/features/study/presentation/widgets/ai_note_generator_sheet.dart';
import 'package:lecturio/injection_container.dart';
import 'package:lecturio/core/data/repositories/note_repository.dart';
import 'package:lecturio/core/data/repositories/subject_repository.dart';
import 'package:lecturio/features/study/presentation/pages/note_detail_page.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final _noteRepository = sl<NoteRepository>();
  final _subjectRepository = sl<SubjectRepository>();
  String _selectedSubjectId = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Study'),
        actions: [
          IconButton(icon: const Icon(Icons.history_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionCard(
              title: 'AI Note Generator',
              subtitle: 'Summarize lectures into bullet points',
              icon: FontAwesomeIcons.bolt,
              color: Colors.deepPurpleAccent,
              onTap: () => _overlayGenerator(context),
            ),
            const SizedBox(height: 20),
            _buildActionCard(
              title: 'Voice to Note',
              subtitle: 'Upload audio/video recordings',
              icon: Icons.mic_rounded,
              color: Colors.blueAccent,
              onTap: () {},
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Notes',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedSubjectId != 'all')
                  TextButton(
                    onPressed: () => setState(() => _selectedSubjectId = 'all'),
                    child: const Text('Clear Filter'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSubjectFilter(),
            const SizedBox(height: 16),
            _buildRecentNotesList(),
          ],
        ),
      ),
    );
  }

  void _overlayGenerator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiNoteGeneratorSheet(),
    ).then((_) => setState(() {})); // Refresh notes after sheet closes
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectFilter() {
    final subjects = _subjectRepository.getAllSubjects();
    if (subjects.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFilterChip('All', 'all');
          }
          final subject = subjects[index - 1];
          return _buildFilterChip(subject.name, subject.id);
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String id) {
    final isSelected = _selectedSubjectId == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedSubjectId = id);
      },
      selectedColor: AppColors.primaryGreen,
      backgroundColor: AppColors.secondaryNavy,
      labelStyle: TextStyle(
        color: Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildRecentNotesList() {
    var notes = _noteRepository.getAllNotes();

    if (_selectedSubjectId != 'all') {
      notes = notes.where((n) => n.subjectId == _selectedSubjectId).toList();
    }

    if (notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            _selectedSubjectId == 'all'
                ? 'No notes yet. Generate some with AI!'
                : 'No notes for this subject.',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryNavy,
              child: Icon(Icons.description, color: AppColors.accentCoral),
            ),
            title: Text(note.title),
            subtitle: Text(
              note.content.length > 50
                  ? '${note.content.substring(0, 50)}...'
                  : note.content,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailPage(note: note),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
