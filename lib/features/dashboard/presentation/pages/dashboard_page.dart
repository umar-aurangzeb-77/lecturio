import 'package:flutter/material.dart';
import 'package:lecturio/features/dashboard/presentation/pages/settings_page.dart';
import 'package:lecturio/core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lecturio/features/dashboard/presentation/bloc/exam_bloc.dart';
import 'package:lecturio/features/dashboard/presentation/widgets/exam_card.dart';
import 'package:lecturio/features/dashboard/presentation/widgets/add_exam_sheet.dart';
import 'package:lecturio/injection_container.dart';
import 'package:lecturio/core/data/repositories/subject_repository.dart';

import 'package:lecturio/core/theme/theme_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  return IconButton(
                    icon: Icon(
                      state.themeMode == AppThemeMode.green
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    onPressed: () {
                      context.read<ThemeBloc>().add(ToggleTheme());
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Lecturio Dashboard',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('Upcoming Exams', () {}),
                const SizedBox(height: 12),
                _buildExamList(),
                const SizedBox(height: 24),
                _buildSectionHeader('Smart Reminders', () {}),
                const SizedBox(height: 12),
                _buildReminderList(),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddExamSheet(),
          );
        },
        label: const Text('Add Exam'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }

  Widget _buildExamList() {
    return BlocBuilder<ExamBloc, ExamState>(
      builder: (context, state) {
        if (state is ExamLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ExamLoaded) {
          if (state.exams.isEmpty) {
            return Center(
              child: Text('No upcoming exams', style: GoogleFonts.inter()),
            );
          }

          final subjects = sl<SubjectRepository>().getAllSubjects();

          return SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.exams.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final exam = state.exams[index];
                final subject = subjects.firstWhere(
                  (s) => s.id == exam.subjectId,
                  orElse: () => subjects.first,
                );
                return ExamCard(exam: exam, subjectName: subject.name);
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildReminderList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text('No smart reminders yet', style: GoogleFonts.inter()),
      ),
    );
  }
}
