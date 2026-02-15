import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/exam_bloc.dart';
import '../widgets/exam_card.dart';
import '../widgets/add_exam_sheet.dart';
import '../../../../injection_container.dart';
import '../../../../core/data/repositories/subject_repository.dart';

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
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Lecturio Dashboard',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
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
        backgroundColor: AppColors.accentCoral,
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.softWhite,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See All',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
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
              child: Text(
                'No upcoming exams',
                style: GoogleFonts.outfit(color: AppColors.textSecondary),
              ),
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: AppColors.accentGold,
              ),
            ),
            title: const Text('Daily Review: Biology'),
            subtitle: const Text('Time to review your Vault notes.'),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
