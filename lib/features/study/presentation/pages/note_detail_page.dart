import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/note.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryNavy, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
              title: Text(
                note.title,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('Smart Summary'),
                const SizedBox(height: 12),
                _buildBulletPoints(note.content),
                const SizedBox(height: 32),
                _buildSectionHeader('Key Concepts'),
                const SizedBox(height: 12),
                _buildChips(note.keyConcepts),
                const SizedBox(height: 32),
                _buildSectionHeader('Quick Review'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryNavy,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accentGold.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    note.quickReview,
                    style: GoogleFonts.inter(fontSize: 16, height: 1.5),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildBulletPoints(String content) {
    final points = content.split('\n').where((s) => s.isNotEmpty).toList();
    return Column(
      children: points
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.accentGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p,
                      style: GoogleFonts.inter(fontSize: 16, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildChips(List<String> concepts) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: concepts
          .map(
            (c) => Chip(
              label: Text(c, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.secondaryNavy,
              side: const BorderSide(color: AppColors.textSecondary),
            ),
          )
          .toList(),
    );
  }
}
